FROM ruby:2.3.3

RUN apt-get update -qq && \
    apt-get install -y build-essential libpq-dev nodejs && \
    mkdir -p /myapp

COPY ./ /myapp

WORKDIR /myapp