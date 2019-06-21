#!/bin/sh

compose_req_body() {
    var_ns=$1
    var_svc=$2
    var_uid=$3
    var_port=$4
    var_tagkey=$5
    var_tagval=$6
    
    var_ips=$(aws ec2 describe-instances \
        --filters Name=instance-state-code,Values=16 Name=tag:${var_tagkey},Values=${var_tagval} \
        --query 'Reservations[].Instances[].{ip:PrivateIpAddress}' \
        --output json \
        --region $AWS_REGION | jq -c '.')
        
    if [ "$var_ips" == "[]" ]; then 
        var_subsets=""
    else
        var_subsets="{\"ports\":[{\"port\":$var_port}],\"addresses\":$var_ips}"
    fi
    
    echo "{\"apiVersion\":\"v1\",\"kind\":\"Endpoints\",\"metadata\":{\"name\":\"$var_svc\",\"namespace\":\"$var_ns\",\"ownerReferences\":[{\"apiVersion\":\"apps/v1\",\"kind\":\"AWSService\",\"name\":\"$var_svc\",\"uid\":\"$var_uid\"}]},\"subsets\":[$var_subsets]}"
}

main() {
    cat work-queue.csv | while read ns uid svcname port tport tname tval; do
        # curl --cacert $CA_FILE
        http_code=$(curl --insecure -s -H "Authorization: Bearer ${TOKEN}" https://${KUBE_HOST}/api/v1/namespaces/${ns}/endpoints/${svcname} | jq .code)
        req_body=$(compose_req_body $ns $svcname $uid $tport $tname $tval)
        
        if [ "$http_code" -eq "404" ]; then 
            curl --insecure -s -XPOST \
                 -H "Authorization: Bearer ${TOKEN}" \
                 -H "Accept: application/json" \
                 -H "Content-Type: application/json" \
                 https://${KUBE_HOST}/api/v1/namespaces/${ns}/endpoints \
                 -d "$req_body"
        else
            curl --insecure -s -XPATCH \
                 -H "Authorization: Bearer ${TOKEN}" \
                 -H "Accept: application/json" \
                 -H "Content-Type: application/strategic-merge-patch+json" \
                 https://${KUBE_HOST}/api/v1/namespaces/${ns}/endpoints/${svcname} \
                 -d "$req_body"
        fi
    done
}

main