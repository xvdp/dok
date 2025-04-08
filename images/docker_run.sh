#!/bin/bash
## runs docker from config file provided that yaml has the following structure
#
# ./docker_run.sh [-u uid] [-g gpus] projectname [config.yaml] 
# run:
#   environments:                   # optional
#   -e "ENV_VAR_NAME=/local/path/"
#
#   projectname:
#     image: 'maintainer/validimage' (or maintainer/validimage:tag)
#     user: validuser
#     gpus: 1                       # all or specific gpu ids
#     volumes:                      # optional
#       -v /host0:/container0
#       -v /host1:/container1

# Examples
# ./docker_run.sh imgname_defined_in_custom_config custom_config.yaml
# ./docker_run.sh -u 1002 -g all deepseek   # uses default config.yaml



get_yaml_value() {
    local config_file="$1"
    shift # Remove the config_file argument
    local yq_path=".$(IFS=. ; echo "$*")" # Construct the yq path
    cat "$config_file" | yq "$yq_path"
}

build_docker_run() {
    local user
    local gpus

    # Parse options overroding config.yaml
    while getopts u:g: option; do
        case ${option} in
            u) user=${OPTARG};;
            g) gpus=${OPTARG};;
            *) echo "Invalid option: -${OPTARG}"; return 1;;
        esac
    done
    shift $((OPTIND - 1))

    # check that image has been passed
    if [ -z "$1" ]; then
        echo "Error: image config name arg missing."
        echo "  Usage: ./docker_run.sh <image_config_name> [config.yaml]"
        return 1
    fi
    local image_name="$1"

    # check config file exists, default to config.yaml
    local config_file="${2:-config.yaml}"
    if [ ! -f "${config_file}" ]; then
        echo "Config file not found: ${config_file}."
        echo "  Usage: ./docker_run.sh <image_config_name> [config.yaml]"
        return 1
    fi          

    # check that image nickname name in config.yaml has been 
    local image_config=$(get_yaml_value ${config_file} run images ${image_name})
    if [ "$image_config" == null ]; then
        echo "Error: image nickname ${image_config} with image name ${image_name}, not found in ${config_file}."
        echo "  Usage: ./docker_run.sh <image_config_name> [config.yaml]"
        return 1
    fi                          

    # required
    local image=$(get_yaml_value "$config_file" run images "$image_name" image)

    if [ -z $user ]; then 
        user=$(get_yaml_value "$config_file" run images "$image_name" user)
    fi
    if [ -z $gpus ]; then 
        gpus=$(get_yaml_value "$config_file" run images "$image_name" gpus)
    fi


    if [ "$image" == null ] || [ "$user" == null ] || [ "$gpus" == null ]; then
        echo "Error: image, user, or gpus not found in ${config_file} run.${image_name}"
        echo "  Usage: ./docker_run.sh <image_name> [config.yaml]"
        return 1
    fi
    # optional
    local volumes=$(get_yaml_value "$config_file" run images "$image_name" volumes)
    local environments=$(get_yaml_value "$config_file" run environments)
 
    # ensure docker image exists:
    if ! docker image inspect "$image" &> /dev/null; then 
        echo "Error: docker image $image not found in ${config_file}. Please build the image first."
        echo
        echo "Available images:"
        docker images
        return 1
    fi

    local docker_run_command="docker run --user $user -it --gpus device=$gpus --network=host --rm --name $image_name"

    # Append volumes
    if [[ -n "$volumes" ]]; then
        docker_run_command="$docker_run_command $volumes"
    fi
    if [[ -n "$environments" ]]; then
        docker_run_command="$docker_run_command $environments"
    fi

    docker_run_command="$docker_run_command $image"
    echo "$docker_run_command"
    eval "$docker_run_command" 
}

# main function logic

build_docker_run "$@"
