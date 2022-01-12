FROM nginx:latest

ENV PORT 8080
EXPOSE $PORT

WORKDIR /usr/share/nginx/html
COPY ./public/* .
COPY default.conf /etc/nginx/templates/default.conf.template
