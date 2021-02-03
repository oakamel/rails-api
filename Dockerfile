FROM ruby:3.0.0
# RUN apt-get update -qq && apt-get install -y nodejs postgresql-client
RUN mkdir /app
WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN gem install bundler
RUN bundle install

COPY . .

EXPOSE 3000

ENTRYPOINT ["sh", "./config/docker/startup.sh"]