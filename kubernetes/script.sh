#!/bin/bash


#aws eks update-kubeconfig --region us-east-2 --name my-cluster
aws eks update-kubeconfig --name my-cluster

#sed -i .bak -e 's/v1alpha1/v1beta1/' ~/.kube/config

kubectl get nodes --cluster=$(aws eks describe-cluster --name my-cluster | jq -r .cluster.arn)

kubectl apply -f Deployment.yaml --cluster=$(aws eks describe-cluster --name my-cluster | jq -r .cluster.arn)

kubectl apply -f service-loadbalancer.yaml --cluster=$(aws eks describe-cluster --name my-cluster | jq -r .cluster.arn)

kubectl describe service hello-kubernetes --cluster=$(aws eks describe-cluster --name my-cluster | jq -r .cluster.arn)

# eksctl create addon \
#     --name vpc-cni \
#     --version v1.11.2-eksbuild.1 \
#     --cluster my-cluster \
#     --service-account-role-arn arn:aws:iam::986966396818:role/AmazonEKSVPCCNIRole \
#     --force

# curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.2/docs/install/iam_policy.json


# aws iam create-policy \
#     --policy-name AWSLoadBalancerControllerIAMPolicy \
#     --policy-document file://iam_policy.json


# eksctl create iamserviceaccount \
#   --cluster=my-cluster \
#   --namespace=kube-system \
#   --name=aws-load-balancer-controller \
#   --role-name "AmazonEKSLoadBalancerControllerRole" \
#   --attach-policy-arn=arn:aws:iam::111122223333:policy/AWSLoadBalancerControllerIAMPolicy \
#   --approve


# helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
#   -n kube-system \
#   --set clusterName=my-cluster \
#   --set serviceAccount.create=false \
#   --set serviceAccount.name=aws-load-balancer-controller \
#   --set image.repository=602401143452.dkr.ecr.region-code.amazonaws.com/amazon/aws-load-balancer-controller
# #  --cluster=$(aws eks describe-cluster --name my-cluster | jq -r .cluster.arn) \
# #602401143452.dkr.ecr.us-east-2.amazonaws.com

# curl -o 2048_full.yaml https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.2/docs/examples/2048/2048_full.yaml

# sed -i 's/internet-facing/internal/g' 2048_full.yaml

# kubectl apply -f 2048_full.yaml

# kubectl get deployment -n kube-system aws-load-balancer-controller --cluster=$(aws eks describe-cluster --name my-cluster | jq -r .cluster.arn)

# kubectl get ingress/ingress-2048 -n game-2048 --cluster=$(aws eks describe-cluster --name my-cluster | jq -r .cluster.arn)

# kubectl get deployment -n kube-system aws-load-balancer-controller --cluster=$(aws eks describe-cluster --name my-cluster | jq -r .cluster.arn)
