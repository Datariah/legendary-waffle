.PHONY: build clean deploy

build:
	env GOOS=linux GOARCH=amd64 go build -ldflags="-s -w" -o bin/generator src/generator.go
	env GOOS=linux GOARCH=amd64 go build -ldflags="-s -w" -o bin/receiver src/receiver.go
	env GOOS=linux GOARCH=amd64 go build -ldflags="-s -w" -o bin/gateway src/gateway.go
	env GOOS=linux GOARCH=amd64 go build -ldflags="-s -w" -o bin/pusher src/pusher.go

clean:
	rm -rf ./bin ./vendor Gopkg.lock

rebuild: clean build

format:
	gofmt -w src/generator.go
	gofmt -w src/receiver.go
	gofmt -w src/gateway.go
	gofmt -w src/pusher.go
