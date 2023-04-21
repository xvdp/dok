#!/bin/bash
# generic build script for torch/Dockerfile
# see pytorch for supported cuda environments
# As of writing of this file it is based on ubuntu 22.04 and cuda 11.8

# requires baseimage arg with os, cuda, mamba

# assumes user appuser has been created

# Example : after building images/ssh/Dockerfile
# $ bash build.sh -b xvdp/cuda_11.8.0-devel-ubuntu22.04_ssh_mamba
# generates -> xvdp/cuda_11.8.0-devel-ubuntu22.04_ssh_mamba_torch:latest

# optional args 
# -m maintainer   default: xvdp
# -t tag          default: latest
# -n name         default baseimage

if [ $# -eq 0 ]
  then
    echo "docker baseimage required: $ bash build.sh <base_img> [<img_name>]"
    exit
fi

while getopts b:n:m:t: option; do case ${option} in
b) BASEIMAGE=${OPTARG};;
n) NAME=${OPTARG};;
m) MAINTAINER=${OPTARG};;
t) TAG=${OPTARG};;
esac; done

if [ -z $BASEIMAGE ]; then
    echo "no base image supplied using arg $1"
    BASEIMAGE=$1
fi
[ -z $MAINTAINER ] && MAINTAINER="xvdp";
[ -z $TAG ] && TAG="latest";
[ -z $NAME ] && NAME=$BASEIMAGE;

NAME=`echo $NAME | cut -d "/" -f 2`  # remove maintainer prefix
NAME=`echo "${NAME//:/$'_'}"`     # remove invalid chars in name ':'
NAME=$MAINTAINER"/"$NAME"_`basename ${PWD}`:$TAG" # add parent folder name _shh

echo BASE_IMAGE=$BASEIMAGE
echo "NAME="$NAME

docker build --build-arg baseimage=$BASEIMAGE --build-arg maintainer=$MAINTAINER -t $NAME .

