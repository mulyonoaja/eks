FROM golang:latest AS builder
ADD . /app
WORKDIR /app
RUN go get -u github.com/etherlabsio/healthcheck
RUN go get -u github.com/etherlabsio/healthcheck/checkers
RUN go get -u github.com/gorilla/mux
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build \
  -o /webapp .

FROM alpine:latest
RUN apk --no-cache add ca-certificates
COPY --from=builder /webapp ./
RUN chmod +x ./webapp
ENTRYPOINT [ "./webapp" ]
EXPOSE 8000
