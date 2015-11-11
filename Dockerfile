FROM openaustralia/morph-base
MAINTAINER Seb Bacon <seb@opencorporates.com>

# Set the locale
RUN locale-gen en_GB.UTF-8
ENV LANG en_GB.UTF-8
ENV LANGUAGE en_GB:en
ENV LC_ALL en_GB.UTF-8

# libcurl is needed by typhoeus gem
RUN apt-get update
RUN apt-get -y install curl libxslt-dev libxml2-dev libcurl4-gnutls-dev poppler-utils

# This installs various executables that are useful for scraping
RUN apt-get -y install --no-install-recommends gnumeric gocr libjpeg-progs unzip

# Install the most recent version of libreoffice
RUN apt-get -y install --no-install-recommends libgl1-mesa-dri libglu1-mesa
RUN mkdir /build && cd /build && curl -O http://www.mirrorservice.org/sites/download.documentfoundation.org/tdf/libreoffice/stable/5.0.3/deb/x86_64/LibreOffice_5.0.3_Linux_x86-64_deb.tar.gz && tar xzf LibreOffice_5.0.3_Linux_x86-64_deb.tar.gz && cd LibreOffice_5.0.3.2_Linux_x86-64_deb/DEBS && dpkg -i *.deb
RUN rm -rf /build
RUN /bin/bash -l -c 'ln -s /usr/local/bin/libreoffice5.0 /usr/local/bin/libreoffice'

# PDFBox
RUN /bin/bash -l -c 'cd /tmp && curl http://mirrors.ukfast.co.uk/sites/ftp.apache.org/pdfbox/2.0.0-RC1/pdfbox-app-2.0.0-RC1.jar > /usr/local/lib/pdfbox-app-2.0.0-RC1.jar'
RUN /bin/bash -l -c 'ln -s /usr/local/lib/pdfbox-app-2.0.0-RC1.jar /usr/local/lib/pdfbox-app.jar'


RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3
RUN curl -sSL https://get.rvm.io | bash -s stable
RUN echo 'source /usr/local/rvm/scripts/rvm' >> /etc/bash.bashrc

RUN /bin/bash -l -c 'rvm install ruby-1.9.3-p545'
RUN /bin/bash -l -c 'gem install bundler'


# Volume for sharing wrapper script
VOLUME /utils

# Special handling for scraperwiki gem because rubygems doesn't support
# gems from git repositories. So we have to explicitly install it.
RUN mkdir /build
RUN git clone https://github.com/openaustralia/scraperwiki-ruby.git /build
RUN cd /build; git checkout morph_defaults
# rake install is not working so doing it in two steps
# TODO Figure out what is going on here
RUN /bin/bash -l -c 'cd /build; rake --trace build'
RUN /bin/bash -l -c 'cd /build; gem install /build/pkg/scraperwiki-3.0.1.gem'
RUN rm -rf /build

# Add prerun script which will disable output buffering
ADD prerun.rb /usr/local/lib/prerun.rb

# Install apache tika
# Required for tika
RUN apt-get update
RUN apt-get -y install openjdk-7-jre-headless
RUN /bin/bash -l -c 'cd /tmp && curl http://mirror.ox.ac.uk/sites/rsync.apache.org/tika/tika-app-1.7.jar > /usr/local/tika-app-1.7.jar'


ADD Gemfile /etc/Gemfile
RUN /bin/bash -l -c 'bundle install --gemfile /etc/Gemfile'
# For some reason bundle install doesn't install everything, so we need to do it twice
RUN /bin/bash -l -c 'rm /etc/Gemfile.lock'
RUN /bin/bash -l -c 'bundle install --gemfile /etc/Gemfile'


VOLUME /output

ENV HOME=/home/scraper
