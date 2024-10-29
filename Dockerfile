FROM ruby:3.3.5

RUN apt-get update -qq && apt-get install -y nodejs postgresql-client

ENV RAILS_ENV=development
ENV PORT=4000

WORKDIR /myapp

COPY Gemfile* ./
RUN bundle install

COPY . .

EXPOSE 4000

CMD ["bash", "-c", "rm -f /myapp/tmp/pids/server.pid && rails server -b 0.0.0.0"]
