
docker run -di --name sqs-mock -p 9324:9324 -v "$PWD:/etc/elasticmq" s12v/elasticmq

while ! curl localhost:9324 &>/dev/null
        do echo "Curl Fail - `date`";sleep 5
done
echo "Docker is up and running!"

 curl 'http://localhost:9324/queue/source?Action=SendMessage&MessageBody={"action":"message_1"}' > /dev/null
 curl 'http://localhost:9324/queue/source?Action=SendMessage&MessageBody={"action":"message_2"}' > /dev/null

current_dir=$PWD

echo "INVOKING LAMBDA LOCALLY...."

cd ..
sam local generate-event schedule | sam local invoke

cd $current_dir;



echo "CLEANING UP...."

docker stop sqs-mock || true && docker rm sqs-mock || true
