#!/bin/bash
# EXAMPLE file hot to add local projects

#
# 1. git clone an installable project, eg, https://github.com/NVlabs/nvdiffrast tp a <parent_folder>
# 2. ./build -b xvdp/cuda_11.8.0-devel-ubuntu22.04_ssh_mamba_torch -i nvdiffrast -r <parent_folder>
# generates -> xvdp/cuda_11.8.0-devel-ubuntu22.04_ssh_torch_diffrast_example:latest
# Dockerfile needs to be modified to `ADD nvdiffrast`

# if more projects need to be passed pass as array -i "${ar[*]}
# Example
# ar=(nvdiffrast, some_other_project)
#./build -b xvdp/cuda_11.8.0-devel-ubuntu22.04_ssh_mamba_torch -i "${ar[*]}"" -r <parent_folder>

# Args
#   -b baseimage  # required: baseimage with OS, Graphic drivers, authorized_keys, etc.
#   -r root       # required: this project defaults to
#   -i projects   # array of folders under root, passed as ar=(project project1) -i "${ar[*]}"
#       must match list of projects in Dockerfile
#   -g gits       # array of gits, if not found as project, clone  ar=(NVlabs/nvdiffrast gituser/project2) -i "${ar[*]}"

# Optional Args
#   -n            # image name -default: basename
#   -m            # maintaner  -default: xvdp
#   -t            # tag        -default: latest


# personal defaults to overwrite or pass with -r ROOT -i "${localprojects[*]}" -g "${githubprojects[*]}" 
ROOT_LOCAL="/home/z/work/gits"
PROJECTS_LOCAL=()
GITS_LOCAL=(NVlabs/nvdiffrast)


if [ $# -eq 0 ]
  then
    echo "docker baseimage required: $ bash build.sh <base_img> [<img_name>]"
    exit
fi

while getopts b:n:m:t:r:i:g: option; do case ${option} in
b) BASEIMAGE=${OPTARG};;
n) NAME=${OPTARG};;       # build name, default: 
m) MAINTAINER=${OPTARG};; # build maintainer, default : xvdp
t) TAG=${OPTARG};;        # build tag, default : latest
r) ROOT=${OPTARG};;       # project root for local installs
i) PROJECTS=(${OPTARG});; # array of pip installabale projects eg. ar=(nvdiffrast mypip) -i "${ar[*]}
g) GITS=(${OPTARG});; # array of pip installabale projects eg. ar=(nvdiffrast mypip) -i "${ar[*]}
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
[ -z $PROJECTS ] && PROJECTS=("${PROJECTS_LOCAL[@]}");
[ -z $GITS ] && GITS=("${GITS_LOCAL[@]}");


# local projects installation # must match Dockerfile ADD instructions
# clone gits to ROOT and include as project
# copy named projects from installation ROOT, install, then clean up
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


NAME=`echo $NAME | cut -d "/" -f 2`  # remove maintainer prefix
NAME=`echo "${NAME//:/$'_'}"`     # remove invalid chars in name ':'
NAME=$MAINTAINER"/"$NAME"_`basename ${PWD}`:$TAG" # add parent folder name _shh

echo BASE_IMAGE=$BASEIMAGE
echo "NAME="$NAME


docker build --build-arg baseimage=$BASEIMAGE --build-arg maintainer=$MAINTAINER -t $NAME .

# cleanup temp projects
for proj in "${PROJECTS[@]}"; do rm -rf "${proj}" ; done
