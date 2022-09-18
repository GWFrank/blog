FROM ruby:3.0

# Set default locale for the environment
ENV LC_ALL C.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

WORKDIR /srv/jekyll

COPY Gemfile Gemfile.lock ./
RUN bundle install

EXPOSE 4000

CMD ["bundle", "exec", "jekyll", "help"]
