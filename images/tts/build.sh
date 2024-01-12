#!/bin/bash
# Text To Speech sandbox

## build atop of base image, default: xvdp/cuda1210_ubuntu2204_ssh_mamba_torch
# ./build.sh
## run with dok/runlang shortcut
# runlang -i xvdp/cuda1210_ubuntu2204_ssh_mamba_torch_tts


# defaults
source ../../config.sh  # provides GIT_ROOT, MAINTAINER, WEIGHTS_ROOT
source ../utils.sh
ROOT="${GIT_ROOT}/Language"
TAG="latest"
BASEIMAGE="xvdp/cuda1210-ubuntu2204_ssh_mamba_torch"

# projects
PROJECTS=(TTS/TTS TTS/bark)
GITS=(coqui-ai/TTS suno-ai/bark)
HERE=`dirname "$(realpath "$0")"`
GITROOT=https://github.com


# optional args
while getopts b:m:t:r:w: option; do case ${option} in
b) BASEIMAGE=${OPTARG};;
m) MAINTAINER=${OPTARG};;
t) TAG=${OPTARG};;
r) ROOT=${OPTARG};;
w) WEIGHTS_ROOT=${OPTARG};;
esac; done

ASSERT_DIR "${ROOT}"
ASSERT_DIR "${WEIGHTS_ROOT}"


# create docker context from local disk or github
i=0
for proj in "${PROJECTS[@]}"; do
    path="${ROOT}/${proj}"
    parent_dir=$(dirname $path)
    echo "project: ${proj}"
    echo " git ${GITS[$i]}"
    # echo " path: ${path}" 
    [ -d "${path}" ] && echo " path: ${path}: exists." || echo " path: ${path} does not exist, cloning:"
    mkdir -p $parent_dir && cd $parent_dir
    # git clone loop - keep projects locally avoiding unneeded downloads
    if [ ! -d $path ]; then
        echo "   cloning:  ${GITROOT}/${GITS[$i]} to ${path}"
        git clone "${GITROOT}/${GITS[$i]}"
    fi
    cp -rf "${path}" "${HERE}"
    ((i++))
done
cd $HERE

# validation loop, are projects in context
for proj in "${PROJECTS[@]}"; do
    _proj="`basename ${proj}`"
    ASSERT_DIR "${_proj}"
    
    # copy any weights into the project, if a path in a weights root is cached locally
    # e.g. for project ${ROOT}/OpenVoice copy anything from ${WEIGHTS_ROOT}/OpenVoice into Context
    if [ -d "${WEIGHTS_ROOT}/${_proj}" ]; then
        cp -rfT "${WEIGHTS_ROOT}/${_proj}/" "${_proj}" 
    fi
done

NAME=$(MAKE_IMAGE_NAME $BASEIMAGE $MAINTAINER $PWD $TAG)
# removed no-cache!
docker build --build-arg baseimage=$BASEIMAGE --build-arg maintainer=$MAINTAINER -t $NAME .

# cleanup temp projects
for proj in "${PROJECTS[@]}"; do
    rm -rf "`basename ${proj}`"
done