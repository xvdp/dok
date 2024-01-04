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
# installed and removed
ADD --chown=appuser:appuser llama llama
ADD --chown=appuser:appuser whisper whisper
ADD --chown=appuser:appuser newspaper newspaper
# no setup.py file run from folder
ADD --chown=appuser:appuser stanford_alpaca stanford_alpaca
ADD --chown=appuser:appuser OpenVoice OpenVoice


RUN pip install --no-cache-dir fairscale fire sentencepiece tiktoken==0.3.3 \
    whisper/. llama/. newspaper/. && rm -rf whisper newspaper

CMD ["/bin/bash" ]
