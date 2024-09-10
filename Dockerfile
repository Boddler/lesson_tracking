FROM ruby:3.1.2

RUN apt-get update -qq && apt-get install -y nodejs postgresql-client

ENV RAILS_ENV=development
ENV PORT=4000

WORKDIR /myapp

COPY Gemfile* ./
RUN bundle install

COPY . .

EXPOSE 4000

CMD ["rails", "server", "-b", "0.0.0.0"]
