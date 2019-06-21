#!/bin/sh

curl --insecure -s -H "Authorization: Bearer ${TOKEN}" https://${KUBE_HOST}/apis/earou.io/v1/awsservices \
    | jq -r '.items[] | "\(.metadata.namespace)\t\(.metadata.uid)\t\(.metadata.name)\t\(.spec.port)\t\(.spec.targetPort)\t\(.spec.selector.awsTagName)\t\(.spec.selector.awsTagValue)" ' \
    > work-queue.csv
