#!/bin/bash
# language projects sandbox -

## build atop of base image, default: xvdp/cuda1180-ubuntu2204_ssh_mamba_torch or change optargs
# ./build.sh

## run  with dok/dockerrun
# ./dockerrun --user 1000 --name lang --gpus all --cache /mnt/Data/weights:/home/weights -v /mnt/Data/data:/home/data  --network=host -it --rm xvdp/cuda1180-ubuntu2204_ssh_mamba_torch_lang
## or run with dok/runlang shortcut
# ./runlang

# projects
# openai/whisper        # Speech to Text

# codelucas/newspaper   # newspaper text scraping - to test
# llama and alpaca - open source models - may be superseeded 
# TODO include: mistral MOE


# defaults
source ../../config.sh  # provides GIT_ROOT, MAINTAINER, WEIGHTS_ROOT
source ../utils.sh
ROOT="${GIT_ROOT}/Language"
TAG="latest"
BASEIMAGE="xvdp/cuda1180-ubuntu2204_ssh_mamba_torch"

# projects
PROJECTS=(to_text/whisper llama newspaper stanford_alpaca)
GITS=(openai/whisper facebookresearch/llama codelucas/newspaper tatsu-lab/stanford_alpaca)


# optional args
while getopts b:m:t:r:w: option; do case ${option} in
b) BASEIMAGE=${OPTARG};;
m) MAINTAINER=${OPTARG};;
t) TAG=${OPTARG};;
r) ROOT=${OPTARG};;
w) WEIGHTS_ROOT=${OPTARG};;
esac; done

ASSERT_DIR "${ROOT}"
# ASSERT_DIR "${WEIGHTS_ROOT}" # no weights are copied in this porject


GITROOT=https://github.com

HERE=$PWD

i=0
for proj in "${PROJECTS[@]}"; do
    path="${ROOT}/${proj}"
    parent_dir=$(dirname $path)
    echo "project ${proj}"
    echo "git ${GITS[$i]}"
    echo "parent_dir ${parent_dir}"
    echo "path: ${path}"
    mkdir -p $parent_dir && cd $parent_dir

    if [ ! -d $path ]; then
        echo "   cloning:  ${GITROOT}/${GITS[$i]} to ${path}"
        git clone "${GITROOT}/${GITS[$i]}"
    fi
    cp -rf "${path}" "${HERE}"
    ((i++))
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