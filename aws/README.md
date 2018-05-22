
deploy your account:
aws cloudformation deploy --template-file sqs-stack.yaml --stack-name=yourstackname --region=eu-west-1 

aws cloudformation describe-stacks --stack-name=safaa-queues --query "Stacks[0].Outputs"
