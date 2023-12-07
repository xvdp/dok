#!/bin/bash

# docker run --user 1000 --name f2f --gpus device=1 --cpuset-cpus="14-27" -v /mnt/share:/home/share -v /mnt/Data/data:/home/data  --network=host -it --rm xvdp/cuda1180-ubuntu2204_ssh_mamba_torch_rf

# defaults
source ../../config.sh  # provides GIT_ROOT, MAINTAINER, WEIGHTS_ROOT
source ../utils.sh
ROOT="${GIT_ROOT}/RF"
BASEIMAGE=xvdp/cuda1180-ubuntu2204_ssh_mamba_torch
TAG="latest"

ASSERT_DIR "${ROOT}"
ASSERT_DIR "${WEIGHTS_ROOT}"

#
# projects
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

NAME=$(MAKE_IMAGE_NAME $BASEIMAGE $MAINTAINER $PWD $TAG)

docker build --build-arg baseimage=$BASEIMAGE --build-arg maintainer=$MAINTAINER --no-cache -t $NAME .

# cleanup temp projects
rm -rf "`basename ${git0}`"
echo "`basename ${git0}`"
