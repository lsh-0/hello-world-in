FROM golang:alpine
WORKDIR /tmp/hello-world-go
ENTRYPOINT ["go", "run", ".", "--port", "80"]
