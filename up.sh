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
true ${CONCOURSE_APP_PIPELINE:?"!"}
true ${STATE_REPO_URL:?"!"}
true ${STATE_REPO_PRIVATE_KEY:?"!"}
true ${APP_REPO_URL:?"!"}
true ${CF_API_URL:?"!"}
true ${CF_USERNAME:?"!"}
true ${CF_PASSWORD:?"!"}
true ${CF_ORG:?"!"}
true ${CF_SPACE:?"!"}
true ${PIPELINE_REPO_URL:?"!"}
true ${GITHUB_RELEASE_OWNER:?"!"}
true ${GITHUB_RELEASE_REPO:?"!"}
true ${GITHUB_RELEASE_TOKEN:?"!"}

mkdir -p bin
PATH=$(pwd)/bin:$PATH

if ! [ -f bin/fly ]; then
  curl -L "https://$DOMAIN/api/v1/cli?arch=amd64&platform=darwin" > bin/fly
  chmod +x bin/fly
fi

if ! fly targets | grep $CONCOURSE_TARGET; then
  fly login \
    --target $CONCOURSE_TARGET \
    --concourse-url "https://$DOMAIN" \
    --team-name $CONCOURSE_TEAM \
    --username $CONCOURSE_USERNAME \
    --password $CONCOURSE_PASSWORD \
  ;
fi

if ! [ -f state/quorum-pipeline-vars.yml ]; then
  cat > state/quorum-pipeline-vars.yml <<EOF
cf_api_url: $CF_API_URL
cf_username: $CF_USERNAME
cf_password: $CF_PASSWORD
cf_org: $CF_ORG
cf_space: $CF_SPACE
pipeline_repo_url: $PIPELINE_REPO_URL
github_release_owner: $GITHUB_RELEASE_OWNER
github_release_repo: $GITHUB_RELEASE_REPO
github_release_token: $GITHUB_RELEASE_TOKEN
EOF
fi

fly set-pipeline \
  --target $CONCOURSE_TARGET \
  --pipeline $CONCOURSE_APP_PIPELINE \
  --load-vars-from state/quorum-pipeline-vars.yml \
  --config quorum-pipeline/pipeline.yml \
  --non-interactive \
;
