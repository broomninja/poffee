#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

SCRIPT_NAME=$(readlink -f ${BASH_SOURCE[0]})
SCRIPTDIR=$(dirname $SCRIPT_NAME)

# cd to the project dir
cd $SCRIPTDIR/..

set -o allexport
eval $(egrep -v '^#' .env | xargs)
set +o allexport

cd -
