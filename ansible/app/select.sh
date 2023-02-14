#!/bin/bash

if [ -z ${HFW_APP_NAME} ]; then
    export HFW_APP_NAME=$(curl -s -X GET http://${HFW_DOCKER_REPO}/v2/_catalog | jq -r '.repositories[]' | fzf --header "select app")
fi

if [ -z ${HFW_APP_GIT_REPO_DIR} ]; then
    echo "-----------------------------------------"
    echo " set the HFW_APP_GIT_REPO_DIR to select"
    echo " from recent commits in your git history"
    echo "-----------------------------------------"
    export HFW_APP_RELEASE=$(curl -s -X GET http://${HFW_DOCKER_REPO}/v2/${HFW_APP_NAME}/tags/list | jq -r '.tags[]' | fzf --no-sort --header "select release")
else  
    CURDIR=$(pwd)
    cd $HFW_APP_GIT_REPO_DIR
    export HFW_APP_RELEASE=$(git log -20 --pretty="oneline" | fzf --no-sort | cut -f 1 -d ' ')    
    cd $CURDIR
fi

if [ -z ${HFW_APP_HOSTS_FILE} ]; then
    CURDIR=$(pwd)
    if [ -z ${HFW_HOSTS_FILES_BASE} ]; then
        echo "-----------------------------------------"
        echo " set the HFW_HOSTS_FILE_BASE to select"
        echo " from recent commits in your git history"
        echo "-----------------------------------------"
        export HFW_HOSTS_FILES_BASE=$(find $HOME -type d | fzf)
    fi
    cd $HFW_HOSTS_FILES_BASE
    export HFW_APP_HOSTS_FILE=$(fzf --header "select hosts file")
    cd $CURDIR
fi

# if [ -z ${HFW_APP_RELEASE} ]; then
#     export HFW_APP_RELEASE=$(curl -s -X GET http://127.0.0.1:5000/v2/${HFW_APP_NAME}/tags/list | jq -r '.tags[]' | fzf --no-sort --header "select release")
# fi

if [ -z "$HFW_APP_RELEASE" ]; then
    echo "No App Release Hash Set"
else
    ansible-playbook -i $HFW_HOSTS_FILES_BASE/$HFW_APP_HOSTS_FILE app_setup.yaml --extra-vars "app_name=$HFW_APP_NAME app_release=$HFW_APP_RELEASE" -K --become-method=su
fi
