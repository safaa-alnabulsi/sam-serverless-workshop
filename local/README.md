Run `docker run -p 9324:9324 -v "$PWD:/etc/elasticmq" s12v/elasticmq` to start a local instance with a source and a target queue. The queues will be available at `localhost:9324/queue/source` 


To test a flow you can run `./start.sh`. This script will startup a docker container called `sqs-mock`. It will then populate the `source` queue in there with two messages. Finally it will stop and cleanup this container. This is of no use at the moment, but can later be used if we add a script that runs the `sam local invoke` command and then verifies that the messages have been moved.

