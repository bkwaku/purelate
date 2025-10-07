FROM --platform=linux/amd64 node:16

# create an app directory and use it as working directory
RUN mkdir -p /publisher
WORKDIR /publisher

# setting up directory for node_modules to bin path so that containers folder can be used
ENV PATH /publisher/node_modules/.bin:$PATH

COPY package.json /publisher/package.json
COPY package.json /tmp/package.json
RUN npm config set unsafe-perm true
RUN cd /tmp && npm install

RUN npm install pm2@6.0.5 -g
RUN npm install cross-env@latest -g

COPY . /publisher
RUN cp -a /tmp/node_modules /publisher/node_modules

# Set production environment
ENV NODE_ENV=production
RUN export NODE_OPTIONS="--max-old-space-size=8192"

# allow port 9222 to be publicly available
EXPOSE 9222

# run command
CMD pm2 start pm2-prod.json && tail -f /dev/null

