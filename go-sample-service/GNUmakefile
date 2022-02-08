GOCMD=go
TEST?=$$(go list ./... |grep -v 'vendor')
BINARY=go-sample-service

default: build test

build:
	${GOCMD} build -o ${BINARY}

test:
	echo $(TEST) | \
		xargs -t ${GOCMD} test -v

clean:
	${GOCMD} clean

.PHONY: test clean
