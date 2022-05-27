# legendary-waffle

This project implements a simple quote generator that will end up sending messages to Slack.

```
├── Makefile
├── README.md
├── bin
├── cloudwatch.tf
├── datasources.tf
├── go.mod
├── go.sum
├── iam.tf
├── lambda.tf
├── locals.tf
├── providers.tf
├── s3.tf
├── sns.tf
├── sqs.tf
├── src
│   ├── gateway.go
│   ├── generator.go
│   ├── internal
│   │   ├── go.mod
│   │   ├── go.sum
│   │   └── quotes.go
│   ├── pusher.go
│   ├── receiver.go
│   └── test.go
└── terraform.tf
```

## Requirements
In order for this project to work, you need:
- Golang 1.18 (check go.mod)
- Terraform 1.0 or higher is recommended, with aws provider >= 4.0.0
- AWS Access Key/Secret or other authentication method (SSO, Web Identity, etc). Normally a properly
setup profile should be enough.
- Slack Bot Token, you can create this by creating an app in your workspace and setting scopes in such
application (you can always sign up for a free workspace to try things out).

## How to use

To build binaries, you can rely on the Makefile:

```shell
make rebuild
```

**Note**: These binaries are cross compiling to linux, so they might not run in your machine!

Once the binaries are compiled, you can apply the terraform code:

```shell
terraform apply
```

Which will create all the AWS resources:
- Lambda functions
- IAM Policies/Roles
- SNS Topic and Lambda suscription.
- SQS Queues and Lambda event source.
- Cloudwatch Log Groups

## Components

The solution is composed of three different lambdas that have different responsabilities:

1. **Generator**: responsible for querying the Quotable API and generating the SQS events.
2. **Gateway**: responsible for receiving SQS events and translating them into SNS.
3. **Pusher**: responsible for receiving SNS messages and pushing the messages to Slack.
