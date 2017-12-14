#!/bin/bash

get_project_dir() {
  local project_path="${BASH_SOURCE[0]%*/*}/../"
  if ! [[ "$project_path" == "${BASH_SOURCE[0]}" ]]; then
    cd "$project_path"
  fi
  pwd
}

project_dir="$(get_project_dir)"

cd "${project_dir}/test" && bundle exec "${project_dir}/test/bin/rake" spec
