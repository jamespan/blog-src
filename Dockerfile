# Using a compact OS
FROM alpine:3.2

MAINTAINER Pan Jiabang <panjiabang@gmail.com> 

# Copy blog source

COPY ./ /tmp
WORKDIR /tmp/

# Install hexo and dependences
RUN apk update && apk add nginx nodejs python make g++ \
    && npm install hexo -g && npm install && hexo generate \
    && cp -a /tmp/public/* /usr/share/nginx/html \
    && rm -rf /tmp/* && apk del nodejs python make g++ && rm -rf /var/cache/apk/*

EXPOSE 80

# Start Nginx and keep it from running background
CMD ["nginx", "-g", "daemon off;"]