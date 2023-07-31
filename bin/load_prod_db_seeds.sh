#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

echo "Please make sure .env has been setup correctly before running this"
echo " - see <PROJECT_DIR>/.env.example for more info"
read -p "Continue? [y/N] " prompt
if [[ ! $prompt =~ [yY](es)* ]]; then
    exit 1
fi

# cd to the project dir
dirname=$(dirname -- "$( readlink -f -- "$0"; )";)
cd $dirname/..

set -o allexport
source .env
set +o allexport

MIX_ENV=prod mix run priv/repo/seeds.exs
cd -