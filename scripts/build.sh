#!/bin/bash

# This script will build a tarball intended for deploying on production.

# Todo: merge this into deploy-to-staging.sh

set -ex

if [ -z ${COMPOSER_PATH} ]; then
  COMPOSER_PATH=/usr/bin/composer
fi

if [ -z ${NPM_PATH} ]; then
  NPM_PATH=/usr/bin/npm
fi

SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT=$(realpath ${SCRIPT_PATH}/..)
BUILD_ROOT=${PROJECT_ROOT}/build
SOURCES_DIR=${PROJECT_ROOT}/resources/build

# Clean up existing builds.
if [ -d ${BUILD_ROOT} ]; then
  chmod -R u+w ${BUILD_ROOT}
  rm -rf ${BUILD_ROOT}
fi

# Only continue if we are on the latest commit of the master branch.
cd "${PROJECT_ROOT}"
[[ $(git branch --show-current) == "master" ]]

# Clone source code.
git clone . "${BUILD_ROOT}"
cd "${BUILD_ROOT}"
git checkout master origin

# Install dependencies.
"${COMPOSER_PATH}" install --no-dev
cd "${BUILD_ROOT}/web/profiles/contrib/droopler/themes/custom/droopler_theme"
"${NPM_PATH}" install
./node_modules/.bin/gulp compile
cd "${BUILD_ROOT}/web/themes/custom/droopler_subtheme"
"${NPM_PATH}" install
./node_modules/.bin/gulp compile

# Replace files and folders with production symlinks.
cp -rv "${SOURCES_DIR}/." "${BUILD_ROOT}"

# Create archive.
tar -czf "${PROJECT_ROOT}/build.tar.gz" "${BUILD_ROOT}"

# Clean up build folder.
rm -rf "${BUILD_ROOT}"

