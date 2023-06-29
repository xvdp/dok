# @xvdp
# intended to be built on top of ../torch/Dockerfile
# https://github.com/xvdp/stylegan3/blob/main/Dockerfile


ARG baseimage
FROM ${baseimage}
ARG maintainer=xvdp
LABEL MAINTAINER $maintainer

SHELL ["/bin/bash", "-c"]

USER root

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV DISPLAY 1

USER appuser

ADD --chown=appuser:appuser stylegan3 stylegan3


RUN pip install --no-cache-dir imageio imageio-ffmpeg pyspng glfw


# -e DISPLAY=${DISPLAY}


CMD ["/bin/bash"]

