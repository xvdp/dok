#!/bin/bash

ASSERT_DIR () {
    if [ ! -d "${1}" ]; then
        echo "FOLDER ${1} not found"
        exit 1
    fi
}

ASSERT_FILE () {
    if [ ! -f "${1}" ]; then
        echo "FILE ${1} not found"
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

