#!/usr/bin/env bash

#when Admin service's ready use external IP and port 8080
ip=$(kubectl get svc -o=json | jq -r '.items[] | select(.metadata.name == "admin").status.loadBalancer.ingress[0].ip'); open "http://$ip:8080"