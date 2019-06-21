FROM alpine:3.6
MAINTAINER Earou Huang <earouhuang@gmail.com>

RUN apk update

# Install curl and jq
RUN apk add --no-cache curl && apk --no-cache add jq

# Install aws-cli
RUN apk -Uuv add groff less python py-pip
RUN pip install awscli
RUN apk --purge -v del py-pip
RUN rm /var/cache/apk/*

RUN mkdir /app
COPY *.sh /app/

WORKDIR /app

ENTRYPOINT ["/bin/sh", "-c"]
CMD ["./aws-svc-controller.sh"]
