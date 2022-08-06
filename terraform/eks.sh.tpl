#!/bin/bash

set -ex
B64_CLUSTER_CA=${CA}
API_SERVER_URL=${EP}
/etc/eks/bootstrap.sh my-cluster --b64-cluster-ca $B64_CLUSTER_CA --apiserver-endpoint $API_SERVER_URL
