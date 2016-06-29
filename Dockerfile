FROM debian:jessie
MAINTAINER Conjur, Inc

RUN apt-get update -yqq && apt-get install -yq rsync curl

RUN curl -L -o /tmp/chefdk.deb https://packages.chef.io/stable/debian/8/chefdk_0.15.15-1_amd64.deb && \
  dpkg -i /tmp/chefdk.deb && \
  rm /tmp/chefdk.deb

RUN curl -L -o /tmp/vagrant.deb https://releases.hashicorp.com/vagrant/1.8.4/vagrant_1.8.4_x86_64.deb && \
  dpkg -i /tmp/vagrant.deb && \
  rm /tmp/vagrant.deb

RUN vagrant plugin install vagrant-berkshelf && \
  vagrant plugin install vagrant-omnibus && \
  vagrant plugin install vagrant-aws

# Add ChefDK's Ruby to path
ENV PATH /opt/chefdk/embedded/bin:$PATH

WORKDIR /src

COPY Gemfile ./
RUN bundle install

COPY attributes/ attributes/
COPY files/ files/
COPY libraries/ libraries/
COPY recipes/ recipes/
COPY templates/ templates/

COPY Berksfile Berksfile.lock metadata.rb ./
