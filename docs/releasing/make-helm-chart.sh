#!/usr/bin/env bash



# Packages and pushes Online Boutique's Helm chart in public Artifact Registry.

set -euo pipefail
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT=$SCRIPT_DIR/../..

log() { echo "$1" >&2; }

TAG="${TAG:?TAG env variable must be specified}"
HELM_CHART_REPO="us-docker.pkg.dev/online-boutique-ci/charts"

cd ${REPO_ROOT}/helm-chart
gsed -i "s/^appVersion:.*/appVersion: \"${TAG}\"/" Chart.yaml
gsed -i "s/^version:.*/version: ${TAG:1}/" Chart.yaml
helm package .
helm push onlineboutique-${TAG:1}.tgz oci://$HELM_CHART_REPO

rm ./onlineboutique-${TAG:1}.tgz

log "Successfully built and pushed the Helm chart."
