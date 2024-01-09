# @xvdp
# text to speech sandbox

ARG baseimage
FROM ${baseimage}
ARG maintainer=xvdp
LABEL MAINTAINER $maintainer

SHELL ["/bin/bash", "-c"]


USER appuser

RUN pip install --no-cache-dir librosa==0.9.1 faster-whisper==0.9.0 pydub==0.25.1 eng_to_ipa==0.0.2 inflect==7.0.0 \
    unidecode==1.3.7 python-dotenv pypinyin==0.50.0 cn2an==0.5.22 jieba==0.42.1 gradio==3.48.0 langid==1.1.6

ADD --chown=appuser:appuser whisper-timestamped whisper-timestamped
RUN pip install --no-cache-dir whisper-timestamped/. && rm -rf whisper-timestamped

# no setup.py file run from folder
ADD --chown=appuser:appuser OpenVoice OpenVoice

# get data from repo if it hasnt altready been dowloaded, unzip
RUN cd OpenVoice && \
    if [ ! -d "checkpoints" ]; then \
        if [ ! -f "checkpoints_1226.zip" ]; then \
            wget https://myshell-public-repo-hosting.s3.amazonaws.com/checkpoints_1226.zip; \
        fi && \
        unzip checkpoints_1226.zip && \
        rm checkpoints_1226.zip; \
    fi && cd -

CMD [ "/bin/bash" ]
