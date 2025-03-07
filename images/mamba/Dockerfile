# @xvdp
# modification of https://github.com/conda-forge/miniforge-images/blob/master/ubuntu/Dockerfile to run on 'latest' and take in a base image
# replaces  https://github.com/conda-forge/miniforge/releases/download/${MINIFORGE_VERSION}/Miniforge3-${MINIFORGE_VERSION}-Linux-$(uname -m).sh
# with      https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-$(uname)-$(uname -m).sh"
# installs mamba as root - requires init and activation at non root user level

# could run on specific versions by passing build args
# ARG MAMBA_NAME=Miniforge3
# ARG VERSION=download/23.1.0-1/${MAMBA_NAME}-23.1.0-1

# TODO: extract packages to local cache instead of requiring connection to github for resilience

ARG baseimage
FROM ${baseimage}
ARG maintainer=xvdp
LABEL MAINTAINER $maintainer

ENV CONDA_DIR=/opt/conda
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV PATH=${CONDA_DIR}/bin:${PATH}

USER root
RUN apt-get update > /dev/null && \
    apt-get install --no-install-recommends --yes \
        apt-utils \
        wget bzip2 ca-certificates \
        git \
        # tini \
        > /dev/null && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    wget --no-hsts --quiet "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh" -O /tmp/mamba.sh && \
    /bin/bash /tmp/mamba.sh -b -p ${CONDA_DIR} 

RUN rm /tmp/mamba.sh && \
    conda clean --tarballs --index-cache --packages --yes && \
    find ${CONDA_DIR} -follow -type f -name '*.a' -delete && \
    find ${CONDA_DIR} -follow -type f -name '*.pyc' -delete && \
    conda clean --force-pkgs-dirs --all --yes
RUN echo ". ${CONDA_DIR}/etc/profile.d/conda.sh && conda activate base" >> /etc/skel/.bashrc && \
    echo ". ${CONDA_DIR}/etc/profile.d/conda.sh && conda activate base" >> ~/.bashrc

# add all users permission to install on conda
RUN chmod -R 777 $CONDA_DIR && mamba init
# reopen shell
SHELL ["/bin/bash", "-c"]
RUN source activate

CMD [ "/bin/bash" ]