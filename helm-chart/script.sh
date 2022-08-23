#!/bin/bash

aws eks update-kubeconfig --name my-cluster

helm install . --kube-context=$(aws eks describe-cluster --name my-cluster | jq -r .cluster.arn) --generate-name



