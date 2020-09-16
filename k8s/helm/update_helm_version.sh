#!/bin/bash 
# $1 helm chart.yaml path
# $2 - app version
# $3 - chart version
if [[ ! -z "$1" ]]
then
    echo ""

    if [[ ! -z "$2" ]]
    then
        sed -i -e "s|appVersion:.*|appVersion:$2|g" $1 
    else
        echo "App version is empty"
    fi


    if [[ ! -z "$3" ]]
    then
        sed -i -e "s|version:.*|version:$3|g" $1 
    else
        echo "Chart version is empty"
    fi

else
    echo "Chart yaml not defined for $0"
    exit 1
fi
