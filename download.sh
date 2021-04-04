#!/usr/bin/env bash

#running docker compose
docker-compose -f docker-compose-elk.yml down

#Launch elk stack
docker-compose -f docker-compose-elk.yml up &

sleep 35

#Launch jenkins
docker-compose up &
