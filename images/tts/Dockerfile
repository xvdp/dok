# @xvdp
# text to speech sandbox

ARG baseimage
FROM ${baseimage}
ARG maintainer=xvdp
LABEL MAINTAINER $maintainer

SHELL ["/bin/bash", "-c"]


USER appuser

# ADD --chown=appuser:appuser TTS TTS # DEPRECATED does not make sense pip install TTS/.
ADD --chown=appuser:appuser bark bark
ADD --chown=appuser:appuser scripts scripts
ADD --chown=appuser:appuser README.md README.md
ADD --chown=appuser:appuser FastSpeech FastSpeech
ADD --chown=appuser:appuser SpeechSynthesis SpeechSynthesis
ADD --chown=appuser:appuser audiolm-pytorch audiolm-pytorch


    
RUN pip install --no-cache-dir bark/. FastSpeech/. audiolm-pytorch/. nltk && \
    python -c "import nltk; nltk.download('punkt')"

# speech synthesis is not installed as it uses older version of librosa
# what about - try
# tacotron2 = torch.hub.load('NVIDIA/DeepLearningExamples:torchhub', 'nvidia_tacotron2', model_math='fp16')>>> tacotron2 = torch.hub.load('NVIDIA/DeepLearningExamples:torchhub', 'nvidia_tacotron2', model_math='fp16')
# ?

CMD [ "/bin/bash" ]
