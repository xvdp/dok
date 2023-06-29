## this should install Mamba in ones current environmnet
## uncomment comments with #* to clean up: 
# apt caches

MAMBA_NAME=Mambaforge
VERSION=latest/download/${MAMBA_NAME}
CONDA_DIR=/opt/conda
export PATH=${CONDA_DIR}/bin:${PATH}

sudo apt-get update > apt-get install --no-install-recommends --yes wget bzip2 ca-certificates git tini 
#* sudo apt-get clean && rm -rf /var/lib/apt/lists/*

wget --no-hsts --quiet https://github.com/conda-forge/miniforge/releases/${VERSION}-$(uname)-$(uname -m).sh -O /tmp/mamba.sh
bash /tmp/mamba.sh -b -p ${CONDA_DIR} 

rm /tmp/mamba.sh
    
#* conda clean --tarballs --index-cache --packages --yes 
#* find ${CONDA_DIR} -follow -type f -name '*.a' -delete 
#* find ${CONDA_DIR} -follow -type f -name '*.pyc' -delete
#* conda clean --force-pkgs-dirs --all --yes

echo ". ${CONDA_DIR}/etc/profile.d/conda.sh && conda activate base" >> /etc/skel/.bashrc && \
echo ". ${CONDA_DIR}/etc/profile.d/conda.sh && conda activate base" >> ~/.bashrc

# add all users permission to install on conda
RUN chmod -R 777 $CONDA_DIR && mamba init
# reopen shell
