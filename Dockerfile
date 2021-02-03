FROM ruby:3.0.0
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
RUN mkdir /app
WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN gem install bundler
RUN bundle install

COPY . .

EXPOSE 3000