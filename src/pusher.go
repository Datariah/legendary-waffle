package main

import (
	"context"
	"fmt"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	log "github.com/sirupsen/logrus"
	"github.com/slack-go/slack"
	"os"
	"strings"
)

func pusher(ctx context.Context, event events.SNSEvent) error {
	slackToken, isSlackTokenSet := os.LookupEnv("SLACK_BOT_TOKEN")
	if !isSlackTokenSet {
		log.Panic("SLACK_BOT_TOKEN is not set.")
	} else {
		if !strings.HasPrefix(slackToken, "xoxb-") {
			log.Panicf("SLACK_BOT_TOKEN must have the prefix \"xoxb-\".")
		}
	}

	channelId, isChannelIdSet := os.LookupEnv("SLACK_CHANNEL_ID")
	if !isChannelIdSet {
		log.Panic("SLACK_CHANNEL_ID is not set.")
	}

	api := slack.New(slackToken)

	for _, message := range event.Records {
		log.WithFields(log.Fields{
			"message_id": message.SNS.MessageID,
			"author":     message.SNS.MessageAttributes["Author"],
			"uuid":       message.SNS.MessageAttributes["Uuid"],
			"timestamp":  message.SNS.MessageAttributes["Timestamp"],
			"source":     message.EventSource,
		}).Infof("new quote from SNS: \"%s\"", message.SNS.Message)

		author := message.SNS.MessageAttributes["Author"].(map[string]interface{})["Value"]

		text := fmt.Sprintf("\"%s\" - %s", message.SNS.Message, author)

		_, timestamp, err := api.PostMessage(
			channelId,
			slack.MsgOptionText(text, false),
			slack.MsgOptionAsUser(true), // Add this if you want that the bot would post message as a user, otherwise it will send response using the default slackbot
		)

		if err != nil {
			log.Errorf("error sending message to slack: %v", err)
			return err
		}

		log.WithFields(log.Fields{"channel": channelId, "message_timestamp": timestamp}).Info("Message sent successfully to Slack")
	}

	return nil
}

func main() {
	lambda.Start(pusher)
}
