# @xvdp
#TODO add cython
# run example:
# docker run --user 1000 --name torch --gpus device=1 --cpuset-cpus="14-27" -v /mnt/Data/weights:/home/weights -v /mnt/Data/data:/home/data  --network=host -it --rm xvdp/cuda1180-ubuntu2204_ssh_mamba_torch

# requires a baseimage with ssh, mamba and torch supported OS and cuda, 
# installs apt ffmpeg 4.4, mamba ffmpeg 5.1 torch >= 2.0 jupyter mitsuba nvdiffrast
# ./build.sh -b xvdp/cuda1180-ubuntu2204_ssh_mamba

ARG baseimage
FROM ${baseimage}
ARG maintainer=xvdp
LABEL MAINTAINER $maintainer

SHELL ["/bin/bash", "-c"]

USER root
RUN apt-get -yqq update && \
        apt-get install -yq --no-install-recommends ca-certificates expat libgomp1 && \
        apt-get autoremove -y && apt-get clean -y && \
        apt-get install -yq --no-install-recommends apt-utils apt-transport-https software-properties-common \
        pkg-config cmake curl lsof xclip wget nano locate rsync nvtop htop libmpich-dev libxcb-shape0-dev  \
        libglvnd0 libgl1 libglx0 libegl1 libgles2 libglvnd-dev libgl1-mesa-dev libegl1-mesa-dev libgles2-mesa-dev \
        zlib1g-dev libjpeg-dev libwebp-dev libpng-dev libtiff5-dev libopenexr-dev libgdal-dev ffmpeg gnupg2 libasound2 \
        unzip && apt-get autoremove -y && apt-get clean -y

USER appuser

RUN chown appuser:appuser /home/appuser \
    && conda config --add channels pytorch && conda config --set channel_priority flexible \
    && source activate && mamba init && mamba install -y python=3.9 ffmpeg 

# channel_priority strict to install pytorch correctly
RUN conda config --set channel_priority strict \
    && mamba install -y pytorch torchaudio pytorch-cuda=11.8 -c pytorch -c nvidia

# until https://github.com/pytorch/vision/issues/7508 reinstall
RUN conda config --set channel_priority flexible \
    && mamba install -y ffmpeg=5.1.2 plotly h5py jupyter tqdm scikit-learn scikit-image einops matplotlib pybind11 \
    openexr colour-science pyopengl && mamba clean -ya

# until the issues between ffmpeg and torchvision are fixd, clone and compile
ADD --chown=appuser:appuser vision vision
ADD --chown=appuser:appuser nvdiffrast nvdiffrast

RUN pip install --upgrade pip && pip install --no-cache-dir lmdb mitsuba mediapipe more_itertools pyexr \
    ninja imageio imageio-ffmpeg tb-nightly timm yapf filterpy numba addict tensorboardx \
    diffusers transformers warmup_scheduler mpi4py blobfile usd-core ipycanvas ipyevents\
    imgui pyspng flake8 flake8-bugbear flake8-comprehensions flake8-mypy flake8-pyi glfw \
    cython pytest pytest-cov flask nbmake \
    vision/.  nvdiffrast/. && rm -rf vision && rm -rf nvdiffrast

    
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
