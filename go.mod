module github.com/Datariah/legendary-waffle

go 1.18

require (
	github.com/Datariah/legendary-waffle/internal v0.0.0-00010101000000-000000000000
	github.com/aws/aws-lambda-go v1.22.0
	github.com/aws/aws-sdk-go-v2 v1.16.4
	github.com/aws/aws-sdk-go-v2/config v1.13.1
	github.com/aws/aws-sdk-go-v2/service/sns v1.15.0
	github.com/aws/aws-sdk-go-v2/service/sqs v1.18.5
	github.com/google/uuid v1.3.0
	github.com/sirupsen/logrus v1.8.1
	github.com/slack-go/slack v0.10.3
)

require (
	github.com/aws/aws-sdk-go-v2/credentials v1.8.0 // indirect
	github.com/aws/aws-sdk-go-v2/feature/ec2/imds v1.10.0 // indirect
	github.com/aws/aws-sdk-go-v2/internal/configsources v1.1.11 // indirect
	github.com/aws/aws-sdk-go-v2/internal/endpoints/v2 v2.4.5 // indirect
	github.com/aws/aws-sdk-go-v2/internal/ini v1.3.5 // indirect
	github.com/aws/aws-sdk-go-v2/service/internal/presigned-url v1.7.0 // indirect
	github.com/aws/aws-sdk-go-v2/service/sso v1.9.0 // indirect
	github.com/aws/aws-sdk-go-v2/service/sts v1.14.0 // indirect
	github.com/aws/smithy-go v1.11.2 // indirect
	github.com/gorilla/websocket v1.4.2 // indirect
	golang.org/x/sys v0.0.0-20220520151302-bc2c85ada10a // indirect
)

replace github.com/Datariah/legendary-waffle/internal => ./src/internal
