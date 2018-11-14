# Vue SPA with Docker CICD Pipeline

This project was done as a Proof of Concept to build a Continuous Integration and Continuous Deployment pipeline using a simple VueSPA developed and deployed within a Docker container and hooked up to CircleCI through GitHub.

## Project Requirements
This project requires Docker to run

### Local Development
For local development, `docker-compose` is used. The docker-compose yml verison used is `3.4` and so docker v17.09.0+ is required. [See here for more details](https://docs.docker.com/compose/compose-file/compose-versioning/).

## Compiles and hot-reloads for development
Once you have Docker installed, you can run the following command to build and run the project for local development.

```
docker-compose up [--build]
```

Use the `--build` flag if the dependencies have changed and need to be installed or updated.

### Running tests
Tests can be run from within the container. If you have a development container running, you can run the following commands to connect to it and run your tests.

```
docker ps                              # Keep track of the CONTAINER_ID of your development container
docker exec -it CONTAINER_ID /bin/bash # You are now in your development container
npm run test:unit                      # or
npm run test:e2e
```

Alternatively, you can just run `npm run docker:test` but this will likely run a build (leveraging caching) and take longer over all. The development container should have all the development dependencies required to run tests.

### Lints and fixes files
```
npm run lint
```

## Building for Production
This repository is hooked up to CircleCI. If you wish to configure the build process, it can be done so through the `.circleci/config.yml` file. Otherwise, you can test running in production container locally.

```
npm run docker:prod  # Builds the Docker Image
npm run prod         # Starts a Production Container
```

## Deployment
As stated above, updating the `.circleci/config.yml` will allow you to change servers being deployed to. Please keep in mind that the deployment script `deploy.sh` is not copied to the production server. This should be done in advance. CircleCI will throw an error if it does not exist.

## ToDos:

- See if CircleCI can `scp` the `deply.sh` to the server configured in CircleCI. This would eliminate another manual step.
- Update `deploy.sh` to also confirm that the reverse proxy is also running. Currently this must be configured on a server before we can deploy to it (without port collisions, etc)
- Look into running Cypress (e2e) tests as headless so that the GUI will close automatically upon successful completion and allow the CircleCI workflow to continue
- Change the CircleCI configuration to use workflows and filter based on branch. It should run different processes based on which branch is being processed.
- Consider other ways to run the tests within the container without requiring a separate staged build for this purpose.
  - Running `docker exec -it 80aeeeaa12d3 npm run test:unit` works, but need to either have a static container name (assuming the `CONTAINER_ID` can be substituted for the `CONTAINER_NAME`)
  - If not, need a way to get the container ID on the fly and run the command.
- Deploy Docker Container for Feature Branch without requiring pushing to Docker Hub (if possible?)
