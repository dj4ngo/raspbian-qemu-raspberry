#!/bin/bash -e

dir="$(dirname $(readlink -f $0))"

grep -q -- "-v[v]*" <<< "$1" && DEBUG="$1"

sudo ansible-playbook -i "$dir/ansible/inventory" "$dir/ansible/setup.yml" $DEBUG


