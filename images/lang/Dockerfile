# @xvdp
# language models sandbox


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
# no setup.py file
ADD --chown=appuser:appuser stanford_alpaca stanford_alpaca

RUN pip install --no-cache-dir fairscale fire sentencepiece tiktoken==0.3.3 \
    whisper/. llama/. newspaper/. && \
    rm -rf whisper newspaper

CMD ["/bin/bash" ]
