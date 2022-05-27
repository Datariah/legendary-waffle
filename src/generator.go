package main

import (
	"context"
	"os"
	"time"

	"github.com/Datariah/legendary-waffle/internal"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/sqs"
	"github.com/aws/aws-sdk-go-v2/service/sqs/types"
	"github.com/google/uuid"
	log "github.com/sirupsen/logrus"

	"github.com/aws/aws-lambda-go/lambda"
)

func generator(ctx context.Context) error {
	region, isAwsRegionSet := os.LookupEnv("AWS_REGION")
	if !isAwsRegionSet {
		log.Warn("AWS_REGION is not set. Falling back to us-east-1")
		region = "us-east-1"
	}

	cfg, err := config.LoadDefaultConfig(ctx, config.WithRegion(region))
	if err != nil {
		log.Errorf("configuration error, " + err.Error())
		return err
	}

	client := sqs.NewFromConfig(cfg)

	// We get the Queue name
	queueName, isQueueNameSet := os.LookupEnv("SQS_QUEUE_NAME")
	if !isQueueNameSet {
		log.Panic("SQS_QUEUE_NAME is not set")
	}

	queueAccountId, isQueueAccountSet := os.LookupEnv("SQS_ACCOUNT_ID")
	if !isQueueAccountSet {
		log.Panic("SQS_ACCOUNT_ID is not set")
	}

	gQInput := &sqs.GetQueueUrlInput{
		QueueName:              aws.String(queueName),
		QueueOwnerAWSAccountId: aws.String(queueAccountId),
	}

	log.Info("Retrieving Queue URL for Queue ", *gQInput.QueueName)

	// With that, we get the Queue URL as we want it in the SendMessageInput struct
	result, err := client.GetQueueUrl(ctx, gQInput)
	if err != nil {
		log.Errorf("Got an error getting the queue URL: %v", err)
		return err
	}

	// We get a quote
	quote, err := internal.GetQuote()
	if err != nil {
		log.Errorf("error retrieving quote: %v", err)
		return err
	}

	// We generate the message
	sMInput := &sqs.SendMessageInput{
		DelaySeconds: 10,
		MessageAttributes: map[string]types.MessageAttributeValue{
			"UUID": {
				DataType:    aws.String("String"),
				StringValue: aws.String(uuid.New().String()),
			},
			"Timestamp": {
				DataType:    aws.String("String"),
				StringValue: aws.String(time.Now().Format(time.RFC3339)),
			},
			"Author": {
				DataType:    aws.String("String"),
				StringValue: aws.String(quote.Author),
			},
		},
		MessageBody: aws.String(quote.Content),
		QueueUrl:    result.QueueUrl,
	}

	resp, err := client.SendMessage(ctx, sMInput)
	if err != nil {
		log.Errorf("Got an error sending the message: %v", err)
		return err
	}

	log.Infof("Sent message with ID: %s", *resp.MessageId)

	return nil
}

func main() {
	lambda.Start(generator)
}
