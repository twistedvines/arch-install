#!/bin/bash

get_project_dir() {
  local project_path="${BASH_SOURCE[0]%*/*}/../"
  if ! [[ "$project_path" == "${BASH_SOURCE[0]}" ]]; then
    cd "$project_path"
  fi
  pwd
}

prepare_environment() {
  cd "${project_dir}/test"
  vagrant init --force --minimal "$box_name"
  bundle install --binstubs
}

project_dir="$(get_project_dir)"

box_files=$(ls "${project_dir}/.cache/packer-archlinux/build/"*.box | sort -r)
box_file="${box_files[0]}"
box_name='packer-archlinux-test'
vagrant box add --force --name "$box_name" "$box_file"
prepare_environment
