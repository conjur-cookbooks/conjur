FROM ruby:2.0
MAINTAINER Conjur, Inc

WORKDIR /src

COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install

COPY . ./
