# Using a compact OS
FROM alpine:3.2

MAINTAINER Pan Jiabang <panjiabang@gmail.com> 

# Install Nginx and Node.js env
RUN apk --update add nginx
RUN apk --update add --virtual build-dependencies nodejs python make g++

# Copy blog source

COPY ./ /tmp
WORKDIR /tmp/

# Install hexo and dependences

RUN npm install hexo -g
RUN npm install
RUN hexo generate

RUN cp -a /tmp/public/* /usr/share/nginx/html

# Clean up

RUN rm -rf ./*
RUN apk del build-dependencies
RUN rm -rf /var/cache/apk/*

EXPOSE 80

# Start Nginx and keep it from running background
CMD ["nginx", "-g", "daemon off;"]