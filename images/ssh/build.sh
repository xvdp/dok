#!/bin/bash
# generic build script for ssh/Dockerfile with  3 users appuser, appuser1 appuser2 exposing port 
# create ssh_key then add id_rsa.pub into authorized_keys folder 
#
#   $ cat id_rsa.pub >> authorized_keys
#
# REQUIRES baseimage arg
# REQUIRES folder with authorized_keys (either ~/.ssh or passed with -r <folder>,)

# Examples
# ./build.sh -b nvidia/cuda:11.8.0-devel-ubuntu22.04 -r $AUTH_ROOT
# creates -> xvdp/cuda1180-ubuntu2204:latest
# ./build.sh -b nvidia/cuda:11.8.0-devel-ubuntu22.04
# creates -> xvdp/cuda1180-ubuntu2204:latest using ~/.shh/authorized_keys

# bashrc file in ssh/ is generic for shell preferences, can be replaced

# kwargs
#  -b (baseimage)           # REQUIRED

# optional
#  -r (root)                # default: ~/.shh folder with files 'authorized_keys'
#  -n (output image name)   # default: maintainer/baseimage_shh:tag
#  -m (maintainer)          # default: xvdp
#  -t (tag)                 # default: latest
#  -p (port)                # default: 32778  # port to be exposed, needs to be opened in the server as well

source ../config.sh
# source ../utils.sh

# defaults
ROOT=~/.ssh   # overwrite or pass -r <valid folder with authorized_keys file>
PORT=32778
MAINTAINER="xvdp"
TAG="latest"
DOCKERGID=$( cat /etc/group | grep docker | cut -d: -f 3)

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
d) DOCKERGID=${OPTARG};;       # folder with authorized_keys file
esac; done

if [ -z $DOCKERGID ]; then
    echo "no docker group found (cat /etc/group | grep docker), or passed with arg -d DOCKERGID;"
    exit
fi

# this is crap code - baseimage can be passed as arg or optarg!
if [ -z $BASEIMAGE ]; then
    echo "no base image supplied using arg $1"
    BASEIMAGE=$1
fi

ASSERT_IMAGE_EXISTS $BASEIMAGE 

# [ -z $NAME ] && NAME=$BASEIMAGE;

if [ ! -d "${ROOT}" ]; then
  echo pass valid -r ROOT kwarg .authorized_keys are found
  exit
fi


echo "${ROOT}/authorized_keys"
if [ -f "${ROOT}/authorized_keys" ]; then
  cp -rf "${ROOT}/authorized_keys" .
else
    echo "${ROOT}/authorized_keys not found, building ${NAME} without authorized_keys .."
    exit
fi

NAME=$(MAKE_IMAGE_NAME $BASEIMAGE $MAINTAINER $PWD $TAG)

echo "BASEIMAGE       ${BASEIMAGE} "
echo "MAINTAINER      ${MAINTAINER} "
echo "TAG             ${TAG} "
echo "OUT IMAGE:      ${NAME}"

docker build --build-arg baseimage=$BASEIMAGE --build-arg port=$PORT --build-arg maintainer=$MAINTAINER --build-arg dockerGID=$DOCKERGID -t $NAME .

# docker build --build-arg baseimage=$BASEIMAGE --build-arg maintainer=$MAINTAINER -t $NAME .

rm -rf authorized_keys

#--build-arg userGIDS="${USERGIDS}" 

# check users             cat /etc/passwd
# current user            id -u
# current user groups     id -G
# docker group users      getent group docker