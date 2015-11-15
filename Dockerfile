FROM jamespan/hexo-env:latest

MAINTAINER Pan Jiabang <panjiabang@gmail.com> 

RUN apk --update add bash

# Copy blog source
COPY ./ /tmp/
WORKDIR /tmp/

# Generate site

RUN cp ./source/asset/bin/* /usr/local/bin/
RUN cp ./.docker/nginx.conf /etc/nginx/nginx.conf

RUN hexo generate \
    && rm -rf /usr/share/nginx/html \
    && mv /tmp/public /usr/share/nginx/html

EXPOSE 80

# Start Nginx with dockerize
CMD ["dockerize", "-stdout", "/var/log/nginx/access.log", "-stderr", "/var/log/nginx/error.log", "nginx"]
