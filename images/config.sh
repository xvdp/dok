# General project variables:  Modify to match environment
cd "$(dirname "$0")"

# BASEIMAGE="xvdp/cuda:12.1.0-devel-ubuntu22.04"
BASEIMAGE="xvdp/cuda:11.8.0-devel-ubuntu22.04"
BASEIMAGE="nvidia/cuda:12.1.0-devel-ubuntu22.04"
BASEIMAGE="nvidia/cuda:12.6.3-cudnn-devel-ubuntu24.04"
BASEIMAGE="nvidia/cuda:12.8.0-cudnn-devel-ubuntu24.04"


# LOCAL or SOURCE VOLUMES # used by ./build.sh scripts
GIT_ROOT=~/work/gits    # folder where gits are cloned to
WEIGHTS_ROOT=/mnt/Data/weights  # folder where project weights should be stored
DATA_ROOT=/mnt/Data/data  # folder where project data should be stored
MAINTAINER=xvdp
DEFAULTUSER="1000"  # ssh precursor creates 1000, 1001, 1002
DEFAULTTAG=latest


# CONTAINER VOLUMES: used by ./dokrun
# LOCAL shared folders
WEIGHTS_HOME=/home/weights
DATA_HOME=/home/data

# CACHE ENVS and local paths: Used by ./dockerrun and ./dockerglrun
ENVS=(TORCH_HOME TORCH_EXTENSIONS_DIR DNNLIB_CACHE_DIR HUGGINGFACE_HOME TTS_HOME)
ENV_HOMES=("torch" "torch_extensions" "dnnlib" "huggingface" "tts")
# WHAT ABOUT XDG_CACHE_HOME

######
# Utils
######

ASSERT_DIR () {
    if [ ! -d "${1}" ]; then
        MSG=""
        if [ -n "${2}" ]; then
            MSG=$2
        fi
        echo "FOLDER ${1} not found ${MSG}"
        exit 1
    fi
}

ASSERT_FILE () {
    if [ ! -f "${1}" ]; then
        MSG=""
        if [ -n "${2}" ]; then
            MSG=$2
        fi
        echo "FILE ${1} not found ${MSG}"
        exit 1
    fi
}

MAKE_IMAGE_NAME () {
    # MAKE_IMAGE_NAME $BASEIMAGE $MAINTAINER $PROJECTNAME $TAG
    BASEIMAGE=$1
    MAINTAINER=$2
    PROJECTNAME=$3
    TAG=$4

    OUT=`echo $BASEIMAGE | cut -d "/" -f 2`   # remove maintainer prefix
    OUT=`echo "${OUT//:/$''}"`         # remove ( : . devel- latest )
    OUT=`echo "${OUT//./$''}"`         # remove invalid chars in OUT ':'
    OUT=`echo "${OUT//devel-/$''}"`         
    OUT=`echo "${OUT//latest/$''}"`   
    OUT=$MAINTAINER"/"$OUT"_`basename ${PROJECTNAME}`:$TAG" # 
    echo $OUT
} 

SPLIT_IMAGE() {
    # $1 maintainer/name:tag
    # tag is optional
    # global variable result 
    local imagename="$1"
    local IFS="/"
    result=""
    read -ra parts <<< "$imagename"
    if [ ${#parts[@]} -eq 2 ]; then
        local name="${parts[1]}"
        IFS=":"
        read -ra namesplit <<< "$name"
        if [ ${#namesplit[@]} -eq 1 ]; then
            namesplit+=("latest")
        fi
        result=("${parts[0]}" "${namesplit[@]}")
    fi
}

ASSERT_IMAGE_EXISTS() {
    # check locally and on dockerhub for image
    # $1 maintainer/name:tag
    SPLIT_IMAGE $1
    local MAINTAINER="${result[0]}"
    local NAME="${result[1]}"
    local TAG="${result[2]}"

    local docim=$(docker images | grep $MAINTAINER -w| grep $NAME -w | grep $TAG -w | cut -d " " -f 1)
    if [ $docim ]; then
        echo "${MAINTAINER}/${NAME}:${TAG}  found locally" # Local file found
    elif curl -s -I "https://hub.docker.com/r/${MAINTAINER}/${NAME}/tags?name=${TAG}" | grep "200 OK" > /dev/null; then
        echo "https://hub.docker.com/r/${MAINTAINER}/${NAME}/tags?name=${TAG}"
        echo "${MAINTAINER}/${NAME}:${TAG}   found on docker hub" # remote file found
    else
        echo "FAIL, Expected maintainer/name:tag, got $1 not found" >&2
        return 1
    fi
    return 0
}


LAST() {
    ls -lt $1 | head -n1
}


alias lastfile='f(){ patt=${1:-"*"}; find . -maxdepth 1 -type f -name $patt | sort -t | head -n1; unset -f f; }; f'

ASSERT_DIR "${GIT_ROOT}" "Adjust 'GIT_ROOT' in file: ${0}"
ASSERT_DIR "${WEIGHTS_ROOT}" "Adjust 'WEIGHTS_ROOT' in file: ${0}"
ASSERT_DIR "${DATA_ROOT}" "Adjust 'DATA_ROOT' in file: ${0}"