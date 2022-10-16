#!/bin/bash
# check if the old way of executing still works, or some parts are not needed anymore
# ansible-playbook -i hosts/$1 server_setup.yaml -e 'ansible_python_interpreter=/usr/bin/python3' -K --become-method=su
ansible-playbook -i $1 server_setup.yaml --extra-vars "@$2" -K --become-method=su
