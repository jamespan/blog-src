FROM alpine:3.2

MAINTAINER Pan Jiabang <panjiabang@gmail.com> 

COPY ./package.json /tmp/
WORKDIR /tmp/

# Install Nginx and Node.js env
RUN apk update && \
    apk add nginx && \
    apk add nodejs python make g++ && \
    npm install hexo -g && \
    npm install && \
    rm -rf /var/cache/apk/*

# Copy blog source

COPY ./ /tmp

RUN hexo generate && \
    cp -a /tmp/public/* /usr/share/nginx/html && \
    rm -rf ./* && \
    apk del nodejs python make g++

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
