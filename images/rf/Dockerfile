# @xvdp
# intended to be built on top of ../torch/Dockerfile
#
# https://github.com/NVIDIAGameWorks/kaolin/blob/master/tools/linux/Dockerfile.install
# only stuff not set in _torch image

ARG baseimage
FROM ${baseimage}
ARG maintainer=xvdp
LABEL MAINTAINER $maintainer

SHELL ["/bin/bash", "-c"]


USER root


ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

ENV NVIDIA_VISIBLE_DEVICES all

# for GLEW
ENV LD_LIBRARY_PATH /usr/local/cuda/lib64:${LD_LIBRARY_PATH}
ENV IGNORE_TORCH_VER "1"

## Install Dash3D Requirements ###
RUN curl -fsSL https://deb.nodesource.com/setup_16.x --insecure | bash - \
    && apt-get install -y nodejs

USER appuser

ADD --chown=appuser:appuser kaolin kaolin
ADD --chown=appuser:appuser koreto koreto

# USER root
# RUN npm install -g npm@8.5.4 && npm install
# USER appuser

# downgrade pip to < v 23. because of deprecation of install-option used in Makefile, pypa/pip#11858
RUN pip install --no-cache-dir cython flake8 flake8-bugbear flake8-comprehensions flake8-mypy flake8-pyi \
    pytest pytest-cov nbmake pybind11 usd-core ipycanvas ipyevents flask plyfile fastsweep

RUN cd kaolin && pip install --no-cache-dir . && cd .. && rm kaolin -rf
RUN cd koreto && pip install --no-cache-dir . && cd .. && rm koreto -rf

CMD ["/bin/bash"]

