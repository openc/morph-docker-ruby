FROM openaustralia/morph-base
MAINTAINER OpenCorporates <tech@opencorporates.com>
# Set the locale
RUN locale-gen en_GB.UTF-8
ENV LANG en_GB.UTF-8
ENV LANGUAGE en_GB:en
ENV LC_ALL en_GB.UTF-8

# libcurl is needed by typhoeus gem
RUN apt-get update
RUN apt-get -y install curl libsm6 libxslt-dev libxml2-dev libcurl4-gnutls-dev poppler-utils

# This installs various executables that are useful for scraping
RUN apt-get -y install --no-install-recommends gnumeric gocr libjpeg-progs p7zip-full unzip

# Install the most recent version of libreoffice
RUN apt-get -y install --no-install-recommends libgl1-mesa-dri libglu1-mesa
RUN LIBRE_OFFICE_VERSION=$(curl -s http://www.mirrorservice.org/sites/download.documentfoundation.org/tdf/libreoffice/stable/ | grep icons/folder | tail -1 | sed -r -e 's/.*>(.+)<\/a.*/\1/'|sed -r -e 's/\///') && mkdir /build && cd /build && curl -L -O http://www.mirrorservice.org/sites/download.documentfoundation.org/tdf/libreoffice/stable/${LIBRE_OFFICE_VERSION}/deb/x86_64/LibreOffice_${LIBRE_OFFICE_VERSION}_Linux_x86-64_deb.tar.gz && tar xzf LibreOffice_${LIBRE_OFFICE_VERSION}_Linux_x86-64_deb.tar.gz && cd LibreOffice_${LIBRE_OFFICE_VERSION}*/DEBS && dpkg -i *.deb
RUN rm -rf /build
RUN /bin/bash -l -c 'ln -s /usr/local/bin/libreoffice* /usr/local/bin/libreoffice'

# PDFBox
RUN /bin/bash -l -c 'cd /tmp && curl http://mirrors.ukfast.co.uk/sites/ftp.apache.org/pdfbox/2.0.0-RC3/pdfbox-app-2.0.0-RC3.jar > /usr/local/lib/pdfbox-app-2.0.0-RC3.jar'
RUN /bin/bash -l -c 'ln -s /usr/local/lib/pdfbox-app-2.0.0-RC3.jar /usr/local/lib/pdfbox-app.jar'


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
RUN addgroup --gid 3000 openc
RUN adduser --home /home/openc --disabled-login --gecos "Openc User" --uid 3000 --gid 3000 openc

ENV HOME=/home/openc
USER openc
