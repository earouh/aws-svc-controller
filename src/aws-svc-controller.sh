#!/bin/sh

if [ "$KUBE_HOST" == "" ]; then
    export KUBE_HOST=kubernetes.default
fi

if [ "$TOKEN" == "" ]; then
    export TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
fi

if [ "$AWS_REGION" == "" ]; then
    export AWS_REGION=ap-northeast-1
fi

while true; do
    ./informer.sh
    ./sync-svc.sh
    ./sync-ec2-ep.sh
    sleep 10
done