FROM jamespan/hexo-env:latest

MAINTAINER Pan Jiabang <panjiabang@gmail.com> 

# Copy blog source

RUN apk --update add bash
RUN wget https://github.com/jwilder/dockerize/releases/download/v0.0.4/dockerize-linux-amd64-v0.0.4.tar.gz
RUN tar -C /usr/local/bin -xzvf dockerize-linux-amd64-v0.0.4.tar.gz
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

COPY ./ /tmp/
WORKDIR /tmp/

# Generate site

RUN hexo generate \
    && rm -rf /usr/share/nginx/html \
    && mv /tmp/public /usr/share/nginx/html

EXPOSE 80

# Start Nginx and keep it from running background
CMD dockerize -stdout /var/log/nginx/access.log -stderr /var/log/nginx/error.log nginx