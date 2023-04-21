# downstream docker file installing
# requires a baseimage with OS and cuda ssh torch

ARG baseimage
FROM ${baseimage}
ARG maintainer=xvdp
MAINTAINER $maintainer

SHELL ["/bin/bash", "-c"]

USER appuser
ADD --chown=appuser:appuser nvdiffrast nvdiffrast
ADD --chown=appuser:appuser ubuso ubuso
ADD --chown=appuser:appuser vidi vidi
RUN pip install nvdiffrast/. &&  pip install ubuso/. &&  pip install ubuso/.


CMD ["/bin/bash"]
