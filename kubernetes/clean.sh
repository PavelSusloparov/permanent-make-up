#!/usr/bin/env bash

kubectl delete svc backend-service
kubectl delete deployment backend-service
kubectl delete svc frontend-service
kubectl delete deployment frontend-service
