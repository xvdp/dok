# @xvdp # TODO - include in this build - 
# apt install rsync, nvtop, htop    # general mgmt
# apt install libmpich-dev          # torch.distributed (guided-diffusion)
# pip install mpi4py blobfile       # message passing interface (guided-diffusion)
# pip install nvdiffrast/. &&  rm -rf nvdiffrast  # either clone and local or clone in github

# requires a baseimage with ssh, mamba and torch supported OS and cuda, 
# installs apt ffmpeg 4.4, mamba ffmpeg 5.1 torch 2.0 jupyter mitsuba
# ./build.sh -b xvdp/cuda_11.8.0-devel-ubuntu22.04_ssh_mamba

ARG baseimage
FROM ${baseimage}
ARG maintainer=xvdp
LABEL MAINTAINER $maintainer

SHELL ["/bin/bash", "-c"]

USER root
RUN apt-get -yqq update && \
        apt-get install -yq --no-install-recommends ca-certificates expat libgomp1 && \
        apt-get autoremove -y && \
        apt-get clean -y && \
        apt-get install -yq --no-install-recommends ca-certificates expat libgomp1 \
        libxcb-shape0-dev ffmpeg && apt-get autoremove -y && apt-get clean -y

RUN apt-get update && \
    apt-get install -y apt-utils apt-transport-https software-properties-common \
    apt-utils gnupg2 curl lsof xclip wget nano locate libasound2 pkg-config cmake \
    libglvnd0 libgl1 libglx0 libegl1 libgles2 libglvnd-dev libgl1-mesa-dev libegl1-mesa-dev libgles2-mesa-dev \
    zlib1g-dev libjpeg-dev libwebp-dev libpng-dev libtiff5-dev libopenexr-dev libgdal-dev libopenexr-dev \
    libxcb-shape0-dev && apt-get autoremove -y && apt-get clean -y

USER appuser
# install latest ffmpeg, installs py 3.9 due to compatibility issues 
RUN chown appuser:appuser /home/appuser \
    && conda config --add channels pytorch && conda config --set channel_priority flexible \
    && source activate && mamba init && mamba install -y python=3.9 ffmpeg 

# channel_priority strict to install pytorch correctly
RUN conda config --set channel_priority strict \
    && mamba install -y pytorch torchaudio pytorch-cuda=11.8 -c pytorch -c nvidia

# until https://github.com/pytorch/vision/issues/7508 reinstall
RUN conda config --set channel_priority flexible \
    && mamba install -y ffmpeg=5.1.2

RUN mamba install -y plotly h5py jupyter tqdm scikit-learn lmdb einops matplotlib pybind11 \
     openexr colour-science glfw pyopengl

RUN pip install --upgrade pip && pip install mitsuba mediapipe more_itertools pyexr \
    ninja imageio imageio-ffmpeg

# until the issues with ffmpeg are fixd, clone and compile

ADD --chown=appuser:appuser vision vision
RUN cd vision && python setup.py install && cd .. && rm -rf vision

# from https://github.com/NVlabs/nvdiffrast/blob/main/docker/Dockerfile
# for GLEW
ENV LD_LIBRARY_PATH /usr/lib64:$LD_LIBRARY_PATH
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility,graphics
# Default pyopengl to EGL for good headless rendering support
ENV PYOPENGL_PLATFORM egl

# if run with a different exposed port than built into ssh edit the alias in .bashrc
# start jupyter on docker - port will be correct, but ip 0.0.0.0 will need to be edited in browser
RUN echo "alias jupy='jupyter notebook --allow-root -y --no-browser --ip=0.0.0.0 --port=${PORT}'" >> ~/.bashrc
CMD ["/bin/bash"]
