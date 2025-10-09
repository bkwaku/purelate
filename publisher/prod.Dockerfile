FROM node:11.12.0-alpine

# create an app directory and use it as working directory
RUN mkdir -p /publisher
WORKDIR /publisher

# setting up directory for node_modules to bin path so that containers folder can be used
ENV PATH /publisher/node_modules/.bin:$PATH

COPY package.json /publisher/package.json
# COPY package-lock.json /publisher/package-lock.json

RUN apk add --no-cache --virtual .gyp

RUN apk add --no-cache --virtual python

RUN apk add --no-cache --virtual make

RUN apk add --no-cache --virtual g++

RUN apk add --no-cache autoconf automake

RUN apk add --no-cache nasm pkgconfig libtool build-base zlib-dev

RUN npm config set unsafe-perm true
RUN npm install        

RUN npm install pm2@6.0.5 -g

RUN npm install cross-env@latest -g

COPY . /publisher

RUN export NODE_OPTIONS="--max-old-space-size=8192"

# allow port 2000 to be publicly available
ENV NODE_ENV=production
EXPOSE 2000

# run command
CMD pm2 start pm2_prod.json && tail -f /dev/null
