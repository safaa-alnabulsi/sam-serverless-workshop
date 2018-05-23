echo 'Starting Docker ....'
docker run -di --name sqs-mock -p 9324:9324 -v "$PWD:/etc/elasticmq" s12v/elasticmq &>/dev/null
echo 'Waiting for Docker to start ....'
while ! curl localhost:9324 &>/dev/null
        do echo 'Curl Fail - `date`, Docker is still not up';sleep 5
done
echo 'Docker is up and running!'

echo '----------------------------------'

echo 'Creating messages in source queue'
curl 'http://isdeblnnm108.gs24.com:9324/queue/source?Action=SendMessage&MessageBody={"action":"message_1"}' > /dev/null
echo 'Creating messages in target queue'
curl 'http://isdeblnnm108.gs24.com:9324/queue/source?Action=SendMessage&MessageBody={"action":"message_2"}' > /dev/null

echo '----------------------------------'

current_dir=$PWD
echo 'INVOKING LAMBDA LOCALLY....'
cd ..
sam local generate-event schedule | sam local invoke
cd $current_dir;

echo '----------------------------------'

echo 'CLEANING UP....'
docker stop sqs-mock || true && docker rm sqs-mock || true
