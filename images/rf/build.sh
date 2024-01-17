#!/bin/bash

# this project installs ontop of cuda11.8 ubuntu22.04 torch2.1
# NVIDIAGameWorks/kaolin
# xvdp/diff-gaussian-rasterization with overloads to various gaussian splatting methods
# xvdp/koreto - utility functions
#   ObjDict(): dict with attrs to simplify argparse dependency


# defaults
source ../../config.sh  # provides GIT_ROOT, MAINTAINER, WEIGHTS_ROOT
ROOT="${GIT_ROOT}/RF"
BASEIMAGE=xvdp/cuda1180-ubuntu2204_ssh_mamba_torch
TAG="latest"

ASSERT_DIR "${ROOT}"
# ASSERT_DIR "${WEIGHTS_ROOT}"
HERE=`dirname "$(realpath "$0")"`
GITROOT=https://github.com

#
# projects
#
cd ${ROOT}
git0=NVIDIAGameWorks/kaolin
name="`basename ${git0}`"
proj="${ROOT}/${name}"
if [ ! -d "${proj}" ];then
    echo "   cloning:  ${GITROOT}/${git0}"
    git clone "${GITROOT}/${git0}"
fi
cd $HERE
cp -rf "${proj}" .
ASSERT_DIR "${name}"

cd "${ROOT}"
git1=xvdp/koreto
name="`basename ${git1}`"
proj="${ROOT}/${name}"
if [ ! -d "${proj}" ];then
    echo "   cloning:  ${GITROOT}/${git1}"
    git clone "${GITROOT}/${git1}"
fi
cd $HERE
cp -rf "${proj}" .
ASSERT_DIR "${name}"
# cp /home/z/weights/RingNet/

NAME=$(MAKE_IMAGE_NAME $BASEIMAGE $MAINTAINER $PWD $TAG)

docker build --build-arg baseimage=$BASEIMAGE --build-arg maintainer=$MAINTAINER --no-cache -t $NAME .

# cleanup temp projects copied to docker context
rm -rf "`basename ${git0}`"
rm -rf "`basename ${git1}`"
echo "`basename ${git0}`"
