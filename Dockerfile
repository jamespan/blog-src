FROM jamespan/blog-build-env:latest

MAINTAINER Pan Jiabang <panjiabang@gmail.com> 

# Copy blog source
COPY ./ /tmp/
WORKDIR /tmp/

# Generate site

RUN cp ./.docker/nginx.conf /etc/nginx/nginx.conf && \
    ln -sf /dev/stdout /var/log/nginx/access.log && ln -sf /dev/stderr /var/log/nginx/error.log

RUN hexo generate \
    && rm -rf /usr/share/nginx/html \
    && mv /tmp/public /usr/share/nginx/html

EXPOSE 80

# Start Nginx with dockerize
CMD ["nginx", "-g", "daemon off;"]
