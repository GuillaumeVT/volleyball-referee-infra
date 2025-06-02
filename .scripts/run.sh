#!/bin/bash

host_infra_directory='C:\Users\guill\IdeaProjects\volleyball-referee-infra'

vbr_network='vbr_network'
vbr_network_subnet='192.168.51.0'
vbr_db_host='192.168.51.11'
vbr_db_port=27017
vbr_api_host='192.168.51.10'
vbr_api_port=8080

vbr_db_admin_user='vbr_admin'
vbr_db_admin_password='dfDr39bz4FPHETgMeuYKAQ7x2XchCkBRJavsNZq8GV6mwS5njt'
vbr_db='vbr_db' # must match mongo-init.js
vbr_db_user='vbr_user' # must match mongo-init.js
vbr_db_user_password='QnPTrGNcwHM9vyRKza732gWhCsJfVxLmFkBuqtYS64ebd5pXUj' # must match mongo-init.js

vbr_admin_user='admin'
vbr_admin_password='m@XCWZ8F1d'
vbr_jwt_key='RrLGUxdh6Bkgu74p3YmjKbAeT5zJZVCPcsaEnqftMDwSFvQHNy'

host_db_directory="${host_infra_directory}\.docker\mongodb"

vbr_api_container='vbr-api'
vbr_db_container='vbr-db'

if docker inspect -f 'Container exists and is running' "$vbr_api_container"; then
  docker stop "$vbr_api_container"
  docker container rm "$vbr_api_container"
fi

if docker inspect -f 'Container exists and is running' "$vbr_db_container"; then
  docker stop "$vbr_db_container"
  docker container rm "$vbr_db_container"
fi

docker network rm --force "$vbr_network"

docker network create --driver=bridge --subnet="$vbr_network_subnet"/24 "$vbr_network"

docker run --name "$vbr_db_container" \
  -e MONGO_INITDB_ROOT_USERNAME="$vbr_db_admin_user" \
  -e MONGO_INITDB_ROOT_PASSWORD="$vbr_db_admin_password" \
  -e MONGO_INITDB_DATABASE="$vbr_db" \
  -v "$host_db_directory"/data:/data/db \
  -v "$host_db_directory"/docker-entrypoint-initdb.d:/docker-entrypoint-initdb.d \
  --network "$vbr_network" \
  --ip "$vbr_db_host" \
  -p "$vbr_db_port":"$vbr_db_port" \
  --restart always \
  -d mongo:8.0.9

docker run --name "$vbr_api_container" \
  -e VBR_DB_HOST="$vbr_db_host" -e VBR_DB_PORT="$vbr_db_port" -e VBR_DB="$vbr_db" -e VBR_DB_USER="$vbr_db_user" -e VBR_DB_PASSWORD="$vbr_db_user_password" \
  -e VBR_ADMIN_USER="$vbr_admin_user" -e VBR_ADMIN_PASSWORD="$vbr_admin_password" \
  -e VBR_JWT_KEY=$vbr_jwt_key \
  --network "$vbr_network" \
  --ip "$vbr_api_host" \
  -p "$vbr_api_port":"$vbr_api_port" \
  --restart always \
  -d vbr-api
