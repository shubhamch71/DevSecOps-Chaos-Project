#!/usr/bin/env bash


# Builds and pushes docker image for each demo microservice.

set -euo pipefail
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT=$SCRIPT_DIR/../..

log() { echo "$1" >&2; }

TAG="${TAG:?TAG env variable must be specified}"
REPO_PREFIX="${REPO_PREFIX:?REPO_PREFIX env variable must be specified}"
PROJECT_ID="${PROJECT_ID:?PROJECT_ID env variable must be specified e.g. google-samples}"

while IFS= read -d $'\0' -r dir; do
    # build image
    svcname="$(basename "${dir}")"
    builddir="${dir}"
    #PR 516 moved cartservice build artifacts one level down to src
    if [ $svcname == "cartservice" ]
    then
        builddir="${dir}/src"
    fi
    image="${REPO_PREFIX}/$svcname:$TAG"
    (
        cd "${builddir}"
        log "Building (and pushing) image on Google Cloud Build: ${image}"
        gcloud builds submit --project=${PROJECT_ID} --tag=${image}
    )
done < <(find "${REPO_ROOT}/src" -mindepth 1 -maxdepth 1 -type d -print0)

log "Successfully built and pushed all images."
