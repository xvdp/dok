#
# General project variables
# Modify to match environment
#
source images/utils.sh      # provides functions ASSERT_DIR() ASSERT_FILE(), MAKE_IMAGE_NAME()
GIT_ROOT=~/work/gits    # folder where gits are cloned to
WEIGHTS_ROOT=/mnt/Data/weights  # folder where project weights should be stored
DATA_ROOT=/mnt/Data/data  # folder where project data should be stored
MAINTAINER=xvdp
DEFAULTUSER="1000"  #ssh precursor creates 1000, 1001, 1002

ASSERT_DIR "${GIT_ROOT}" "Adjust 'GIT_ROOT' in file: ${0}"
ASSERT_DIR "${WEIGHTS_ROOT}" "Adjust 'WEIGHTS_ROOT' in file: ${0}"
ASSERT_DIR "${DATA_ROOT}" "Adjust 'DATA_ROOT' in file: ${0}"