#!/usr/bin/env bash

set -euo pipefail

ROOT=$(git rev-parse --show-toplevel)
SHA=$(git rev-parse HEAD)

DOCKER_REPO="stacktracehq/learn-data-science"
DOCKER_COMPOSE_FILE="docker-compose.yml"
CPU_DOCKERFILE=Dockerfile
GPU_DOCKERFILE=Dockerfile.gpu

touch $DOCKER_COMPOSE_FILE $GPU_DOCKERFILE
trap 'rm $DOCKER_COMPOSE_FILE $GPU_DOCKERFILE' EXIT

### Create common docker-compose.yml start
(cat <<YAML
version: '2.3'
services:
  notebook:
YAML
) > $DOCKER_COMPOSE_FILE

if [[ $(uname) == "Darwin" ]]
then

IMAGENAME=$DOCKER_REPO:cpu-$SHA

### CPU-specific docker-compose.yml
(cat <<CPU
    image: $IMAGENAME
    build:
      context: .
      dockerfile: Dockerfile
    container_name: learn-data-science
CPU
) >> $DOCKER_COMPOSE_FILE

fi

if [[ $(uname) == "Linux" ]]
then

IMAGENAME=$DOCKER_REPO:gpu-$SHA
FROM_LINE="FROM stacktracehq/learn-data-science:minimal-notebook-gpu"

echo $FROM_LINE > $GPU_DOCKERFILE
tail -n +2 $CPU_DOCKERFILE >> $GPU_DOCKERFILE

### CPU-specific docker-compose.yml
(cat <<GPU
    image: $IMAGENAME
    build:
      context: .
      dockerfile: Dockerfile.gpu
    container_name: learn-data-science
    runtime: nvidia
GPU
) >> $DOCKER_COMPOSE_FILE

fi

### End docker-compose.yml
(cat <<YAML
    environment:
      - JUPYTER_ENABLE_LAB=yes
    ports:
      - '8888:8888'
    restart: unless-stopped
    volumes:
      - './notebooks:/home/jovyan'
YAML
) >> $DOCKER_COMPOSE_FILE

mkdir -p notebooks
docker-compose build
docker-compose up
