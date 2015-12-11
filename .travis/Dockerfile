FROM alpine:3.2

MAINTAINER Pan Jiabang <panjiabang@gmail.com> 

# Install Nginx

RUN apk add --update nginx && \
    rm -rf /var/cache/apk/* && ln -sf /dev/stdout /var/log/nginx/access.log && ln -sf /dev/stderr /var/log/nginx/error.log

# Copy blog content

COPY ./public /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
