#!/bin/bash
# generic build script for ssh/Dockerfile with  3 users appuser, appuser1 appuser2 exposing port 
# create ssh_key then add id_rsa.pub into authorized_keys folder
#
#   $ cat id_rsa.pub >> authorized_keys
#
# REQUIRES at least one valid baseimage arg
# REQUIRES  -r <folder>, containing ssh generated authorized_keys for remote functionality

# Example
# ./build.sh -b nvidia/cuda:11.8.0-devel-ubuntu22.04 -r <myfolder>
# creates -> xvdp/cuda_11.8.0-devel-ubuntu22.04_ssh:latest

# bashrc file in ssh/ is generic for shell preferences, can be replaced

# kwargs
#  -b (baseimage)           # REQUIRED
#  -r (root)                # REQUIRED: substitute default: ~/work/dokcred folder with files 'authorized_keys'
# optional
#  -n (output image name)   # default: maintainer/baseimage_shh:tag
#  -m (maintainer)          # default: xvdp
#  -t (tag)                 # default: latest
#  -p (port)                # default: 32778  # port to be exposed, needs to be opened in the server as well

ROOT_LOCAL="/home/z/work/dokcred"   # overwrite or pass -r <valid folder with authorized_keys file>

if [ $# -eq 0 ]
  then
    echo "docker baseimage required: $ bash build.sh <base_img> [<img_name>]"
    exit
fi

while getopts b:n:m:t:p:r: option; do case ${option} in
b) BASEIMAGE=${OPTARG};;
n) NAME=${OPTARG};;
m) MAINTAINER=${OPTARG};;
t) TAG=${OPTARG};;
p) PORT=${OPTARG};;
r) ROOT=${OPTARG};;       # folder with authorized_keys file
esac; done

if [ -z $BASEIMAGE ]; then
    echo "no base image supplied using arg $1"
    BASEIMAGE=$1
fi
[ -z $MAINTAINER ] && MAINTAINER="xvdp";
[ -z $TAG ] && TAG="latest";
[ -z $NAME ] && NAME=$BASEIMAGE;
[ -z $PORT ] && PORT=32778;
[ -z $ROOT ] && ROOT=$ROOT_LOCAL;


NAME=`echo $NAME | cut -d "/" -f 2`   # remove maintainer prefix
NAME=`echo "${NAME//:/$'_'}"`         # remove invalid chars in name ':'
NAME=$MAINTAINER"/"$NAME"_`basename ${PWD}`:$TAG" # add parent folder name _shh

echo "${ROOT}/authorized_keys"
if [ -f "${ROOT}/authorized_keys" ]; then
  cp -rf "${ROOT}/authorized_keys" .
else
    echo "${ROOT}/authorized_keys not found, building ${NAME} without authorized_keys .."
    exit
fi

echo BASE_IMAGE: $BASEIMAGE
echo "OUT IMAGE: "$NAME

docker build --build-arg baseimage=$BASEIMAGE --build-arg port=$PORT --build-arg maintainer=$MAINTAINER -t $NAME .

rm -rf authorized_keys
