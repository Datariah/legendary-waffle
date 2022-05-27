package main

import (
	"context"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"

	log "github.com/sirupsen/logrus"
)

func handler(ctx context.Context, sqsEvent events.SQSEvent) error {
	for _, message := range sqsEvent.Records {
		log.WithFields(log.Fields{
			"message_id": message.MessageId,
			"author":     message.MessageAttributes["Author"].StringValue,
			"uuid":       message.MessageAttributes["Uuid"].StringValue,
			"timestamp":  message.MessageAttributes["Timestamp"].StringValue,
			"source":     message.EventSource,
		}).Infof("New quote arrived: \"%s\"", message.Body)
	}

	return nil
}

func main() {
	lambda.Start(handler)
}
