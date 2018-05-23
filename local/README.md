## local development

For having the two queues locally we used [ElasticMQ](https://github.com/adamw/elasticmq)

To test a flow you can run `./start.sh`, this script does the following:


 1. creates a docker netwrok
 2. startups a docker container called `sqs-mock`. The queues will be available at `localhost:9324/queue/source` and `localhost:9324/queue/target`  
 3. populate the `source` queue in there with two messages.
 4. invokes the lambda locally
 5. tests the messages that have been moved from source queue to target queue.
 6. Finally it stops and cleanup this container.

