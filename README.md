# Vue SPA with Docker CICD Pipeline

This project was done as a Proof of Concept to build a Continuous Integration and Continuous Deployment pipeline using a simple VueSPA developed and deployed within a Docker container and hooked up to CircleCI through GitHub.

## Project Requirements

This project requires Docker to run

### Local Development

For local development, `docker-compose` is used. The docker-compose yml verison used is `3.4` and so docker v17.09.0+ is required. [See here for more details](https://docs.docker.com/compose/compose-file/compose-versioning/).

## Compile and hot-reloads for development

Once you have Docker installed, you can run the following command to build and run the project for local development. 

The first time you pull the repo, you will need to build the dependencies. This is done with the following command

```
npm run build:dev
```

This will ensure your local environment (Docker Image) has the latest NPM dependencies. Once that is done, you can run the dev server with the following command:

```
npm run start:dev
```

### Running tests

Tests can be run from within the container. 

First, ensure your development server is running. These tests will be run against it.

```
# npm run start:dev  ## (if you havent already)
npm run start:unit
```

### Lints and fixes files

The following command is NOT currently running in Docker, but you can easily lint your files with this command:

```
npm run lint
```

## Building for Production

This repository is hooked up to CircleCI. If you wish to configure the build process, it can be done so through the `.circleci/config.yml` file. Otherwise, you can test running in production container locally.

```
npm run build:prod      # Builds the Docker Image
```

## Deployment

As stated above, updating the `.circleci/config.yml` will allow you to change servers being deployed to. Please keep in mind that the deployment script `deploy.sh` is not copied to the production server. This should be done in advance. CircleCI will throw an error if it does not exist.

## Additional Configuration

1. [Docker Hub](https://circleci.com/blog/build-cicd-piplines-using-docker/)
    1. Register @ Docker Hub
    2. Add the username and password to CircleCI Dashboard (to expose them as environment variables for your CI commands)
2. Deployment
    1. Get SSH access to the server to deploy to
    2. Generate SSH key for this server
    3. Add SSH key to CircleCI Dashboard
    4. Move `./deploy.sh` to the server
3. [Branch Protection](https://circleci.com/docs/2.0/workflows-waiting-status/)
    1. Set your `develop` and `master` branches to require passing CircleCI tests before merging is allowed.

## ToDos:

### General

- See if CircleCI can `scp` the `deploy.sh` to the server configured in CircleCI. This would eliminate another manual step.
- Update `deploy.sh` to also confirm that the reverse proxy is also running. Currently this must be configured on a server before we can deploy to it (without port collisions, etc)
- ~~Look into running Cypress (e2e) tests as headless so that the GUI will close automatically upon successful completion and allow the CircleCI workflow to continue~~
- ~~Change the CircleCI configuration to use workflows and filter based on branch. It should run different processes based on which branch is being processed.~~
- ~~Consider other ways to run the tests within the container without requiring a separate staged build for this purpose.~~
  - ~~Running `docker exec -it 80aeeeaa12d3 npm run test:unit` works, but need to either have a static container name (assuming the `CONTAINER_ID` can be substituted for the `CONTAINER_NAME`)~~
  - ~~If not, need a way to get the container ID on the fly and run the command.~~
- Deploy Docker Container for Feature Branch without requiring pushing to Docker Hub (if possible?)

### e2e

End to End tests are running in CI on Docker properly. There are only a few issues...

1. ~~Need to get the exit code of the test runner~~
2. ~~Want to capture the headless output / test results~~
3. ~~Need to persist the above (results, screenshots, and video)~~
4. ~~Need to clean up the above, move it to it's proper home~~
5. ~~Stop the Docker-Compose network and attached containers~~
6. Notify people tests are done
7. ~~Exit based on the test results~~

- ~~The exit code of the headless tests needs to be piped or passed to the next script (the cleanup script)~~