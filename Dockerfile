FROM jamespan/hexo-env:latest

MAINTAINER Pan Jiabang <panjiabang@gmail.com> 

# Copy blog source

COPY ./ /tmp/
WORKDIR /tmp/

# Generate site

RUN hexo generate \
    && rm -rf /usr/share/nginx/html \
    && mv /tmp/public /usr/share/nginx/html

EXPOSE 80

# Start Nginx and keep it from running background
CMD ["nginx", "-g", "daemon off;"]