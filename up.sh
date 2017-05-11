#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

if ! [ -d state/ ]; then
  exit "No State, exiting"
  exit 1
fi

source state/env.sh
CONCOURSE_TARGET=${CONCOURSE_TARGET:?"env!"}
CONCOURSE_APP_PIPELINE=${CONCOURSE_APP_PIPELINE:?"env!"}
STATE_REPO_URL=${STATE_REPO_URL:?"env!"}
STATE_REPO_PRIVATE_KEY=${STATE_REPO_PRIVATE_KEY:?"env!"}
APP_REPO_URL=${APP_REPO_URL:?"env!"}
CF_API_URL=${CF_API_URL:?"env!"}
APPUSER_USERNAME=${APPUSER_USERNAME:?"env!"}
APPUSER_PASSWORD=${APPUSER_PASSWORD:?"env!"}
APPUSER_ORG=${APPUSER_ORG:?"env!"}
APPUSER_SPACE=${APPUSER_SPACE:?"env!"}

mkdir -p bin
PATH=$(pwd)/bin:$PATH

if ! [ -f bin/fly ]; then
  curl -L "http://$CONCOURSE_DOMAIN/api/v1/cli?arch=amd64&platform=darwin" > bin/fly
  chmod +x bin/fly
fi

if ! fly targets | grep $CONCOURSE_TARGET; then
  fly login \
    --target $CONCOURSE_TARGET \
    --concourse-url "https://$CONCOURSE_DOMAIN" \
    --username $CONCOURSE_USERNAME \
    --password $CONCOURSE_PASSWORD \
  ;
fi

if ! [ -f state/cf-app-pipeline-vars.yml ]; then
  cat > state/cf-app-pipeline-vars.yml <<EOF
cf_api_url: $CF_API_URL
cf_username: $APPUSER_USERNAME
cf_password: $APPUSER_PASSWORD
cf_org: $APPUSER_ORG
cf_space: $APPUSER_SPACE
app_repo_url: $APP_REPO_URL
EOF
fi

if ! fly pipelines -t $CONCOURSE_TARGET | grep $CONCOURSE_PIPELINE; then
  fly set-pipeline \
    --target $CONCOURSE_TARGET \
    --pipeline $CONCOURSE_APP_PIPELINE \
    --load-vars-from state/cf-app-pipeline-vars.yml \
    --config cf-app-pipeline.yml \
    --non-interactive \
  ;
fi
