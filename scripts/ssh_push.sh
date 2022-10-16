#!/bin/bash

# This scripts allows to push an image exposed only to a local
# docker registry through an ssh coonection.
#
# usage: ssh_push [server] [docker_image]

# open an ssh connection just to port forward the docker registry port
ssh -L 5000:localhost:5000 $1 "nc -l -p 5001 -e '/bin/false'" &

# wait a little bit for the ssh connection to be stablished
sleep 2

# pull the image to the repository
docker push $2

# execute a remote command to terminate the previous ssh connection established
# to forward the docker registry port
ssh $1 "wget localhost:5001"

