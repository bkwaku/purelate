FROM --platform=linux/amd64 node:16

# create an app directory and use it as working directory
RUN mkdir -p /tasks
WORKDIR /tasks

# setting up directory for node_modules to bin path so that containers folder can be used
ENV PATH /tasks/node_modules/.bin:$PATH

COPY package.json /tasks/package.json
COPY package.json /tmp/package.json
RUN npm config set unsafe-perm true
RUN cd /tmp && npm install

RUN npm install pm2@6.0.5 -g
RUN npm install db-migrate -g
RUN npm install cross-env -g

COPY . /tasks
RUN cp -a /tmp/node_modules /tasks/node_modules

# Set production environment
ENV NODE_ENV=production

# allow ports to be publicly available
EXPOSE 9210 9211 9212

# run command - use production pm2 config
CMD pm2 start pm2-prod.json && tail -f /dev/null
