#!/usr/bin/env bash

# exit on error even if parts of a pipe fail
set -e -o pipefail

###### Main ######

USERNAME=$1
DIR=$2

###### Input checks ######
if [[ -z "${USERNAME}" ]]; then
    echo "Das zweite Argument muss der Name des Entwicklers sein"
    exit 1
fi

###### DIRS #############

DIRS=( $(find . -name 'main.tf' | cut -d'/' -f 2 | sort) )

if [[ ! -z "${DIR}" ]]; then
    DIRS=($DIR)
fi

for each in "${DIRS[@]}"
do
    echo "############### $each #####################"
    cd ${each}
    terraform init

    echo "Create environment ${USERNAME}, if it does not exist"
    terraform workspace new ${USERNAME} || true

    echo "Create environment live, if it does not exist"
    terraform workspace new live || true

    echo "Create environment staging, if it does not exist"
    terraform workspace new staging || true
    cd ..
done
