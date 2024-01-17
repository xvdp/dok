"""
install bark from github
pip install git+https://github.com/suno-ai/bark.git
Example from README.md
more examples in ipynb inside bark

speakers and languages
https://suno-ai.notion.site/8b8e8749ed514b0cbf3f699013548683?v=bc67cff786b04b50b3ceb756fd05f68c
 10 speakers per language on 


silence = np.zeros(int(0.5*SAMPLE_RATE))
for line in script:
    speaker, text = line.split(": ")
    audio_array = generate_audio(text, history_prompt=speaker_lookup[speaker], )
    pieces += [audio_array, silence.copy()]

 speaker_lookup = {"Samantha": "v2/en_speaker_9", "John": "v2/en_speaker_2"}

import bark
bark.generation.SUPPORTED_LANGS
'es' in [l[1] for l in bark.generation.SUPPORTED_LANGS]

"""
import sys
import time
import os
import os.path as osp
import numpy as np
from scipy.io.wavfile import write as write_wav
# pylint: disable=import-error
import bark
from bark import SAMPLE_RATE, generate_audio, preload_models

from cleanlines import read_clean

# environments added inside .dockerrun
if not 'XDG_CACHE_HOME' in os.environ:
    print('XDG_CACHE_HOME not os.environ, models will dowloaded to .local/')

DATA_HOME = os.environ['DATA_HOME'] if 'DATA_HOME' in os.environ['HOME'] else os.environ['HOME']
if not 'DATA_HOME' in os.environ:
    print(f"DATA_HOME not found default saving dir set to os.environ['HOME'] {DATA_HOME}")

def makename(name='bark_gen.wav', speaker=6, language='en'):
    langs = [l[1] for l in bark.generation.SUPPORTED_LANGS]
    assert language in langs, f"{language} not in {langs}"
    name = f"_{language}_speaker{speaker}".join(osp.splitext(name))
    return name


def run_installed_bark(text=osp.abspath(osp.join(osp.dirname(__file__),"../abstracts/audiolm_abs.txt")),
                       out_folder=f"{DATA_HOME}/Language",
                       name="bark_reading_audiolm_abs.wav",
                       speaker=6, language="en",
                       parse_sentences=True):
    """
    Args
        text            (str) text or filename
        out_folder      (str)
        name            (str)
        speaker         (int [6]) (0-9) are valid
        language        (str ['en']) in bark.generation.SUPPORTED_LANGS
        parse_sentence  (bool [True]), if True, genertes one sentence at a time, if false, all at once.
            True is better unless context is very small sentences
    """
    os.makedirs(out_folder, exist_ok=True)
    assert os.path.isdir(out_folder), f"{out_folder} not found, create then run"
    name = makename(name, speaker, language)

    if isinstance(speaker, int):
        speaker = f"v2/{language}_speaker_{speaker}"
    text = read_clean(text, parse_sentences=parse_sentences)
    print(f"generating audio {name} for text \n{text}\n\npreloading models")
    preload_models()

    if isinstance(text, str):
        text = [text]
    nbwords = sum([len(t.split()) for t in text])
    _start = time.time()

    audio = []

    print("generating audio")
    for i, sent in enumerate(text):
        audio += [generate_audio(sent,  history_prompt=speaker)]
        if i < len(text): # .25 +o- 0.1s of silence
            audio += [np.zeros(int(0.15 + np.random.rand()*.2 * SAMPLE_RATE))]
    audio = np.concatenate(audio)

    print(f"writing {name}")
    print(f" processed {nbwords} in {round(time.time()-_start)} seconds")
    write_wav(os.path.join(out_folder, name), SAMPLE_RATE, audio)


    return audio



def run_from_transformers(text, out_folder=f"{DATA_HOME}/Language", voice_preset = "v2/en_speaker_6",  name="bark_generation.wav"):
    """ from huggingface transformers    
    """
    # pylint: disable=import-outside-toplevel
    # pylint: disable=no-name-in-module
    from transformers import AutoProcessor, BarkModel
    os.makedirs(out_folder, exist_ok=True)
    name = voice_preset.replace("/", "_").join(osp.splitext(name))
    print(f"generating audio {name} for text \n{text} with transformers\n\npreloading models")

    processor = AutoProcessor.from_pretrained("suno/bark")
    model = BarkModel.from_pretrained("suno/bark")
    inputs = processor(text, voice_preset=voice_preset)
    print("generating audio")
    audio_array = model.generate(**inputs)
    audio_array = audio_array.cpu().numpy().squeeze()
    print("writing wav")
    write_wav(os.path.join(out_folder, name), SAMPLE_RATE, audio_array)
    return audio_array

if __name__ == '__main__':

    # usage   $ python runbark.py <text> <out_folder> <out_name
    # TEXT = """Understanding the neural code in the brain has long been driven by studying feed-forward architec-
    # tures, starting from Hubel and Wiesel’s famous proposal on the origin of orientation selectivity in
    # primary visual cortex"""

    TEXT = osp.abspath(osp.join(osp.dirname(__file__),"../abstracts/audiolm_abs.txt"))
    OUT_FOLDER = f"{DATA_HOME}/Language"
    OUT_NAME = f"barkreading_{osp.splitext(osp.basename(TEXT))[0]}.wav"


    if len(sys.argv) > 1 and sys.argv[1] != "_":
        TEXT = sys.argv[1]
    if len(sys.argv) > 2 and sys.argv[2] != "_":
        OUT_FOLDER = sys.argv[2]
    if len(sys.argv) > 3:
        OUT_NAME = sys.argv[3]

    run_installed_bark(TEXT, OUT_FOLDER, OUT_NAME)
    run_from_transformers(TEXT, OUT_FOLDER)
