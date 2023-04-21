#!/bin/bash
# generic build script for internal projects,
# As of writing of this file it is based on ubuntu 22.04 and cuda 11.8

# Args
#   -b baseimage  # required: baseimage with OS, Graphic drivers, authorized_keys, etc.
#   -r root       # required: this project defaults to
#   -i projects   # array of folders under root, passed as -i "${ar[*]}
#       must match list of projects in Dockerfile

# Optional Args
#   -n            # image name -default: basename
#   -m            # maintaner  -default: xvdp
#   -t            # tag        -default: latest

# Example : after building images/ssh/Dockerfile
# $ bash build.sh -b xvdp/cuda_11.8.0-devel-ubuntu22.04_ssh_torch
# generates -> xvdp/cuda_11.8.0-devel-ubuntu22.04_ssh_torch_face:latest


ROOT_LOCAL="/home/z/work/gits" # personal defaults to overwrite
PROJECTS_LOCAL=(nvdiffrast vidi ubuso) # personal projects, which subfolder by same name can be built with pip


if [ $# -eq 0 ]
  then
    echo "docker baseimage required: $ bash build.sh <base_img> [<img_name>]"
    exit
fi

while getopts b:n:m:t:r:i: option; do case ${option} in
b) BASEIMAGE=${OPTARG};;
n) NAME=${OPTARG};;       # build name, default: 
m) MAINTAINER=${OPTARG};; # build maintainer, default : xvdp
t) TAG=${OPTARG};;        # build tag, default : latest
r) ROOT=${OPTARG};;       # project root for local installs
i) PROJECTS=(${OPTARG});; # array of pip installabale projects eg. ar=(nvdiffrast mypip) -i "${ar[*]}
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
[ -z $PROJECTS ] && PROJECTS=$PROJECTS_LOCAL;

# local projects installation # must match Dockerfile ADD instructions
# copy named projects from installation ROOT, install, then clean up
for proj in "${PROJECTS[@]}"; do
  if [ ! -d "${ROOT}/${proj}" ];then echo "${ROOT}/${proj} not found, cannot build ..."; fi
done
for proj in "${PROJECTS[@]}"; do cp -rf "${ROOT}/${proj}" . ; done


NAME=`echo $NAME | cut -d "/" -f 2`  # remove maintainer prefix
NAME=`echo "${NAME//:/$'_'}"`     # remove invalid chars in name ':'
NAME=$MAINTAINER"/"$NAME"_`basename ${PWD}`:$TAG" # add parent folder name _shh

echo BASE_IMAGE=$BASEIMAGE
echo "NAME="$NAME


docker build --build-arg baseimage=$BASEIMAGE --build-arg maintainer=$MAINTAINER -t $NAME .

# cleanup temp projects
for proj in "${PROJECTS[@]}"; do rm -rf "${proj}" ; done
