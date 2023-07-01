#!/bin/bash
# language

## build atop of base image
# ./build.sh -b xvdp/cuda1180-ubuntu2204_ssh_mamba_torch



## run  with dok/dockerrun
# dockerrun --user 1000 --name lang --gpus all --cache /mnt/Data/weights:/home/weights -v /mnt/Data/data:/home/data  --network=host -it --rm xvdp/cuda1180-ubuntu2204_ssh_mamba_torch_lang


# projects
PROJECTS=(to_text/whisper llama)
GITS=(openai/whisper facebookresearch/llama)

BASEIMAGE=xvdp/cuda1180-ubuntu2204_ssh_mamba_torch
MAINTAINER="xvdp"
TAG="latest"

# local roots
ROOT=~/work/gits/Language
WEIGHTS_ROOT=~/weights
source ../utils.sh
ASSERT_DIR "${ROOT}"
ASSERT_DIR "${WEIGHTS_ROOT}"

GITROOT=https://github.com

HERE=$PWD

i=0
for proj in "${PROJECTS[@]}"; do
    path="${ROOT}/${proj}"
    parent_dir=$(dirname $path)
    mkdir -p $parent_dir && cd $parent_dir

    if [ ! -d $path ]; then
        echo "   cloning:  ${GITROOT}/${GITS[$i]}"
        git clone "${GITROOT}/${GITS[$i]}"
    fi
    cp -rf "${path}" "${HERE}"
    i=${i+1}
done
cd $HERE

for proj in "${PROJECTS[@]}"; do
    ASSERT_DIR "`basename ${proj}`"
done

# weights are too large. copy them into volume first then link.

NAME=$(MAKE_IMAGE_NAME $BASEIMAGE $MAINTAINER $PWD $TAG)
docker build --build-arg baseimage=$BASEIMAGE --build-arg maintainer=$MAINTAINER --no-cache -t $NAME .

# cleanup temp projects
for proj in "${PROJECTS[@]}"; do
    rm -rf "`basename ${proj}`"
done