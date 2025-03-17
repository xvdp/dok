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
ARG TORCH_INSTALL_CMD="pip3 install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/cu128"
ARG userNAME1=z
ARG userNAME2=harveer
ARG userNAME3=srinivasa
LABEL MAINTAINER $maintainer

SHELL ["/bin/bash", "-c"]

USER root
RUN apt-get -yqq update && \
        apt-get install -yq --no-install-recommends ca-certificates expat libgomp1 && \
        apt-get autoremove -y && apt-get clean -y && \
        apt-get install -yq --no-install-recommends apt-utils apt-transport-https software-properties-common \
        pkg-config cmake curl lsof xclip wget nano locate rsync nvtop htop libmpich-dev libxcb-shape0-dev  \
        libglvnd0 libgl1 libglx0 libegl1 libgles2 libglvnd-dev libgl1-mesa-dev libegl1-mesa-dev libgles2-mesa-dev \
        zlib1g-dev libjpeg-dev libwebp-dev libpng-dev libtiff5-dev libopenexr-dev libgdal-dev ffmpeg gnupg2  \
        unzip && apt-get autoremove -y && apt-get clean -y
        # -y python=3.9 libasound2

USER ${userNAME1}

# conda config --add channels pytorch && 
RUN chown ${userNAME1}:${userNAME1} /home/${userNAME1} \
    && conda config --set channel_priority flexible \
    && source activate && mamba init


RUN ${TORCH_INSTALL_CMD}  \
    && mamba install -y ffmpeg plotly h5py jupyter tqdm scikit-learn scikit-image einops matplotlib pybind11 openexr colour-science pyopengl
# RUN pip3 install numpy==${NUMPY_VERSION}


# reopen shell
SHELL ["/bin/bash", "-c"]
# RUN mamba clean -ya

# until the issues between ffmpeg and torchvision are fixed, clone and compile (not in torchvision 16)
# ADD --chown=appuser:appuser nvdiffrast nvdiffrast
# ADD --chown=appuser:appuser vision vision

# mediapipe requires numpy < 2, downgrades to 1.26.4
RUN pip install --upgrade pip && pip install --no-cache-dir opencv-python lmdb mitsuba mediapipe more_itertools pyexr \
    ninja imageio imageio-ffmpeg tb-nightly timm yapf filterpy numba addict tensorboardx \
    diffusers transformers warmup_scheduler mpi4py blobfile usd-core ipycanvas ipyevents\
    imgui pyspng flake8 flake8-bugbear flake8-comprehensions flake8-mypy flake8-pyi glfw \
    cython pytest pytest-cov flask nbmake \
    git+https://github.com/NVlabs/nvdiffrast.git#egg=nvdiffrast

    # vision/.  nvdiffrast/. && rm -rf vision && rm -rf nvdiffrast

# RUN pip install --no-cache-dir nvidia-ml-py

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
