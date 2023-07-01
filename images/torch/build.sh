#!/bin/bash
# generic build script for torch/Dockerfile
# see pytorch for supported cuda environments
# As of writing of this file it is based on ubuntu 22.04 and cuda 11.8

# requires baseimage arg with os, cuda, mamba

# assumes user appuser has been created

# Example : after building images/ssh/Dockerfile
# $ bash build.sh -b xvdp/cuda1180-ubuntu2204_ssh_mamba
# generates -> xvdp/cuda1180-ubuntu2204_ssh_mamba_torch:latest

# optional args 
# -m maintainer   default: xvdp
# -t tag          default: latest
# -n name         default baseimage

if [ $# -eq 0 ]
  then
    echo "docker baseimage required: $ bash build.sh <base_img> [<img_name>]"
    exit
fi

ROOT_LOCAL=~/work/gits
GITS_LOCAL=(pytorch/vision NVlabs/nvdiffrast)

while getopts b:n:m:t:r:g: option; do case ${option} in
b) BASEIMAGE=${OPTARG};;
n) NAME=${OPTARG};;
m) MAINTAINER=${OPTARG};;
t) TAG=${OPTARG};;
r) ROOT=${OPTARG};;       # project root for local installs
esac; done

if [ -z $BASEIMAGE ]; then
    echo "no base image supplied using arg $1"
    BASEIMAGE=$1
fi
# Defaults
[ -z $ROOT ] && ROOT=$ROOT_LOCAL;
[ -z $MAINTAINER ] && MAINTAINER="xvdp";
[ -z $TAG ] && TAG="latest";
[ -z $NAME ] && NAME=$BASEIMAGE;
[ -z $GITS ] && GITS=("${GITS_LOCAL[@]}");

source ../utils.sh
ASSERT_DIR "${ROOT}"


PROJECTS=()
cd ${ROOT}
for proj in "${GITS[@]}"; do
  if [ ! -d "${ROOT}/`basename ${proj}`" ];then
      echo "   cloning:  https://github.com/${proj}"
      git clone "https://github.com/${proj}"
  else
    echo "   using local:   ${ROOT}/`basename ${proj}`"
  fi
  PROJECTS+=(`basename ${proj}`)
done
cd -

for proj in "${PROJECTS[@]}"; do
  if [ ! -d "${ROOT}/${proj}" ];then
    echo "BUILD ERROR: ${ROOT}/${proj} not found, cannot build ...";
    exit
  fi
done
for proj in "${PROJECTS[@]}"; do cp -rf "${ROOT}/${proj}" . ; done


NAME=$(MAKE_IMAGE_NAME $BASEIMAGE $MAINTAINER $PWD $TAG)
docker build --build-arg baseimage=$BASEIMAGE --build-arg maintainer=$MAINTAINER -t $NAME .

# cleanup temp projects
for proj in "${PROJECTS[@]}"; do rm -rf "${proj}" ; done

