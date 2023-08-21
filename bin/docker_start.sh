#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

SCRIPT_NAME=$(readlink -f ${BASH_SOURCE[0]})
echo "SCRIPTNAME is $SCRIPT_NAME"

SCRIPTDIR=$(dirname $SCRIPT_NAME)
echo "absolute path of the script is $SCRIPTDIR"

source $SCRIPTDIR/export_env.sh

# cd to the project dir
cd $SCRIPTDIR/..

docker compose up -d --build

cd -