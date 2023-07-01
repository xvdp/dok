# @xvdp
# diffusion models
# https://github.com/xvdp/wuerstchen
# docker run --user 1000 --name wue --gpus device=0 --cpuset-cpus="14-27" -v /mnt/Data/weights:/home/weights -v /mnt/Data/data:/home/data  --entrypoint /bin/bash --network=host -it --rm xvdp/cuda1180-ubuntu2204_ssh_mamba_torch_wuerstchen

ARG baseimage
FROM ${baseimage}
ARG maintainer=xvdp
LABEL MAINTAINER $maintainer

SHELL ["/bin/bash", "-c"]


USER appuser
ADD --chown=appuser:appuser llama llama
ADD --chown=appuser:appuser whisper whisper

RUN pip install --no-cache-dir fairscale fire sentencepiece tiktoken==0.3.3 \
    &&  ip install --no-cache-dir whisper/. && rm -rf whisper

CMD ["/bin/bash" ]
