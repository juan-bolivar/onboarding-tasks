#!/bin/bash


helm install . --kube-context=$(aws eks describe-cluster --name my-cluster | jq -r .cluster.arn) --generate-name



