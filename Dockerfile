FROM docker-registry.opencorporates.com/opencorporates/morph-ruby:latest-built-from-source
MAINTAINER OpenCorporates <tech@opencorporates.com>

USER root

# replace the original links with their old-releases equivalents
RUN sed -i.bak -r 's/(archive|security).ubuntu.com/old-releases.ubuntu.com/g' /etc/apt/sources.list && \
    apt-get update && \
    apt-get -y install gnupg2 libsqlite3-dev

# Volume for sharing wrapper script
VOLUME /utils

ADD Gemfile* /etc/
RUN /bin/bash -l -c 'gem install --force -v 1.17.3 bundler' && \
    /bin/bash -l -c 'sed -i -e "s/https:/http:/" /etc/Gemfile && bundle install --gemfile /etc/Gemfile'

VOLUME /output

USER openc
