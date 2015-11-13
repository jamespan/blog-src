#  # Using a compact OS
#  FROM alpine:3.2
#  
#  MAINTAINER Pan Jiabang <panjiabang@gmail.com> 
#  
#  # Install Nginx and Node.js env
#  RUN apk update
#  RUN apk add nginx
#  RUN apk add nodejs python make g++ && rm -rf /var/cache/apk/*
#  
#  COPY ./package.json /tmp/
#  WORKDIR /tmp/
#  
#  # Install hexo and dependences
#  
#  RUN npm install hexo -g 
#  RUN npm install && npm cache clean
#  
#  CMD ["sh"]

# Using a compact OS
FROM jamespan/hexo-env:latest

MAINTAINER Pan Jiabang <panjiabang@gmail.com> 

# Copy blog source

COPY ./ /tmp/
WORKDIR /tmp/

# Install hexo and dependences

RUN hexo generate

RUN rm -rf /usr/share/nginx/html && mv /tmp/public /usr/share/nginx/html

EXPOSE 80

# Start Nginx and keep it from running background
CMD ["nginx", "-g", "daemon off;"]