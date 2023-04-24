# downstream docker file installing
# requires a baseimage with OS and cuda ssh torch

ARG baseimage
FROM ${baseimage}
ARG maintainer=xvdp
LABEL MAINTAINER $maintainer

SHELL ["/bin/bash", "-c"]

USER appuser
ADD --chown=appuser:appuser nvdiffrast nvdiffrast
RUN pip install nvdiffrast/.

CMD ["/bin/bash"]
