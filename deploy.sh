if [ $# -lt 3 ]; then
  echo 1>&2 "$0: not enough arguments"
  echo "Please provide the name of your queue stack and the name of your bucket like this:."
  echo "./deploy.sh my-sqs-stack my-lambda-stack my-bucket-name"
  exit 2
fi

QUEUE_STACK_NAME=$1
LAMBDA_STACK_NAME=$2
BUCKET_NAME=$3

cd aws
./deploy-queues.sh ${QUEUE_STACK_NAME}
cd ..

SourceQueueUrl=$(aws cloudformation describe-stacks --stack-name=${QUEUE_STACK_NAME} --query "Stacks[0].Outputs[?OutputKey=='SourceQueueUrl'].OutputValue" --out text)
TargetQueueUrl=$(aws cloudformation describe-stacks --stack-name=${QUEUE_STACK_NAME} --query "Stacks[0].Outputs[?OutputKey=='TargetQueueUrl'].OutputValue" --out text)

sam package  --template-file ./template.yaml --output-template-file packaged.yaml --s3-bucket ${BUCKET_NAME}

sam package \
	--template-file template.yaml \
	--output-template-file packaged.yaml \
	--s3-bucket ${BUCKET_NAME}

sam deploy \
	--template-file ./packaged.yaml \
	--stack-name ${LAMBDA_STACK_NAME} \
	--capabilities CAPABILITY_IAM \
	--parameter-overrides  SourceQueueUrl="${SourceQueueUrl}" TargetQueueUrl="${TargetQueueUrl}"
