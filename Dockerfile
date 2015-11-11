# Using a compact OS
FROM alpine:latest

MAINTAINER Pan Jiabang <panjiabang@gmail.com> 

# Install Nginx
RUN apk --update add nginx
RUN apk --update add nodejs

#RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.29.0/install.sh | bash
#RUN nvm install 5.0

# Add 2048 stuff into Nginx server

RUN npm --registry=https://registry.npm.taobao.org install hexo -g

COPY ./ /tmp
WORKDIR /tmp/blog.jamespan.me/

RUN npm --registry=https://registry.npm.taobao.org install
RUN hexo clean
RUN hexo generate

COPY ./public /usr/share/nginx/html

EXPOSE 80

# Start Nginx and keep it from running background
CMD ["nginx", "-g", "daemon off;"]