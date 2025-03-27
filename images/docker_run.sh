##!/bin/bash
## runs docker from config file provided that yammle has the following structure
#
# dockerrun.sh config.yaml projectname
# run:
#   projectname:
#     image: 'maintainer/validimage'
#     user: validuser
#     gpus: 1
#     volumes:
#       -v /host0:/container0
#       -v /host1:/container1

# e.g.  bash testconfig.sh config.yaml deepseek


get_yaml_value() {
  local config_file="$1"
  shift # Remove the config_file argument
  local yq_path=".$(IFS=. ; echo "$*")" # Construct the yq path
  cat "$config_file" | yq "$yq_path"
}

build_docker_run() {
  local config_file="$1"
  local image_name="$2"

  local image=$(get_yaml_value "$config_file" run "$image_name" image)
  local user=$(get_yaml_value "$config_file" run "$image_name" user)
  local gpus=$(get_yaml_value "$config_file" run "$image_name" gpus)
  local volumes=$(get_yaml_value "$config_file" run "$image_name" volumes)

  local docker_run_command="docker run --user $user -it --gpus device=$gpus --network=host --rm --name $image_name"

  # Append volumes
  if [[ -n "$volumes" ]]; then
    docker_run_command="$docker_run_command $volumes"
    # local volume_array=($(echo "$volumes" | tr -d '[]"'))
    # for volume in "${volume_array[@]}"; do
    #   docker_run_command="$docker_run_command -v $volume"
    # done
  fi

  docker_run_command="$docker_run_command $image"
  echo "$docker_run_command"
  eval "$docker_run_command" 
}

build_docker_run "$1" "$2"