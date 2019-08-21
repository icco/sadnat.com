FROM ruby:2.6.3-slim

WORKDIR /opt
COPY . .

ENV PORT 8080
ENV RACK_ENV production

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

RUN for i in $(seq 1 8); do mkdir -p "/usr/share/man/man$i"; done

RUN apt-get update; \
      apt-get install -y --no-install-recommends \
       build-essential \
      dpkg-dev \
      libgdbm-dev \
      libpq-dev \
      postgresql-client \
      ; rm -rf /var/lib/apt/lists/*;

RUN bundle install --system --without=test development

CMD bundle exec thin -R config.ru start -p $PORT
EXPOSE 8080
