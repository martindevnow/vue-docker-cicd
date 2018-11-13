FROM node:9.11.1 as devBuild
WORKDIR /tmp
COPY package*.json /tmp/
RUN CI=true npm install
WORKDIR /usr/src/app
COPY . /usr/src/app/
RUN cp -a /tmp/node_modules /usr/src/app/
ENV NODE_ENV=development
ENV PORT=8085
EXPOSE 8085
CMD [ "npm", "run", "serve" ]

# Take from existing build and run tests against it
FROM node:9.11.1 as testBuild
WORKDIR /usr/src/app
COPY --from=devBuild /usr/src/app .
CMD [ "npm", "run", "test:unit" ]

# Builder
FROM node:9.11.1 as builder
WORKDIR /usr/src/app
COPY --from=devBuild /usr/src/app .
RUN npm run build

# Make production build
FROM node:9.11.1 as prodBuild
RUN npm install -g http-server
WORKDIR /app
COPY --from=builder /usr/src/app/dist .
EXPOSE 80
CMD [ "http-server", "-p", "80", "/app" ]
