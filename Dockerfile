FROM jamespan/hexo-env:latest

MAINTAINER Pan Jiabang <panjiabang@gmail.com> 

# Copy blog source

RUN apk --update add bash
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

COPY ./ /tmp/
WORKDIR /tmp/

# Generate site

RUN cp /tmp/source/asset/bin/* /usr/local/bin/

RUN hexo generate \
    && rm -rf /usr/share/nginx/html \
    && mv /tmp/public /usr/share/nginx/html

EXPOSE 80

# Start Nginx and keep it from running background
CMD dockerize -stdout /var/log/nginx/access.log -stderr /var/log/nginx/error.log nginx