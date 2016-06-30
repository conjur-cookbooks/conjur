FROM ruby:2.1
MAINTAINER Conjur, Inc

RUN apt-get update -yqq && apt-get install -yq rsync curl ssh

WORKDIR /src

RUN curl -L -o /tmp/chefdk.deb https://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/12.04/x86_64/chefdk_0.10.0-1_amd64.deb && \
  dpkg -i /tmp/chefdk.deb && \
  rm /tmp/chefdk.deb

RUN curl -L -o /tmp/vagrant.deb https://releases.hashicorp.com/vagrant/1.7.4/vagrant_1.7.4_x86_64.deb && \
  dpkg -i /tmp/vagrant.deb && \
  rm /tmp/vagrant.deb

RUN vagrant plugin install vagrant-berkshelf && \
  vagrant plugin install vagrant-omnibus && \
  vagrant plugin install vagrant-aws

# vagrant 1.7.4 wants bundler <= 1.10.5
RUN gem uninstall -axq bundler && gem install bundler --version '1.10.5'

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY attributes/ attributes/
COPY files/ files/
COPY libraries/ libraries/
COPY recipes/ recipes/
COPY templates/ templates/

COPY Berksfile Berksfile.lock metadata.rb ./
