#!/bin/bash -e

dir="$(dirname $(readlink -f $0))"
raspbian_url="http://downloads.raspberrypi.org/raspbian/images"
tmp_file="$(mktemp)"
dl_path="/VM_pool/raspbian-rpi-qemu/dl"
vm_path="/VM_pool/raspbian-rpi-qemu"
default_debian_version="raspbian-2017-09-08"

# remove file on exit
trap "{ rm -f $tmp_file; }" EXIT 




function usage () {
	cat << EOF
REQUIREMENTS
	Ansible is required to run this script
SYNOPSIS	
	${0##*/} get_raspbian_versions
	${0##*/} setup raspbian_version (raspbian version is string returned by get_raspbian_versions)
EOF
}

function get_raspbian_versions () {

	curl -s $raspbian_url/ -o $tmp_file
	echo "cat //html/body/table/tr/td/a/text()" | xmllint --html --shell $tmp_file | sed -n 's/\(.*raspbian.*\)\/$/\1/p'
}


function run_playbook () {
	playbook="$1"
	extra_vars="dl_path=$dl_path vm_path=$vm_path $2"
	set -x
	sudo ansible-playbook -i "$dir/ansible/inventory" --extra-vars "$extra_vars" "$dir/ansible/${playbook}.yml" $DEBUG
	set +x
}


function setup () {
	raspbian_version="${1:-$default_debian_version}"
	curl -s $raspbian_url/$raspbian_version/ -o $tmp_file
	zip_file="$(echo 'cat //html/body/table/tr/td/a/text()' | xmllint --html --shell $tmp_file | sed -n '/\.zip$/{p;q}')"
	raspbian_url="$raspbian_url/$raspbian_version/$zip_file"
	run_playbook setup "raspbian_url=$raspbian_url"
}

### Main

case $1 in
	get_raspbian_versions)
		get_raspbian_versions
		;;
	setup)
		shift
		setup ${@}
		;;
	*)
		usage
		;;
esac

