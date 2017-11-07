#!/bin/bash

dir="$(dirname $(readlink -f $0))"

echo $dir
sudo ansible-playbook -i "$dir/ansible/inventory" "$dir/ansible/setup.yml"


