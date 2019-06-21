#!/bin/sh

compose_req_body() {
    var_ns=$1
    var_svc=$2
    var_uid=$3
    var_port=$4
    var_tport=$5
    
    echo "{\"apiVersion\":\"v1\",\"kind\":\"Service\",\"metadata\":{\"name\":\"$var_svc\",\"namespace\":\"$var_ns\",\"ownerReferences\":[{\"apiVersion\":\"apps/v1\",\"kind\":\"AWSService\",\"name\":\"$var_svc\",\"uid\":\"$var_uid\"}]},\"spec\":{\"ports\":[{\"port\":$var_port,\"protocol\":\"TCP\",\"targetPort\":$var_tport}]}}"
}

main() {
    cat work-queue.csv | while read ns uid svcname port tport tname tval; do
        # curl --cacert $CA_FILE
        http_code=$(curl --insecure -s -H "Authorization: Bearer ${TOKEN}" https://${KUBE_HOST}/api/v1/namespaces/${ns}/services/${svcname} | jq .code)
        req_body=$(compose_req_body $ns $svcname $uid $port $tport)
        
        if [ "$http_code" -eq "404" ]; then 
            curl --insecure -s -XPOST \
                 -H "Authorization: Bearer ${TOKEN}" \
                 -H "Accept: application/json" \
                 -H "Content-Type: application/json" \
                 https://${KUBE_HOST}/api/v1/namespaces/${ns}/services \
                 -d "$req_body"
        else
            curl --insecure -s -XPATCH \
                 -H "Authorization: Bearer ${TOKEN}" \
                 -H "Accept: application/json" \
                 -H "Content-Type: application/strategic-merge-patch+json" \
                 https://${KUBE_HOST}/api/v1/namespaces/${ns}/services/${svcname} \
                 -d "$req_body"
        fi
    done
}

main