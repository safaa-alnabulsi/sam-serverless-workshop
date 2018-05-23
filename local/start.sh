#!/usr/bin/env bash

echo 'Starting Docker ....'
docker network prune -f
docker network create message-mover

docker run --restart always -di --name sqs-mock --network message-mover -p 9324:9324 -v "$PWD:/etc/elasticmq" s12v/elasticmq

echo 'Waiting for Docker to start ....'
while ! curl localhost:9324 &>/dev/null
        do echo "Curl Fail - `date`";sleep 5
done
echo "Docker is up and running!"

echo 'Creating messages in source queue'
curl 'http://localhost:9324/queue/source?Action=SendMessage&MessageBody={"action":"message_1"}' > /dev/null
echo 'Creating messages in target queue'
curl 'http://localhost:9324/queue/source?Action=SendMessage&MessageBody={"action":"message_2"}' > /dev/null

current_dir=$PWD
echo 'INVOKING LAMBDA LOCALLY....'
cd ..
sam local generate-event schedule | sam local invoke --docker-network message-mover

cd $current_dir;

echo '----------------------------------'
echo "CLEANING UP...."

docker stop sqs-mock || true && docker rm sqs-mock || true
docker network rm message-mover > /dev/null