#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# cd to the project dir
dirname=$(dirname -- "$( readlink -f -- "$0"; )";)
cd $dirname/..
eval $(egrep -v '^#' .env | xargs)
cd -