#!/bin/bash

if [[ "$VIRTUAL_ENV" ]]
then
    echo "enviroment already set $VIRTUAL_ENF"
else
    if [[ ! -d "venv" ]]
    then
        python3 -m venv venv
        . ./venv/bin/activate
        pip install --upgrade pip
        pip install -r ./requirements.pip
    else
        . ./venv/bin/activate
    fi
fi

