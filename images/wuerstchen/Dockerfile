# @xvdp
# NetEase Face2Face implementation
# https://github.com/xvdp/wuerstchen
# 

ARG baseimage
FROM ${baseimage}
ARG maintainer=xvdp
LABEL MAINTAINER $maintainer

SHELL ["/bin/bash", "-c"]

USER root
RUN apt-get update && apt-get autoremove -y && apt-get clean -y

USER appuser
ADD --chown=appuser:appuser wuerstchen wuerstchen
ADD --chown=appuser:appuser pytorch-tools pytorch-tools
ADD --chown=appuser:appuser set_caches.sh set_caches.sh
ADD --chown=appuser:appuser cache_from_mount.sh cache_from_mount.sh
RUN chmod +x cache_from_mount.sh && chmod +x set_caches.sh && mamba clean -ay

RUN pip install --no-cache-dir open_clip_torch webdataset \
    && cd pytorch-tools && pip install --no-cache-dir . && cd - && rm pytorch-tools -rf

# commented out required installs - present in ./image/torch
# RUN pip install --no-cache-dir transformers warmup_scheduler

CMD ["/bin/bash" ] 
#, "-c", "./cache_from_mount.sh", "&"]
