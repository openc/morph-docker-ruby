FROM openaustralia/morph-ruby
MAINTAINER Seb Bacon <seb@opencorporates.com>

ADD Gemfile /etc/Gemfile.opencorporates
ADD angler-wrapper.rb /usr/bin/angler-wrapper.rb

RUN /bin/bash -l -c 'bundle install --system --gemfile /etc/Gemfile.opencorporates'
