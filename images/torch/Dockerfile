# @xvdp
# installs torch jupyter mitsuba
# requires a baseimage with ssh, mamba and torch supported OS and cuda, 
# ./build.sh -b xvdp/cuda_11.8.0-devel-ubuntu22.04_ssh_mamba

ARG baseimage
FROM ${baseimage}
ARG maintainer=xvdp
MAINTAINER $maintainer

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

RUN mamba install -y pytorch torchvision torchaudio pytorch-cuda=11.8 -c pytorch -c nvidia \
&& mamba install -y ninja plotly h5py jupyter tqdm scikit-learn lmdb einops matplotlib pybind11 \
openexr colour-science glfw pyopengl imageio imageio-ffmpeg \
&& pip install --upgrade pip && pip install mitsuba mediapipe more_itertools pyexr

# from https://github.com/NVlabs/nvdiffrast/blob/main/docker/Dockerfile
# for GLEW
ENV LD_LIBRARY_PATH /usr/lib64:$LD_LIBRARY_PATH
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility,graphics
# Default pyopengl to EGL for good headless rendering support
ENV PYOPENGL_PLATFORM egl

# TODO ninja from mamba fails!? install as pip, next time a full rebuild is needed, remove from mamba, split pytorch from the other installs
RUN pip install ninja
# if run with a different exposed port than which it is built edit the alias in .bashrc
RUN echo "alias jupy='jupyter notebook --allow-root -y --no-browser --ip=0.0.0.0 --port=${PORT}'" >> ~/.bashrc
CMD ["/bin/bash"]

# ENTRYPOINT ["sh", "-c", "jupyter notebook --allow-root -y --no-browser --ip=0.0.0.0 --port=$PORT"]

# to ovwerwrite entrypoint on run --entrypoint /bin/bash or -entrypoint python

# docker run --gpus all -it --entrypoint /bin/bash -v /mnt/share:/home/share -p 8888:8888 --rm xvdp/cuda_11.8.0-devel-ubuntu22.04_ssh_torch:latest

# docker run --gpus all -it -p 8888:8888 -v /mnt/share:/home/share --rm xvdp/cuda_11.8.0-devel-ubuntu22.04_ssh_torch:latest

# $ docker run --gpus all -it -v /mnt/share:/home/share --entrypoint /bin/bash -p 32778:32778 --rm xvdp/cuda_11.8.0-devel-ubuntu22.04_ssh_torch:latest
# > jupyter notebook --allow-root -y --no-browser --ip 0.0.0.0 --port 32778

# docker run --gpus all -it -v /mnt/share:/home/share --entrypoint /bin/bash -p 5678:5678 --rm xvdp/cuda_11.8.0-devel-ubuntu22.04_ssh_torch:latest
# > jupyter notebook --allow-root -y --no-browser --ip 0.0.0.0 --port 5678 

# ./build.sh -b xvdp/cuda_11.8.0-devel-ubuntu22.04_ssh
# docker run --gpus all -it --entrypoint /bin/bash -v /mnt/share:/home/share --rm xvdp/cuda_11.8.0-devel-ubuntu22.04_ssh_torch:latest
# docker run --gpus all -it -p 8888:8888 -v /mnt/share:/home/share --rm xvdp/cuda_11.8.0-devel-ubuntu22.04_ssh_torch:latest

# -p 0.0.0.0:8888:8888 opens port 8888
# nmap localhost -p 8888
# 8888/tcp open  sun-answerbook

# docker run --gpus all -it -v /mnt/share:/home/share --rm -p 0.0.0.0:8888:8888 xvdp/cuda_11.8.0-devel-ubuntu22.04_ssh_torch:latest
# 68056c8f8628   xvdp/cuda_11.8.0-devel-ubuntu22.04_ssh_torch:latest   "sh -c 'jupyter note…"   3 seconds ago   Up 3 seconds   0.0.0.0:8888->8888/tcp, 32778/tcp   heuristic_roentgen

# docker run --gpus all -it -v /mnt/share:/home/share --rm -p 8888:8888 xvdp/cuda_11.8.0-devel-ubuntu22.04_ssh_torch:latest
# f97010573c00   xvdp/cuda_11.8.0-devel-ubuntu22.04_ssh_torch:latest   "sh -c 'jupyter note…"   7 seconds ago   Up 6 seconds   0.0.0.0:8888->8888/tcp, :::8888->8888/tcp, 32778/tcp   relaxed_pike


# docker run --gpus all -it -v /mnt/share:/home/appuser/share -p 32778:32778 --rm xvdp/cuda_11.8.0-devel-ubuntu22.04_ssh_mamba_torch_face:latest

# --entrypoint /bin/bash
# --entrypoint python


# -v /mnt/share:/home/appuser/share 
# --user=1000
# --group-add $(getent group docker | cut -d: -f3) 

# --gpus all
# --gpus device=0
# --gpus device=1

# --cpuset-cpus="0-25"
# --cpuset-cpus="26-52"
# --cpus=0.5 # 50% of cpu time
