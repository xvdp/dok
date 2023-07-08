# @xvdp
# intended to be built on top of ../torch/Dockerfile
# similar to https://github.com/xvdp/stylegan3/blob/main/Dockerfile
# to run visualizer.py start with 
#../dockerglrun --user 1000 --name torch --gpus device=0 --cpuset-cpus=0-10 -it --rm --cache /mnt/Data/weights:/home/weights xvdp/cuda1180-ubuntu2204_ssh_mamba_torch_gans


ARG baseimage
FROM ${baseimage}
ARG maintainer=xvdp
LABEL MAINTAINER $maintainer

SHELL ["/bin/bash", "-c"]

USER root

RUN apt-get -yqq update
RUN apt-get install -yq --no-install-recommends libglvnd0 libgl1 libglx0 libegl1 libgles2 libglvnd-dev \
    libgl1-mesa-dev libegl1-mesa-dev libgles2-mesa-dev zlib1g-dev libjpeg-dev libwebp-dev \
    && apt-get autoremove -y && apt-get clean -y

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
# unset opengl platform, set in torch image to EGL
ENV PYOPENGL_PLATFORM=

USER appuser
ADD --chown=appuser:appuser stylegan3 stylegan3

# ENV DISPLAY 1
# -e DISPLAY=${DISPLAY}
RUN pip install --no-cache-dir imageio imageio-ffmpeg==0.4.4 pyspng==0.1.0 glfw imgui && \
    pip install -U pyopengl==3.1.7

CMD ["/bin/bash"]

