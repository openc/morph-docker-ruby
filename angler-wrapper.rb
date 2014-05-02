#!/usr/bin/env ruby
# for each line in stdout
# send it to a server
require 'hutch'
require 'open3'

def send
  config = Hutch::Config
  config.set(:mq_host, 'rabbit1')
  config.set(:mq_api_host, 'rabbit1')
  config.set(:mq_api_port, 55672)
  config.set(:mq_vhost, '/')
  Hutch.connect({}, config)
  command_output_each_line(ARGV.join(" "), {}) do |line|
    Hutch.publish('bot.record', JSON.parse(line))
  end
end

def command_output_each_line(command, options={})
  Open3::popen3(command, options) do |_, stdout, stderr, wait_thread|
    loop do
      check_output_with_timeout(stdout)

      begin
        yield stdout.readline
      rescue EOFError
        break
      end
    end
    status = wait_thread.value.exitstatus
    if status > 0
      message = "Bot <#{command}> exited with status #{status}: #{stderr.read}"
      raise RuntimeError.new(message)
    end
  end
end

def check_output_with_timeout(stdout, initial_interval = 10, timeout = 1)
  interval = initial_interval
  loop do
    reads, _, _ = IO.select([stdout], [], [], interval)
    break if !reads.nil?
    raise "Timeout! - could not read from external bot after #{timeout} seconds" if reads.nil? && interval > timeout
    interval *= 2
  end
end

send
