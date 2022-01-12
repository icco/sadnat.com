FROM nginx

WORKDIR /usr/share/nginx/html
COPY ./public/* .

ENV PORT 8080
EXPOSE $PORT
