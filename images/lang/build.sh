#!/bin/bash
# language

## build atop of base image
# ./build.s

## run  with dok/dockerrun
# dockerrun --user 1000 --name lang --gpus all --cache /mnt/Data/weights:/home/weights -v /mnt/Data/data:/home/data  --network=host -it --rm xvdp/cuda1180-ubuntu2204_ssh_mamba_torch_lang

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

# defaults
BASEIMAGE=${BASEIMAGE:-xvdp/cuda1180-ubuntu2204_ssh_mamba_torch}
MAINTAINER=${MAINTAINER:-xvdp}
TAG=${TAG:-latest}

# local roots
ROOT=${ROOT:-~/work/gits/Language} # home for projects
WEIGHTS_ROOT=${WEIGHTS_ROOT:-~/weights} # home for weights
source ../utils.sh
ASSERT_DIR "${ROOT}"
ASSERT_DIR "${WEIGHTS_ROOT}"

GITROOT=https://github.com

HERE=$PWD

i=0
for proj in "${PROJECTS[@]}"; do
    path="${ROOT}/${proj}"
    parent_dir=$(dirname $path)
    echo "\nprogect ${proj}"
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