# @xvdp
# diffusion models
# https://github.com/xvdp/wuerstchen
# docker run --user 1000 --name wue --gpus device=0 --cpuset-cpus="14-27" -v /mnt/Data/weights:/home/weights -v /mnt/Data/data:/home/data  --entrypoint /bin/bash --network=host -it --rm xvdp/cuda1180-ubuntu2204_ssh_mamba_torch_wuerstchen

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
ADD --chown=appuser:appuser copy_laion.sh copy_laion.sh
RUN chmod +x cache_from_mount.sh && chmod +x set_caches.sh \
    && chmod +x copy_laion.sh && mamba clean -ay

RUN pip install --no-cache-dir open_clip_torch webdataset \
    && cd pytorch-tools && pip install --no-cache-dir . && cd - && rm pytorch-tools -rf

# commented out required installs - present in ./image/torch
# RUN pip install --no-cache-dir transformers warmup_scheduler

CMD ["/bin/bash" ] 
#, "-c", "./cache_from_mount.sh", "&"]
