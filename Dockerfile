FROM ubuntu:14.04

MAINTAINER Pan Jiabang <panjiabang@gmail.com> 

# Copy blog source

RUN \
  # use aliyun's mirror for faster download speed
  sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list && \
  apt-get update && \
  apt-get install -y nodejs curl git-core build-essential python && \
  # use nodejs as node 
  update-alternatives --install /usr/bin/node node /usr/bin/nodejs 10 && \
  # install npm
  curl -L https://npmjs.org/install.sh | sh && \
  # clean up install cache
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* 

RUN npm install hexo-cli -g

COPY ./ /tmp/
WORKDIR /tmp/

# Generate site

RUN npm install
RUN hexo generate

RUN mv /tmp/public /usr/share/nginx/html

EXPOSE 80

# Start Nginx and keep it from running background
CMD ["nginx", "-g", "daemon off;"]