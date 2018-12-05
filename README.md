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

### Packaging/Productizing
I would like to convert much of the work done here into an NPM package that I can add to my projects. This would work by `npm install`ing this package into my app. The package, on postinstall, would add the .env file (or w/e method we use for setting these flags/variables), and import commands into the `scripts` property of the main `package.json`

### Deployment
- Have CircleCI `scp` the `deploy.sh` to the server configured in CircleCI during Deploy step
- Update `deploy.sh` to also confirm that the reverse proxy is also running. Currently this must be configured on a server before we can deploy to it (without port collisions, etc)

### Project "Variables"
- Where should all the project specific configuration/variables be stored?
    - Need to have them in one spot
    - Some things NEED to be somewhere specific (package.json has version and name)
    - Some are defined in the config.yml
- Developers shouldn't NEED their own `.env` file since it's all in docker
    - Could store everything in .env (have a LITTLE duplication between `package.json` and `.env`)
- There must be a better way to export the Environment Variables into CircleCI/npm commands
- 

### Versioning
- What are best practices for versioning Docker Images? 
    - Version #? + commit SHA? + Build #?
    - When to version? (only in CI?)
    - When to version bump?
- Script to version bump?
- How to access package.json's "version" from outside NPM commands

## Using The CICD Pipeline in Another Project

If you wish to use this CICD pipeline in another project, there are several files you will need to import to your project.

### Important Files

1. `.circleci/config.yml`
    - Be sure to update the Environment Variables that are set in the `setupenv` command
2. `cypress/*`
    - Update the `cypress.json` to specify any plugins you want
    - No update to `Dockerfile.cypress` required
    - No update `package.json` required
    - No update to `tsconfig.json` required
3. `docker-compose.yml`
This file is responsible for running e2e tests through Cypress. There are few fields you can update or add to this file.
    - `environment` if you want different folders/plugins/url, etc [These can also be provided at run time through the `npm` command found in the `package.json`]
    - `volumes` I decided to store the 
4. `Dockerfile`
    - You may need to modify the build step (if you have a different NPM command to build) any other ENV variables required
5. `Dockerfile.dev` 
    - You can update the `port` if you want and specify any other ENV variables required
6. `package.json`
You don't need to copy the whole file, of course. However, the majority of the docker commands are listed in here. Because I could not comment in the `*.json` file, I've added comments as commands.

### Package.json

#### Framework Specific
There are commands that you will need to change based on your framework. Under the comment `comment:vue-commands-inside-container` there are 5 commands. These are meant to be run within the Docker container. These will be specific to your Framework.

#### Local Development
The commands under the comment `comment:local-development` are meant to be used for local development. 

#### Building Production
The command under `comment:production` is the command to building the production ready image.

#### CI/CD Commands
The commands found under `comment:ci` run the unit tests in a Continuous Integration environment. This is run against the development build to leverage the `devDependencies` for running the tests. [**Note:** If you are running locally with `start:dev`, you can run your unit tests against your running container with `start:unit` to avoid rebuilding your `Dockerfile.dev` Docker image ]

#### End-to-End Testing
The commands found at `comment:e2e` are used in CI as well (but can be run locally too). These use the `docker-compose` to bring up the latest Production build of the app, and run Cypress against it. You should be sure to rebuild your production ready app before running Cypress against it if you have made any changes to your application (`build:prod`). (If your tests remain the same, you do NOT need to rebuild Cypress)

If you only made changes to the e2e tests, you only need to rebuild Cypress (`build:cypress`) before running again.


