package main

import (
	"context"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/sns"
	"github.com/aws/aws-sdk-go-v2/service/sns/types"
	"os"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"

	log "github.com/sirupsen/logrus"
)

func gateway(ctx context.Context, sqsEvent events.SQSEvent) error {

	region, isAwsRegionSet := os.LookupEnv("AWS_REGION")
	if !isAwsRegionSet {
		log.Warn("AWS_REGION is not set. Falling back to us-east-1")
		region = "us-east-1"
	}

	snsTopic, isSnsTopicSet := os.LookupEnv("SNS_TOPIC_ARN")
	if !isSnsTopicSet {
		log.Panic("SNS_TOPIC_ARN is not set.")
	}

	cfg, err := config.LoadDefaultConfig(ctx, config.WithRegion(region))
	if err != nil {
		log.Errorf("configuration error, " + err.Error())
		return err
	}

	client := sns.NewFromConfig(cfg)

	for _, message := range sqsEvent.Records {
		log.WithFields(log.Fields{
			"message_id": message.MessageId,
			"author":     message.MessageAttributes["Author"].StringValue,
			"uuid":       message.MessageAttributes["Uuid"].StringValue,
			"timestamp":  message.MessageAttributes["Timestamp"].StringValue,
			"source":     message.EventSource,
		}).Infof("new quote arrived: \"%s\"", message.Body)

		attr := map[string]types.MessageAttributeValue{}

		for k, v := range message.MessageAttributes {
			attr[k] = types.MessageAttributeValue{
				StringValue: v.StringValue,
				DataType:    aws.String(v.DataType),
			}
		}

		input := sns.PublishInput{
			Message:           aws.String(message.Body),
			MessageAttributes: attr,
			TopicArn:          aws.String(snsTopic),
		}

		output, err := client.Publish(ctx, &input)
		if err != nil {
			log.Errorf("error while publishing message: %v", err)
			return err
		}

		log.Infof("forwarded SQS event to SNS via Message with ID %s", *output.MessageId)
	}

	return nil
}

func main() {
	lambda.Start(gateway)
}
