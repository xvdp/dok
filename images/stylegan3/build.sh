#!/bin/bash

# 1.
# stylegan3 uses envs TORCH_EXTENSIONS_DIR DNNLIB_CACHE
# to prevent building extensions in container every time, either:
#   run with dok/dockerrun --cache <path to shared vol>:<path to mounted vol> ...
#   call stylegan3/set_cache_dirs.set_envs(<path to mounted vol>) on scripts.
# default mounted vol /home/weights
# example
# ./dockerrun --user 1000 --name torch --gpus all --cpuset-cpus="0-10" --cache /mnt/Data/weights:/home/weights -v /mnt/Data/data:/home/data -v /mnt/Data/results:/home/results --network=host -it --rm xvdp/cuda1180-ubuntu2204_ssh_mamba_torch_stylegan3


# 2.
# python visualize.py requires forwarding -X but none of the crap i tried seems to work


ROOT=~/work/gits/GANs
WEIGHTS_ROOT=~/weights
BASEIMAGE=xvdp/cuda1180-ubuntu2204_ssh_mamba_torch
MAINTAINER="xvdp"
TAG="latest"

source ../asserts.sh
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

NAME=`echo $BASEIMAGE | cut -d "/" -f 2`   # remove maintainer prefix
NAME=`echo "${NAME//:/$''}"`         # remove ( : . devel- latest )
NAME=`echo "${NAME//./$''}"`         # remove invalid chars in name ':'
NAME=`echo "${NAME//devel-/$''}"`         
NAME=`echo "${NAME//latest/$''}"`   
NAME=$MAINTAINER"/"$NAME"_`basename ${PWD}`:$TAG" # add parent folder name _shh

docker build --build-arg baseimage=$BASEIMAGE --build-arg maintainer=$MAINTAINER -t $NAME .

# cleanup local
rm -rf "`basename ${git0}`"

