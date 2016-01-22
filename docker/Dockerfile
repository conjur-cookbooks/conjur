FROM ruby:2.1
MAINTAINER Conjur, Inc

WORKDIR /src

RUN curl -O https://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/12.04/x86_64/chefdk_0.10.0-1_amd64.deb && \
  dpkg -i chefdk_0.10.0-1_amd64.deb && \
  rm chefdk_0.10.0-1_amd64.deb

COPY Gemfile Gemfile.lock ./
RUN chef exec bundle install
RUN chef exec gem install 'rubocop-checkstyle_formatter'

COPY attributes/ attributes/
COPY files/ files/
COPY libraries/ libraries/ 
COPY recipes/ recipes/ 
COPY templates/ templates/ 
COPY distrib/ distrib/

RUN chmod 0600 distrib/id_rsa
COPY Berksfile Berksfile.lock metadata.rb ./
