#!/bin/bash
# @xvdp

# example script building all images on server, requires:
# I docker context is set to a remote server, ensure that AUTH_ROOT contains the public ssh of those permitted to access.
# 1. set AUTH_ROOT and PROJ_ROOT to valid folders
# 2. cat ~/id_rsa.pub >> ~/$AUTH_ROOT/authorized_keys
# 3. ./buildall.sh

source ./config.sh  # provides $BASEIMAGE, $MAINTAINER, $DEFAULTTAG


AUTH_ROOT=~/.ssh
PROJ_ROOT=~/work/gits
if [ ! -d "${AUTH_ROOT}" ]; then
  echo "${AUTH_ROOT} does not exist, modify script AUTH_ROOT with folder with authorized_keys are found"
  exit
fi
if [ ! -d "${PROJ_ROOT}" ]; then
  echo "${PROJ_ROOT} does not exist, modify script PROJ_ROOT with projects folder"
  exit
fi


echo "Building stack of images based on ${BASEIMAGE} > "

PROJECTNAME=ssh
cd $PROJECTNAME && ./build.sh -b $BASEIMAGE -r $AUTH_ROOT -m $MAINTAINER -t $DEFAULTTAG 
#-u "${USERGIDS}"


# # build on top of previousimage
BASEIMAGE=$(MAKE_IMAGE_NAME $BASEIMAGE $MAINTAINER $PROJECTNAME $DEFAULTTAG)
echo $BASEIMAGE
PROJECTNAME=mamba
cd ../$PROJECTNAME && ./build.sh -b $BASEIMAGE -m $MAINTAINER -t $DEFAULTTAG -r $PROJ_ROOT

# # build on top of previousimage
BASEIMAGE=$(MAKE_IMAGE_NAME $BASEIMAGE $MAINTAINER $PROJECTNAME $DEFAULTTAG)

PROJECTNAME=torch241_deepseek
cd ../$PROJECTNAME && ./build.sh -b $BASEIMAGE -m $MAINTAINER -t $DEFAULTTAG -r $PROJ_ROOT

# PROJECTNAME=torch
# cd ../$PROJECTNAME && ./build.sh -b $BASEIMAGE -m $MAINTAINER -t $DEFAULTTAG -r $PROJ_ROOT


# BASEIMAGE=$(MAKE_IMAGE_NAME $BASEIMAGE $MAINTAINER $PROJECTNAME $DEFAULTTAG)
# PROJECTNAME=torch

# cd ssh && ./build.sh -b nvidia/cuda:11.8.0-devel-ubuntu22.04 -r $AUTH_ROOT
# cd ../mamba && ./build.sh -b xvdp/cuda1180-ubuntu2204_ssh
# cd ../torch && ./build.sh -b xvdp/cuda1180-ubuntu2204_ssh_mamba -r $PROJ_ROOT
# cd ../diffuse && ./build.sh -b xvdp/cuda1180-ubuntu2204_ssh_mamba_torch -r "${PROJ_ROOT}/Diffusion"
# cd ../lang && ./build.sh -b xvdp/cuda1180-ubuntu2204_ssh_mamba_torch -r "${PROJ_ROOT}/Language"
# cd ../gans && ./build.sh -b xvdp/cuda1180-ubuntu2204_ssh_mamba_torch -r "${PROJ_ROOT}/GANs"

# TODO deprecate - diffrast has been added to torch image
# cd ../diffrast_example && ./build.sh -b xvdp/cuda1180-ubuntu2204_ssh_mamba_torch -g  NVlabs/nvdiffrast -r $PROJ_ROOT
