#!/bin/bash

get_project_dir() {
  local project_path="${BASH_SOURCE[0]%*/*}/../"
  if ! [[ "$project_path" == "${BASH_SOURCE[0]}" ]]; then
    cd "$project_path"
  fi
  pwd
}

init_serverspec() {
  cd "${project_dir}/test"
  vagrant init --force --minimal "$box_name"
  bundle install --binstubs
}

project_dir="$(get_project_dir)"
if ! [ -d "${project_dir}/.cache" ]; then
  mkdir -p "${project_dir}/.cache"
  git clone https://github.com/twistedvines/packer-archlinux.git "${project_dir}/.cache/packer-archlinux"
else
  cd "${project_dir}/.cache/packer-archlinux" && git pull origin master
fi
files="$(ls "${project_dir}/"*.sh)"

for file in $files; do
  cp "$file" "${project_dir}/.cache/packer-archlinux/scripts/arch-install-scripts"
done

"${project_dir}/.cache/packer-archlinux/build.sh" -p 'vagrant'

box_files=$(ls "${project_dir}/.cache/packer-archlinux/build/"*.box | sort -r)
box_file="${box_files[0]}"
box_name='packer-archlinux-test'
vagrant box add --force --name "$box_name" "$box_file"
init_serverspec
cd "${project_dir}/test" && bundle exec "${project_dir}/test/bin/rake" spec \
  && vagrant destroy -f
