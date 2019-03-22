#!/usr/bin/env bash

# exit on error even if parts of a pipe fail
set -e -o pipefail


###### Inputs ######

ENVIRONMENT=$1
COMMAND=$2
DIR=$3

###### DIRs ######

SORTACTION="sort";
if [ "${COMMAND}" == "destroy" ]; then
    SORTACTION="sort -r";
fi

DIRS=( $(find . -name 'main.tf' | cut -d'/' -f 2 | $SORTACTION) )
DISPOSABLE_DIRS=( $(find . -name '.local' | cut -d'/' -f 2 | $SORTACTION) )
EXECUTE_DIRS=("${DIRS[@]}")

# Wenn ein Ordner angegeben wurde wird auch nur dieser ausgeführt
if [[ ! -z "${DIR}" ]]; then
    EXECUTE_DIRS=($DIR)
else
    # Wenn es sich um die lokale Umgebung handelt werden nur die disposable-Ordner genommen, sofern kein DIR angegeben wurde
    if [ "$ENVIRONMENT" != "live" ] && [ "$ENVIRONMENT" != "staging" ]; then
        EXECUTE_DIRS=("${DISPOSABLE_DIRS[@]}")
    fi
fi

###### Input checks ######

if [[ -z "${ENVIRONMENT}" ]]; then
    echo "Das zweite Argument muss der Environment-Name sein (live, staging)"
    exit 1
fi

###### Workspace IAM key #######

IAM_KEY=${ENVIRONMENT}
if [ "$IAM_KEY" != "live" ] && [ "$IAM_KEY" != "staging" ]; then
    IAM_KEY="dev"
fi

###### Live Sicherheitsabfrage #######

if [ "${ENVIRONMENT}" == "live" ]; then
    echo
    echo "######## Achtung ###########"
    read -p "Willst du wirklich auf die Live-Umgebung deployen? Bestätige mit 'live': " EINGABE
    echo  # (optional) move to a new line
    if [ $EINGABE != "live" ]; then
        echo "Abbruch"
        exit
    fi
fi

###### Main ######

for each in "${EXECUTE_DIRS[@]}"
do
    echo "############### $each #####################"
    cd $each
    terraform workspace select "${ENVIRONMENT}"
    terraform ${COMMAND} -input=false \
        -var-file ../vars.tfvars \
        -var "environment_key=$IAM_KEY" \
        -var "environment=$ENVIRONMENT"
    cd ..
done

