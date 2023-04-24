# @xvdp
# installs torch jupyter mitsuba
# requires a baseimage with ssh, mamba and torch supported OS and cuda, 
# ./build.sh -b xvdp/cuda_11.8.0-devel-ubuntu22.04_ssh_mamba

ARG baseimage
FROM ${baseimage}
ARG maintainer=xvdp
LABEL MAINTAINER $maintainer

SHELL ["/bin/bash", "-c"]

USER root
RUN apt-get update && apt-get install -y apt-utils apt-transport-https software-properties-common \
apt-utils gnupg2 curl lsof xclip wget nano locate libasound2 pkg-config cmake \
libglvnd0 libgl1 libglx0 libegl1 libgles2 libglvnd-dev libgl1-mesa-dev libegl1-mesa-dev libgles2-mesa-dev \
zlib1g-dev libjpeg-dev libwebp-dev libpng-dev libtiff5-dev libopenexr-dev libgdal-dev libopenexr-dev
# && rm -rf /var/lib/apt/lists/* 

USER appuser
RUN chown appuser:appuser /home/appuser

# needs baseimage with mamba installation
RUN conda config --add channels pytorch && conda config --set channel_priority strict && source activate && mamba init
# it is not reccomented to overwrite (base) instead create an environemnt... but for now we do it
# with later versions of pytorch and packages this could be removed, or an environment added
RUN mamba install -y python=3.9

RUN mamba install -y pytorch torchvision torchaudio pytorch-cuda=11.8 -c pytorch -c nvidia
RUN mamba install -y plotly h5py jupyter tqdm scikit-learn lmdb einops matplotlib pybind11 \
openexr colour-science glfw pyopengl imageio imageio-ffmpeg \
&& pip install --upgrade pip && pip install mitsuba mediapipe more_itertools pyexr ninja

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
