/* This pipeline is not tested yet
   */
pipeline {
    agent none

    options {
        timestamps()
        disableConcurrentBuilds()
    }

    environment {
      AWS_DEFAULT_REGION='eu-west-1'
      QUEUE_STACK_NAME="sqs-stack
      LAMBDA_STACK_NAME="sqs-messages-mover-lambda"
      BUCKET_NAME="sqs-messages-mover-bucket"
    }

    stages {
        stage('Install Prerequisites') {
            agent {
                label 'deploy-s24-die'
            }
            steps {
                sh 'echo "Deploy the Source and Target Queues"'
                sh 'aws cloudformation deploy --template-file aws/sqs-stack.yaml --stack-name=$QUEUE_STACK_NAME --region=$AWS_DEFAULT_REGION'
                sh 'echo "Create S3 Bucket"'
                sh 'aws s3 mb s3://$BUCKET_NAME'
            }
        }

        stage('Package Lambda') {
            agent {
                label 'deploy-s24-die'
            }
            steps {
               sh 'pip install aws-sam-cli'
               sh 'sam package --template-file template.yaml --output-template-file packaged.yaml --s3-bucket $BUCKET_NAME'
            }
        }

        stage('Deploy Lambda') {
            agent {
                label 'deploy-s24-die'
            }

            environment {
                SourceQueueUrl = sh (script: "aws cloudformation describe-stacks --stack-name=$QUEUE_STACK_NAME --query \"Stacks[0].Outputs[?OutputKey=='SourceQueueUrl'].OutputValue\" --out text", returnStdout: true)
                TargetQueueUrl = sh (script: "aws cloudformation describe-stacks --stack-name=$QUEUE_STACK_NAME --query \"Stacks[0].Outputs[?OutputKey=='TargetQueueUrl'].OutputValue\" --out text", returnStdout: true)
            }

            steps {
                sh 'pip install aws-sam-cli'
                sh 'sam deploy \
                    	--template-file ./packaged.yaml \
                    	--stack-name $LAMBDA_STACK_NAME \
                    	--capabilities CAPABILITY_IAM \
                    	--parameter-overrides  SourceQueueUrl=$SourceQueueUrl TargetQueueUrl=$TargetQueueUrl'
            }
        }

        stage('Clean Created Stacks') {
            agent {
                label 'deploy-s24-die'
            }
            steps {
                //empty the s3 bucket
                //delete the s3 bucket
                //sh 'aws cloudformation delete --stack-name=$LAMBDA_STACK_NAME'
                //sh 'aws cloudformation delete --stack-name=$QUEUE_STACK_NAME'
            }
        }
    }

  /* post {
        success {
            slackSend channel: '#s24datainfra-dev',
                      color:   '#36a64f',
                      message: "Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' Deploy-Dev passed, ready for Deploy-Production, ${env.BUILD_URL}"
        }
        failure {
            slackSend channel: '#s24datainfra-dev',
                      color:   '#FF0000',
                      message: "Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' has failed, ${env.BUILD_URL}"
        }
    } */
}