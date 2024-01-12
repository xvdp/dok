# @xvdp
# text to speech sandbox

ARG baseimage
FROM ${baseimage}
ARG maintainer=xvdp
LABEL MAINTAINER $maintainer

SHELL ["/bin/bash", "-c"]


USER appuser

ADD --chown=appuser:appuser TTS TTS
ADD --chown=appuser:appuser bark bark
RUN pip install --no-cache-dir TTS/. bark/.


CMD [ "/bin/bash" ]
