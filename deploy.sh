QUEUE_STACK_NAME="YourQueueStackName"
BUCKET_NAME="Your Bucket Name"

SourceQueueUrl=$(aws cloudformation describe-stacks --stack-name=${QUEUE_STACK_NAME} --query "Stacks[0].Outputs[?OutputKey=='SourceQueueUrl'].OutputValue" --out text)
TargetQueueUrl=$(aws cloudformation describe-stacks --stack-name=${QUEUE_STACK_NAME} --query "Stacks[0].Outputs[?OutputKey=='TargetQueueUrl'].OutputValue" --out text)


aws s3 mb s3://BUCKET_NAME

sam package  --template-file template.yaml  --output-template-file packaged.yaml --s3-bucket BUCKET_NAME

aws cloudformation deploy --template-file /Users/salnabulsi/projects/serverless-workshop/sam-nodejs/packaged.yaml --stack-name messages-mover  --capabilities CAPABILITY_IAM \
--parameter-overrides  SourceQueueUrl=${SourceQueueUrl} TargetQueueUrl=${TargetQueueUrl} Stage="dev"