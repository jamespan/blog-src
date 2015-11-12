# Using a compact OS
FROM alpine:latest

MAINTAINER Pan Jiabang <panjiabang@gmail.com> 

# Install Nginx
RUN apk update
RUN apk add nginx
RUN apk add nodejs python make g++

# Add 2048 stuff into Nginx server

RUN npm install hexo -g

COPY ./ /tmp
WORKDIR /tmp/

RUN npm install
RUN hexo generate

RUN cp -a /tmp/public/* /usr/share/nginx/html
RUN rm -rf ./*
RUN hexo clean
RUN apk del nodejs python make g++
RUN rm -rf /var/cache/apk/*

EXPOSE 80

# Start Nginx and keep it from running background
CMD ["nginx", "-g", "daemon off;"]