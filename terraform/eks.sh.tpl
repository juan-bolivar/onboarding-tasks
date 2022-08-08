MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==MYBOUNDARY=="

--==MYBOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"

#!/bin/bash
set -ex
B64_CLUSTER_CA=${CA}
API_SERVER_URL=${EP}
/etc/eks/bootstrap.sh my-cluster --b64-cluster-ca $B64_CLUSTER_CA --apiserver-endpoint $API_SERVER_URL

--==MYBOUNDARY==--\

