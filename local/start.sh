
docker run -di --name docker -p 9324:9324 -v "$PWD:/etc/elasticmq" s12v/elasticmq

while ! curl localhost:9324 &>/dev/null
        do echo "Curl Fail - `date`";sleep 5
done
echo "Docker is up and running!"


docker stop docker
