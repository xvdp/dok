"""
install bark from github
pip install git+https://github.com/suno-ai/bark.git
"""
from bark import SAMPLE_RATE, generate_audio, preload_models
from scipy.io.wavfile import write as write_wav
from IPython.display import Audio

text= """A recent theoretical emphasis on complex interactions within
neural systems underlying consciousness has been accompanied by
proposals for the quantitative characterization of these interac-
tions. In this article, we distinguish key aspects of consciousness
that are amenable to quantitative measurement from those that
are not. """
from scipy.io.wavfile import write as write_wav
from IPython.display import Audio
preload_models()
import os

print('XDG_CACHE_HOME' in os.environ)

text = """Understanding the neural code in the brain has long been driven by studying feed-forward architec-
tures, starting from Hubel and Wiesel’s famous proposal on the origin of orientation selectivity in
primary visual cortex"""
audio_array = generate_audio(text)
write_wav("/home/data/Language/bark_generation.wav", SAMPLE_RATE, audio_array)

import transformers
from transformers import AutoProcessor, BarkModel
processor = AutoProcessor.from_pretrained("suno/bark")
model = BarkModel.from_pretrained("suno/bark")
voice_preset = "v2/en_speaker_6"
inputs = processor(text, voice_preset=voice_preset)
audio_array = model.generate(**inputs)
audio_array = audio_array.cpu().numpy().squeeze()
write_wav("/home/data/Language/bark_generation_6.wav", SAMPLE_RATE, audio_array)

