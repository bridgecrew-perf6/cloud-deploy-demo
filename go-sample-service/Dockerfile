FROM golang:1.17-buster as builder

WORKDIR /app
COPY *.go go.* GNUmakefile ./
RUN make

FROM debian:buster-slim

WORKDIR /

COPY --from=builder /app/go-sample-service ./
EXPOSE 8080

CMD ["/go-sample-service"]