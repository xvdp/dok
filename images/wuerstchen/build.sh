#!/bin/bash

## build atop of base image
# ./build.sh -b xvdp/cuda1180-ubuntu2204_ssh_mamba_torch

## run
# docker run --user 1000 --name f2f --gpus device=1 --cpuset-cpus="14-27" -v /mnt/share:/home/share -v /mnt/Data/data:/home/data  --network=host -it --rm xvdp/cuda1180-ubuntu2204_ssh_mamba_torch_face_wuerstchen

## run jupyter (in above cmd line - or from another docker console) 
# docker exec -it wue0 jupyter notebook --allow-root -y --no-browser --ip=0.0.0.0 --port=32778

BASEIMAGE=xvdp/cuda1180-ubuntu2204_ssh_mamba_torch
ROOT=~/work/gits/Diffusion
WEIGHTS_ROOT=~/weights
# downloads models from https://huggingface.co/dome272/wuerstchen/ to $WEIGHTS_ROOT 
# If the project already has the weights within the code, remove all references to WEIGHTs_ROOT, it wont be necessary.
#   rationale: store large files in shared data drive instead of the main drive

while getopts b:r:w: option; do case ${option} in
b) BASEIMAGE=${OPTARG};;
r) ROOT=${OPTARG};;         # project root for local installs
w) WEIGHTS_ROOT=${OPTARG};; # weights root: download 
esac; done

ASSERT_DIR () {
  if [ ! -d "${1}" ]; then
    echo "FOLDER ${1} not found"
    exit
  fi
}

ASSERT_FILE () {
  if [ ! -f "${1}" ]; then
    echo "FILE ${1} not found"
    exit
  fi
}

ASSERT_DIR "${ROOT}"
ASSERT_DIR "${WEIGHTS_ROOT}"
MAINTAINER="xvdp"
TAG="latest"

#
# Wuerstchen xvdp:dev
#
cd ${ROOT}
git0=xvdp/wuerstchen
name="`basename ${git0}`"
proj="${ROOT}/${name}"
if [ ! -d "${proj}" ];then
    echo "   cloning:  https://github.com/${git0}"
    git clone -b xdev "https://github.com/${git0}"
fi
cd -
cp -rf "${proj}" .
ASSERT_DIR "${name}"

#
# Wuerschen weights
#
pretrained=( model_stage_b.pt model_stage_c_ema.pt model_stage_c.pt vqgan_f4_v1_500k.pt )
modelscache="${WEIGHTS_ROOT}/${name}"
models="${name}/models"

mkdir -p $modelscache
mkdir -p $models

for pt in "${pretrained[@]}"; do
    if [ ! -f "${modelscache}/${pt}" ]; then
        wget -O "${modelscache}/${pt}" "https://huggingface.co/dome272/wuerstchen/resolve/main/${pt}" 
    fi
    cp "${modelscache}/${pt}" $models
    ASSERT_FILE "${models}/${pt}"
done

cd ${ROOT}
git1=pabloppp/pytorch-tools
name="`basename ${git1}`"
proj="${ROOT}/${name}"
if [ ! -d "${proj}" ];then
    echo "   cloning:  https://github.com/${git1}"
    git clone "https://github.com/${git1}"
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

# echo BASE_IMAGE=$BASEIMAGE
# echo "NAME=$NAME

docker build --build-arg baseimage=$BASEIMAGE --build-arg maintainer=$MAINTAINER --no-cache -t $NAME .

# cleanup temp projects
rm -rf "`basename ${git0}`"
rm -rf "`basename ${git1}`"
