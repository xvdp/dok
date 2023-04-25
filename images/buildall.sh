#!/bin/bash
# @xvdp
# example script building all images on server
# 1. set AUTH_ROOT and PROJ_ROOT to valid folders
# 2. cat ~/id_rsa.pub >> ~/$AUTH_ROOT/authorized_keys
# 3. ./buildall.sh

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

cd ssh && ./build.sh -b nvidia/cuda:11.8.0-devel-ubuntu22.04  -r $AUTH_ROOT
cd ../mamba && ./build.sh -b xvdp/cuda_11.8.0-devel-ubuntu22.04_ssh
cd ../torch && ./build.sh -b xvdp/cuda_11.8.0-devel-ubuntu22.04_ssh_mamba
cd ../diffrast_example && ./build.sh -b xvdp/cuda_11.8.0-devel-ubuntu22.04_ssh_mamba_torch -g  NVlabs/nvdiffrast -r $PROJ_ROOT
