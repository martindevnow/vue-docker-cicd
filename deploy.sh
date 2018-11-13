#!/bin/bash
set -e

DOCKER_IMAGE=$1
URL_SUBDOMAIN=$2
CONAINER_NAME="vue-docker-cicd-container"

# TODO: Work on deploy script