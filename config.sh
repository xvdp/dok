#
# General project variables
# Modify to match environment
#

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



# LOCAL or SOURCE VOLUMES # used by ./build.sh scripts
GIT_ROOT=~/work/gits    # folder where gits are cloned to
WEIGHTS_ROOT=/mnt/Data/weights  # folder where project weights should be stored
DATA_ROOT=/mnt/Data/data  # folder where project data should be stored
MAINTAINER=xvdp
DEFAULTUSER="1000"  #ssh precursor creates 1000, 1001, 1002

ASSERT_DIR "${GIT_ROOT}" "Adjust 'GIT_ROOT' in file: ${0}"
ASSERT_DIR "${WEIGHTS_ROOT}" "Adjust 'WEIGHTS_ROOT' in file: ${0}"
ASSERT_DIR "${DATA_ROOT}" "Adjust 'DATA_ROOT' in file: ${0}"


# CACHE ENVS and local paths: Used by ./dockerrun and ./dockerglrun
ENVS=(TORCH_HOME TORCH_EXTENSIONS_DIR DNNLIB_CACHE_DIR HUGGINGFACE_HOME TTS_HOME)
ENV_HOMES=("torch" "torch_extensions" "dnnlib" "huggingface" "tts")

# CONTAINER VOLUMES: used by ./dokrun
WEIGHTS_HOME=/home/weights
DATA_HOME=/home/data
