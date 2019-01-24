#!/bin/bash
set -uo pipefail

cd "$(cd "$(dirname "$0")"; cd ..; pwd)" || { echo "Failed to change to correct directory"; exit 1; }

# This is the Kubernetes network, which must be in 10/8, but should be considered a
# separate private network from the NYT 10/8, and not routable outside the project.
#
# 10.254.0.0/15 has been reserved in the NYT Network for GKE, to prevent overlap,
# but we will use the same IP range(s) in every project for simplicity.
#
# This first cidr will be fine for projects with only one GKE cluster, but will need to
# be changed for subsequent clusters -- uncomment the appropriate one.
# TODO: automate the selection if needed (not trivial)
CLUSTER_CIDR=10.254.0.0/19
#CLUSTER_CIDR=10.254.32.0/19  # SECOND Project Cluster
#CLUSTER_CIDR=10.254.64.0/19  # THIRD  Project Cluster
#CLUSTER_CIDR=10.254.96.0/19  # Et Cetera
#CLUSTER_CIDR=10.254.128.0/19
#CLUSTER_CIDR=10.254.160.0/19
#CLUSTER_CIDR=10.254.192.0/19
#CLUSTER_CIDR=10.254.224.0/19
#CLUSTER_CIDR=10.255.0.0/19
#CLUSTER_CIDR=10.255.32.0/19
#CLUSTER_CIDR=10.255.64.0/19
#CLUSTER_CIDR=10.255.96.0/19
#CLUSTER_CIDR=10.255.128.0/19
#CLUSTER_CIDR=10.255.160.0/19
#CLUSTER_CIDR=10.255.192.0/19
#CLUSTER_CIDR=10.255.224.0/19

usage() {
    echo -e "Usage: $(basename "$0") <name> <region> <machine-type>\n"

    echo -e "Create a new GKE cluster of a particular machine type in a region.\n"
}

# shellcheck disable=SC1091
source bin/common/functions.sh

check_no_args usage "$@"
print_version
check_download
check_gcloud
check_kubectl
check_project

notify() {
  url="https://hooks.slack.com/services/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"
  message="$(whoami) is creating a cluster in project \`$1\` (version \`$3\`):\n\`\`\`$2\`\`\`"
  json="{
  \"text\": \"$message\"
  }"

  # Send the message and mute the response
  curl -s -d "payload=$json" "$url" > /dev/null
}

echo -e "If your team already has a dev cluster in the -dev project and a prd cluster in the -prd project, please run your workload on those existing clusters."
echo -e "Avoid creating a new cluster to run a single application's workload; a GKE cluster is meant to be shared by your team."
echo -e "Feel free to contact Delivery Engineering for more explanation."

confirm "Does your team need this new cluster?"

if [ -z "${1-}" ]; then
    usage
    echo "Error: please provide a cluster name (eg. 'dev-cluster' / 'prd-cluster')"
    exit 1
fi

if [ -z "${2-}" ]; then
    usage
    echo "Error: please provide the region ('us-central1 or 'us-east1')"
    exit 1
fi

# Zone selection from here:
# https://cloud.google.com/compute/docs/regions-zones/regions-zones#available
if [ "$2" == "us-central1" ]; then
    zone="us-central1-b"
    zones="us-central1-c,us-central1-f"
elif [ "$2" == "us-east1" ]; then
    zone="us-east1-b"
    zones="us-east1-c,us-east1-d"
else
    echo "Error: only regions 'us-east1' and 'us-central1' are supported"
    exit 1
fi

if [ -z "${3-}" ]; then
    usage
    gcloud compute machine-types list --filter="zone:( $zone )" --format 'value(format("{0} - {1}", name, description))'
    echo
    echo "Error: please provide a machine type from one of the above"
    exit 1
fi

# Source from scopes.sh:
# - $SCOPES: array of scopes
# shellcheck disable=SC1091
source bin/common/scopes.sh

scope="${SCOPES//$'\n'/,}"

if [[ -z "${CLUSTER_VERSION-}" ]]; then
  CLUSTER_VERSION=$(gcloud container get-server-config --zone "$zone" --format 'value(defaultClusterVersion)')
  echo "Using cluster version: $CLUSTER_VERSION"
  echo "You can change this with the environment variable CLUSTER_VERSION=x.x.x"
else
  echo "Overriding cluster version to $CLUSTER_VERSION"
fi

echo
echo -e "Getting network information..."

echo -e "\nGenerating cluster creation command...\n"

cmd=(
gcloud container clusters create "$1" \
    --zone "$zone" \
    --node-locations "$zone,$zones" \
    --machine-type "$3" \
    --disk-size 100 \
    --num-nodes 1 \
    --enable-autoscaling \
    --min-nodes 1 \
    --max-nodes 5 \
    --scopes "$scope" \
    --cluster-ipv4-cidr "$CLUSTER_CIDR" \
    --cluster-version "$CLUSTER_VERSION" \
    --no-enable-autorepair
    --enable-network-policy
)

echo -e "\$ ${cmd[*]}"

confirm

project=$(get_project)
version=$(get_version)
notify "$project" "${cmd[*]}" "$version"

echo -e "Running command..."

ERRLOG=$(mktemp -t gke-cluster-create)
"${cmd[@]}" 2>&1 |tee $ERRLOG
rc=$?

print_info_about_erroneously_created_cluster() {
  # This is dumb behavior that may change in future `gcloud` releases
  # Rather than blindly deleting a cluster by name, print this warning.
  echo 'IMPORTANT: The cluster may actually have been created, but in an unusable ERROR state.'
  echo 'Use `gcloud` or the web console to delete it.'
}

if [[ $rc -eq 0 ]]; then
  echo -ne "\nScaling kube-dns..."
  while :
    do kubectl get -n kube-system cm kube-dns-autoscaler >/dev/null 2>&1 && break || echo -n .
    sleep 5
  done
  kubectl patch cm kube-dns-autoscaler \
  -n kube-system \
  -p '{"data":{"linear":"{\"coresPerReplica\":32,\"min\":3,\"nodesPerReplica\":2,\"preventSinglePointFailure\":true}"}}'

  echo -e "\nContainer cluster created successfully.\n"
  rm -f ${ERRLOG}
  exit 0
elif grep -q "Requested CIDR ${CLUSTER_CIDR} is not available" ${ERRLOG}; then
  echo
  echo "The standard cluster CIDR block requested (${CLUSTER_CIDR}) is already in use."
  echo "See the comments at the top of this script, set the CLUSTER_CIDR variable"
  echo "to a different value, and try again."
  echo
  echo "Command output has been logged to ${ERRLOG}"
  echo
  print_info_about_erroneously_created_cluster
  echo
  exit 2
else
  echo
  echo "Cluster creation failed. Command output has been logged to ${ERRLOG}"
  echo
  print_info_about_erroneously_created_cluster
  echo
  exit 3
fi
