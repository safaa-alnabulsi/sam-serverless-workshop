if [ $# -lt 1 ]; then
  echo 1>&2 "$0: not enough arguments"
  echo "Please provide the name of the stack as input parameter."
  exit 2
fi

aws cloudformation deploy --template-file sqs-stack.yaml --stack-name=$1 --region=eu-west-1 
