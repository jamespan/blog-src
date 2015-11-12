# Using a compact OS
FROM alpine:3.2

MAINTAINER Pan Jiabang <panjiabang@gmail.com> 

# Install Nginx and Node.js env
RUN apk update
RUN apk add nginx
RUN apk add nodejs python make g++

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
RUN hexo clean
RUN apk del nodejs python make g++
RUN rm -rf /var/cache/apk/*

EXPOSE 80

# Start Nginx and keep it from running background
CMD ["nginx", "-g", "daemon off;"]