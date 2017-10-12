#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

if ! [ -d state/ ]; then
  exit "No State, exiting"
  exit 1
fi

source state/env.sh
true ${CONCOURSE_TEAM:?"!"}
true ${CONCOURSE_USERNAME:?"!"}
true ${CONCOURSE_PASSWORD:?"!"}
true ${CONCOURSE_DEV_PIPELINE:?"!"}
true ${CF_API_URL:?"!"}
true ${CF_USERNAME:?"!"}
true ${CF_PASSWORD:?"!"}
true ${CF_ORG:?"!"}
true ${CF_SPACE:?"!"}
true ${PIPELINE_REPO_URL:?"!"}
true ${PIPELINE_REPO_PRIVATE_KEY:?"!"}
true ${GITHUB_RELEASE_OWNER:?"!"}
true ${GITHUB_RELEASE_REPO:?"!"}
true ${GITHUB_RELEASE_TOKEN:?"!"}

mkdir -p bin
PATH=$(pwd)/bin:$PATH

if ! [ -f bin/fly ]; then
  curl -L "https://$DOMAIN/api/v1/cli?arch=amd64&platform=darwin" > bin/fly
  chmod +x bin/fly
fi

fly login \
  --target $CONCOURSE_TARGET \
  --concourse-url "https://$DOMAIN" \
  --team-name $CONCOURSE_TEAM \
  --username $CONCOURSE_USERNAME \
  --password $CONCOURSE_PASSWORD \
;

fly set-pipeline \
  --target $CONCOURSE_TARGET \
  --pipeline $CONCOURSE_DEV_PIPELINE \
  -v cf_api_url="$CF_API_URL" \
  -v cf_username="$CF_USERNAME" \
  -v cf_password="$CF_PASSWORD" \
  -v cf_org="$CF_ORG" \
  -v cf_space="$CF_SPACE" \
  -v pipeline_repo_url="$PIPELINE_REPO_URL" \
  -v pipeline_repo_private_key="$PIPELINE_REPO_PRIVATE_KEY" \
  -v quorum_pcf_repo_url="$QUORUM_PCF_REPO_URL" \
  -v github_release_owner="$GITHUB_RELEASE_OWNER" \
  -v github_release_repo="$GITHUB_RELEASE_REPO" \
  -v github_release_token="$GITHUB_RELEASE_TOKEN" \
  --config quorum-pipeline/pipeline.yml \
  --non-interactive \
;
