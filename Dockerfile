FROM ruby:2.5.5

WORKDIR /opt
COPY . .

ENV PORT 8080
ENV RACK_ENV production
ENV LANG en_US.UTF-8

RUN bundle install --system --without=test development

CMD bundle exec thin -R config.ru start -p $PORT
EXPOSE 8080
