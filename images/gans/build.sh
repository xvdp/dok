#!/bin/bash

# 1.
# stylegan3 uses envs TORCH_EXTENSIONS_DIR DNNLIB_CACHE
# to prevent building extensions in container every time, either:
#   run with dok/dockerrun --cache <path to shared vol>:<path to mounted vol> ...
#   call stylegan3/set_cache_dirs.set_envs(<path to mounted vol>) on scripts.
# default mounted vol /home/weights
# example
# ./dockerglrun --user 1000 --name torch --gpus all --cpuset-cpus="0-10" --cache /mnt/Data/weights:/home/weights -v /mnt/Data/data:/home/data -v /mnt/Data/results:/home/results --network=host -it --rm xvdp/cuda1180-ubuntu2204_ssh_mamba_torch_gans


# 2.
# python stylegan3/visualize.py requires forwarding xauthority, run with dockerglrun


# defaults
source ../../config.sh   # provides GIT_ROOT, MAINTAINER, WEIGHTS_ROOT
ROOT=${ROOT:-${GIT_ROOT}/GANs}
TAG=latest

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

#
# stylegan3 
#
cd ${ROOT}
git0=xvdp/stylegan3
name="`basename ${git0}`"
proj="${ROOT}/${name}"
if [ ! -d "${proj}" ];then
    echo "   cloning:  https://github.com/${git0}"
    git clone "https://github.com/${git0}"
fi
cd -
cp -rf "${proj}" .
ASSERT_DIR "${name}" 

NAME=$(MAKE_IMAGE_NAME $BASEIMAGE $MAINTAINER $PWD $TAG)
docker build --build-arg baseimage=$BASEIMAGE --build-arg maintainer=$MAINTAINER -t $NAME .

# cleanup local
rm -rf "`basename ${git0}`"

