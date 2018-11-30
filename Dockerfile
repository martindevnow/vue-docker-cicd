# Builder
FROM node:9.11.1 as builder
ENV NODE_ENV=production
COPY package*.json /tmp/
RUN cd /tmp && CI=true npm install

WORKDIR /usr/src/app
COPY . /usr/src/app/
RUN cp -a /tmp/node_modules /usr/src/app/
RUN npm run build

# Make production build
FROM node:9.11.1 as prodBuild
RUN npm install -g http-server
WORKDIR /app
COPY --from=builder /usr/src/app/dist .
EXPOSE 80
CMD [ "http-server", "-p", "80", "/app" ]
