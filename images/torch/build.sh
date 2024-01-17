#!/bin/bash
# # build script for torch/Dockerfile

# # requires baseimage arg with:
# * OS
# * CUDA ( 11.8 or 12.1 as per torch latest)
# * mamba
# * user appuser
# tested with baseimages:
# * xvdp/cuda1180-ubuntu2204_ssh_mamba : builds torch 2.0.1
# * xvdp/cuda1210-ubuntu2204_ssh_mamba : builds torch 2.1.0

# # Examples
# $ bash build.sh -b xvdp/cuda1180-ubuntu2204_ssh_mamba
# $ bash build.sh -b xvdp/cuda1210-ubuntu2204_ssh_mamba


# # optional args 
# -m maintainer   default: xvdp
# -t tag          default: latest
# -n name         default baseimage


if [ $# -eq 0 ]
  then
    echo "docker baseimage required: $ bash build.sh <base_img> [<img_name>]"
    exit
fi

source ../../config.sh  # provides GIT_ROOT, MAINTAINER, WEIGHTS_ROOT

ROOT=$GIT_ROOT
GITS=(NVlabs/nvdiffrast pytorch/vision)
TAG="latest"

while getopts b:n:m:t:r:g: option; do case ${option} in
b) BASEIMAGE=${OPTARG};;
n) NAME=${OPTARG};;
m) MAINTAINER=${OPTARG};; # preefined in config
t) TAG=${OPTARG};;
r) ROOT=${OPTARG};;       # project root for local installs
g) GITS=${OPTARG};;
esac; done

HERE=`dirname "$(realpath "$0")"`
GITROOT=https://github.com

if [ -z $BASEIMAGE ]; then
    echo "no base image supplied using arg $1"
    BASEIMAGE=$1
fi
# Defaults
[ -z $NAME ] && NAME=$BASEIMAGE;

ASSERT_DIR "${ROOT}"

PROJECTS=()
cd ${ROOT}
for git in "${GITS[@]}"; do
  proj="${ROOT}/`basename ${git}`"
  if [ ! -d $proj ];then
      echo "   cloning:  ${GITROOT}/${git}"
      git clone "${GITROOT}/${git}"
  else
    echo "   using local cache:   ${proj}"
  fi
  ASSERT_DIR "${proj}"
  cp -rf "${proj}" "${HERE}"
  PROJECTS+=(`basename ${proj}`)
done
cd -


NAME=$(MAKE_IMAGE_NAME $BASEIMAGE $MAINTAINER $PWD $TAG)
docker build --build-arg baseimage=$BASEIMAGE --build-arg maintainer=$MAINTAINER -t $NAME .

# cleanup temp projects
for proj in "${PROJECTS[@]}"; do rm -rf "${proj}" ; done

