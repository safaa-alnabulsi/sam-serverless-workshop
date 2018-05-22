const axios = require('axios')
const url = 'http://checkip.amazonaws.com/';
let response;
var AWS_REGION = "eu-west-1"
var SOURCE_QUEUE_URL = "First Queue URL"
var TARGET_QUEUE_URL = "Second Queue URL"

// Load the AWS SDK for Node.js
var AWS = require('aws-sdk');
// Set the region
AWS.config.update({region: 'eu-west-1'});

// Create an SQS service object
var sqs = new AWS.SQS({apiVersion: '2012-11-05'});

function sayHello(message, callback) {
    try {
        response = {
            'statusCode': 200,
            'body': JSON.stringify({
                message: message
            })
        }
    }
    catch (err) {
        console.log(err);
        callback(err, null);
    }

    callback(null, response)
}

function receiveMessage(srcQueueURL, callback) {
    var params = {
        MaxNumberOfMessages: 10,
        QueueUrl: srcQueueURL,
    };
    sqs.receiveMessage(params, callback);
}

function sendMessage(queueUrl, message, callback) {
    var params = {
        DelaySeconds: 10,
        MessageBody: message.Body,
        QueueUrl: queueUrl
    };
    sqs.sendMessage(params, callback);
}

function deleteMessage(message, queueUrl) {
    var params = {
        QueueUrl: queueUrl,
        ReceiptHandle: message.ReceiptHandle
    };

    sqs.deleteMessage(params, function (err, data) {
        if (err) {
            console.log("Delete Error", err);
        } else {
            console.log("Message Deleted", data);
        }
    });
}

function moveMessages(srcQueueURL, targetQueueURL) {
    console.log('Moving messages');
    receiveMessage(srcQueueURL, function (err, data) {
        if (err) {
            console.log("Receive Error", err);
        } else if (data.Messages) {
            console.log(`Received ${data.Messages.size} messages`);

            data.Messages.forEach(function(message) {
                console.log("Sending message:", message);
                sendMessage(targetQueueURL, message, function (err, data) {
                    if (err) {
                        console.log("Error", err);
                    } else {
                        console.log("Success", data.MessageId);
                        deleteMessage(message, srcQueueURL);
                     }
               })
            });
         }
    });
}

exports.lambda_handler = async(event, context, callback) => {
    sayHello('Hi tesssst', callback);
    moveMessages(SOURCE_QUEUE_URL, TARGET_QUEUE_URL)
};
