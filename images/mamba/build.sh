#!/bin/bash
# generic build script for mamba/Dockerfile over baseimage
# requires baseimage arg

# Example : after building images/ssh/Dockerfile
# $ bash build.sh -b xvdp/cuda1180-ubuntu2204_ssh
# generates -> xvdp/cuda1180-ubuntu2204_ssh_mamba:latest

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

NAME=`echo $NAME | cut -d "/" -f 2`   # remove maintainer prefix
NAME=`echo "${NAME//:/$''}"`         # remove ( : . devel- latest )
NAME=`echo "${NAME//./$''}"`         # remove invalid chars in name ':'
NAME=`echo "${NAME//devel-/$''}"`         
NAME=`echo "${NAME//latest/$''}"`   
NAME=$MAINTAINER"/"$NAME"_`basename ${PWD}`:$TAG" # add parent folder name _shh

echo BASE_IMAGE=$BASEIMAGE
echo "NAME="$NAME

docker build --build-arg baseimage=$BASEIMAGE --build-arg maintainer=$MAINTAINER -t $NAME .
