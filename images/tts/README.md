# Text To Speech Models



1. https://github.com/suno-ai/bark
Fast, easy to run experimental code mage includes script adapted from their README example `$python scripts/runbark.py`.  Bark cites:
* Borsos et al 2022 [AudioLM: a Language Modeling Approach to Audio Generation](https://arxiv.org/abs/2209.03143)  and implementation https://github.com/lucidrains/audiolm-pytorch 
* Wang et al 2023 [Neural Codec Language Models are Zero-Shot Text to Speech Synthesizers](https://arxiv.org/abs/2301.02111) https://github.com/facebookresearch/encodec
* https://github.com/karpathy/nanoGPT 


Example
```python
cd scripts && python
from runbark  import *
audio = run_installed_bark(name="FastSpeech_Abstract.wav", text="/home/data/Language/fastspeech_abs.txt", parse_sentences=True)
```


2. Nvidia Deep Learning examples
/work/gits/NN/DeepLearningExamples/CUDA-Optimized/FastSpeech
* Ren et al 2019, [FastSpeech: Fast, Robust and Controllable Text to Speech](https://arxiv.org/pdf/1905.09263.pdf), examples https://speechresearch.github.io/fastspeech/


3. FastSpeech2
https://github.com/ming024/FastSpeech2
* Ren et al 2022 [FASTSPEECH 2: FAST AND HIGH-QUALITY END-TO-END TEXT TO SPEECH](https://arxiv.org/pdf/2006.04558.pdf)

* FastSpeech2 tests from transformers and fairseq https://huggingface.co/facebook/fastspeech2-en-ljspeech 
    `python run scripts/run_hugfastspeech2.py`

## DEPRECATED - codes still in build and Dockerfile uncomment if appear useful
3. https://github.com/coqui-ai/TTS. Collection of vocoders, converters, and audio models. Messy programming, unclear parameters and results. Keeping it here just in case one of the models results in something useful. Unless it gets any clearner: deprecate
