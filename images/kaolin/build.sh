#!/bin/bash

# docker run --user 1000 --name f2f --gpus device=1 --cpuset-cpus="14-27" -v /mnt/share:/home/share -v /mnt/Data/data:/home/data  --network=host -it --rm xvdp/cuda1180-ubuntu2204_ssh_mamba_torch_face_face2face
ROOT=~/work/gits/NeuralRepresentations
WEIGHTS_ROOT=~/weights

source ../asserts.sh
ASSERT_DIR "${ROOT}"
ASSERT_DIR "${WEIGHTS_ROOT}"

BASEIMAGE=xvdp/cuda1180-ubuntu2204_ssh_mamba_torch
MAINTAINER="xvdp"
TAG="latest"
#
# chumpy
#
cd ${ROOT}
git0=NVIDIAGameWorks/kaolin
name="`basename ${git0}`"
proj="${ROOT}/${name}"
if [ ! -d "${proj}" ];then
    echo "   cloning:  https://github.com/${git0}"
    git clone "https://github.com/${git0}"
fi
cd -
cp -rf "${proj}" .
ASSERT_DIR "${name}" 

# cp /home/z/weights/RingNet/

NAME=`echo $BASEIMAGE | cut -d "/" -f 2`   # remove maintainer prefix
NAME=`echo "${NAME//:/$''}"`         # remove ( : . devel- latest )
NAME=`echo "${NAME//./$''}"`         # remove invalid chars in name ':'
NAME=`echo "${NAME//devel-/$''}"`         
NAME=`echo "${NAME//latest/$''}"`   
NAME=$MAINTAINER"/"$NAME"_`basename ${PWD}`:$TAG" # add parent folder name _shh

# echo BASE_IMAGE=$BASEIMAGE
# echo "NAME=$NAME

docker build --build-arg baseimage=$BASEIMAGE --build-arg maintainer=$MAINTAINER --no-cache -t $NAME .

# cleanup temp projects
rm -rf "`basename ${git0}`"

