#!/usr/bin/env bash

# Copyright 2020 Lightbend Inc.
# Licensed under the Apache License, Version 2.0.

set -o errexit
set -o nounset
set -o pipefail

readonly out=${1:-/dev/stdout}

readonly TCK=./run_tck.sh
readonly LIB_REPO=git://github.com/cloudstateio/go-support.git
readonly CS_REPO=git://github.com/cloudstateio/cloudstate.git
readonly LIB_TAG=$(git ls-remote --tag $LIB_REPO | tail -n 1 | awk -F/ '{ print $3 }' | sed 's/^v\(.*\)/\1/')
readonly CS_TAG=$(git ls-remote --tag $CS_REPO | tail -n 1 | awk -F/ '{ print $3 }' | sed 's/^v\(.*\)/\1/')

echo "${CS_REPO} latest release is: ${CS_TAG}"
echo "${LIB_REPO} latest release is: ${LIB_TAG}"

# 2>&1
function run() {
  local func=$1
  local func_tag=$2
  local proxy=$3
  local proxy_tag=$4
  local now=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  SECONDS=0
  o=$($TCK ${func}:${func_tag} ${proxy}:${proxy_tag} cloudstateio/cloudstate-tck:${proxy_tag})
  local tck_status=$?
  if [ "$tck_status" -eq 0 ]; then pass="true"; else pass="false"; fi
  local duration=$SECONDS
  local func_label="$(basename $func):$func_tag"
  local proxy_label="$(basename $proxy):$proxy_tag"
  echo -n "{
\"name\":\"${func_label} > ${proxy_label}\",
\"timestamp\":\"${now}\",
\"function\":\"${func}:${func_tag}\",
\"function_label\":\"$func_label\",
\"proxy\":\"${proxy}:${proxy_tag}\",
\"proxy_label\":\"${proxy_label}\",
\"tck\":\"cloudstateio/cloudstate-tck:${proxy_tag}\",
\"pass\":${pass},
\"logs\":\"$(echo -n "${o}" | base64)\",
\"runtime\":$duration,
\"buildurl\":\"${TRAVIS_BUILD_WEB_URL}\"
}" | tr -d '\n'
}

FUNC=gcr.io/mrcllnz/cloudstate-go-tck-dev
PROXY=cloudstateio/cloudstate-proxy-dev-mode
echo $(run $FUNC latest $PROXY latest) >>"$out"

PROXY=cloudstateio/cloudstate-proxy-dev-mode
echo $(run $FUNC latest $PROXY "$CS_TAG") >>"$out"

PROXY=cloudstateio/cloudstate-proxy-native-dev-mode
echo $(run $FUNC latest $PROXY latest) >>"$out"

PROXY=cloudstateio/cloudstate-proxy-native-dev-mode
echo $(run $FUNC latest $PROXY "$CS_TAG") >>"$out"

# go release
FUNC=gcr.io/mrcllnz/cloudstate-go-tck
PROXY=cloudstateio/cloudstate-proxy-dev-mode
echo $(run $FUNC "$LIB_TAG" $PROXY latest) >>"$out"

PROXY=cloudstateio/cloudstate-proxy-dev-mode
echo $(run $FUNC "$LIB_TAG" $PROXY "$CS_TAG") >>"$out"

PROXY=cloudstateio/cloudstate-proxy-native-dev-mode
echo $(run $FUNC "$LIB_TAG" $PROXY latest) >>"$out"

PROXY=cloudstateio/cloudstate-proxy-native-dev-mode
echo $(run $FUNC "$LIB_TAG" $PROXY "$CS_TAG") >>"$out"

# python
FUNC=gcr.io/mrcllnz/cloudstate-python-tck
PROXY=cloudstateio/cloudstate-proxy-dev-mode
echo $(run $FUNC latest $PROXY latest) >>"$out"
PROXY=cloudstateio/cloudstate-proxy-dev-mode
echo $(run $FUNC latest $PROXY "$CS_TAG") >>"$out"
PROXY=cloudstateio/cloudstate-proxy-native-dev-mode
echo $(run $FUNC latest $PROXY latest) >>"$out"
PROXY=cloudstateio/cloudstate-proxy-native-dev-mode
echo $(run $FUNC latest $PROXY "$CS_TAG") >>"$out"

# dart
FUNC=sleipnir/dart-shoppingcart
PROXY=cloudstateio/cloudstate-proxy-dev-mode
echo $(run $FUNC 0.5.6 $PROXY latest) >>"$out"
PROXY=cloudstateio/cloudstate-proxy-dev-mode
echo $(run $FUNC 0.5.6 $PROXY "$CS_TAG") >>"$out"
PROXY=cloudstateio/cloudstate-proxy-native-dev-mode
echo $(run $FUNC 0.5.6 $PROXY latest) >>"$out"
PROXY=cloudstateio/cloudstate-proxy-native-dev-mode
echo $(run $FUNC 0.5.6 $PROXY "$CS_TAG") >>"$out"

# kotlin
FUNC=sleipnir/kotlin-shoppingcart
PROXY=cloudstateio/cloudstate-proxy-dev-mode
echo $(run $FUNC latest $PROXY latest) >>"$out"
PROXY=cloudstateio/cloudstate-proxy-dev-mode
echo $(run $FUNC latest $PROXY "$CS_TAG") >>"$out"
PROXY=cloudstateio/cloudstate-proxy-native-dev-mode
echo $(run $FUNC latest $PROXY latest) >>"$out"
PROXY=cloudstateio/cloudstate-proxy-native-dev-mode
echo $(run $FUNC latest $PROXY "$CS_TAG") >>"$out"
