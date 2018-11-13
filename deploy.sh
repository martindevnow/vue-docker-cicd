#!/bin/bash

# TODO: Confirm script, upload to prod server to test
# TODO: Setup webhook on PR merge (or try to see if CircleCI will run against merge.. and retain the old branch name.)
#       Ideally, use CCI to kill the container after successful merge.

set -e

# Check for arguments
if [[ $# -lt 2 ]] ; then
    echo '[ERROR] You must supply a Docker Image to pull and Subdomain to Deploy'
    exit 1
fi

DOCKER_IMAGE="martindevnow/${1}"
URL_SUBDOMAIN=$2

if [[ $URL_SUBDOMAIN == "master" ]] ; then
    URL_SUBDOMAIN="qa"
elif [[ $URL_SUBDOMAIN == "develop" ]] ; then
    URL_SUBDOMAIN="dev"
fi

CONTAINER_NAME="vue-docker-cicd-${URL_SUBDOMAIN}"

echo "========"
echo "Docker Image   = ${DOCKER_IMAGE}"
echo "URL Subdomain  = ${URL_SUBDOMAIN}"
echo "Container Name = ${CONTAINER_NAME}"
echo "========"

echo "Stopping Existing Container with Same Name (If Applicable)"
#Check for running container & stop it before starting a new one
if [[ $(docker inspect -f '{{.State.Running}}' ${CONTAINER_NAME}) == "true" ]] ; then
    echo "... Stopping"
    docker stop ${CONTAINER_NAME}
else echo "... container not running"
fi

echo "Starting Vue Docker CICD Project using Docker Image name: $DOCKER_IMAGE"
docker run -e VIRTUAL_HOST=${URL_SUBDOMAIN}.martindevnow.com -d --rm=true --name ${CONTAINER_NAME} ${DOCKER_IMAGE}

docker ps -a
