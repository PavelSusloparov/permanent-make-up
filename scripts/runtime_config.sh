#!/usr/bin/env bash

# Set variable
#gcloud beta runtime-config configs variables set greeting \
#  "Hi from Runtime Config" \
#  --config-name frontend_cloud

gcloud beta runtime-config configs variables list --config-name=frontend_cloud

gcloud beta runtime-config configs variables get-value greeting --config-name=frontend_cloud
gcloud beta runtime-config configs variables get-value messages.endpoint --config-name=frontend_cloud

# Refresh updated values
# curl -XPOST http://localhost:8080/actuator/refresh
