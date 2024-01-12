
from typing import Union, Optional
from pathlib import Path
import os
import os.path as osp

import TTS as TTS__init__
from TTS.api import TTS
from TTS.utils.manage import ModelManager
from TTS.utils.synthesizer import Synthesizer

def get_path():
    path = osp.join(osp.dirname(TTS__init__.__file__), ".models.json")
    return path

def get_manager(path=None, progress_bar=True):
    if path is None:
        path = get_path()
    manager = ModelManager(path, progress_bar=progress_bar)
    return manager

def cmds(manager):
    print(f"manager.list_models() {manager.list_modles()}")
    print("manager.model_info_by_full_name()")

def download_all(manager: Optional[ModelManager] = None,
                 force: bool = False):
    """ downloads all models to local cache

    [m for m in models if 'vocoder' in m]

    ['model_type']s    {'vocoder_models', 'tts_models', 'voice_conversion_models'}

    models without config
    ['tts_models/multilingual/multi-dataset/xtts_v2',
    'tts_models/multilingual/multi-dataset/xtts_v1.1',
    'tts_models/multilingual/multi-dataset/bark',
    'tts_models/en/multi-dataset/tortoise-v2']

    """
    assert force or 'TTS_HOME' in os.environ, "either force=True to download to local cache or set TTS_HOME path"
    if manager is None:
        manager = get_manager()
    models = manager.list_models()
    o = {}
    for mod in models:
        model_path, config_path, model_item = manager.download_model(mod)
        o[mod] ={'path': model_path, 'config': config_path, 'item': model_item}
    return o


def load_pretrained(manager, model_name: Union[int, str], vocoder_name: Optional[str] = None):
    models = manager.list_models()
    if isinstance(model_name, int):
        model_name = models[ model_name%len(models) ]
    assert model_name in models, f"pretrained model {model_name} not in\n{models} "

    model_path, config_path, model_item = manager.download_model(model_name)

    if model_item['default_vocoder'] and vocoder_name is not None:
        vocoder_name = model_item['default_vocoder']

    vocoder_path = vocoder_config_path = None
    if vocoder_name is not None:
        vocoder_path, vocoder_config_path, _ = manager.download_model(vocoder_name)


    #TODO COMPLETE
    # synthesizer = Synthesizer(
    #     tts_path,
    #     tts_config_path,
    #     speakers_file_path,
    #     language_ids_file_path,
    #     vocoder_path,
    #     vocoder_config_path,
    #     encoder_path,
    #     encoder_config_path,
    #     vc_path,
    #     vc_config_path,
    #     model_dir,
    #     args.voice_dir,
    # ).to(device)

    #         # tts model
    #         if model_item["model_type"] == "tts_models":
    #             tts_path = model_path
    #             tts_config_path = config_path
    #             if "default_vocoder" in model_item:
    #                 args.vocoder_name = (
    #                     model_item["default_vocoder"] if args.vocoder_name is None else args.vocoder_name
    #                 )

    #         # voice conversion model
    #         if model_item["model_type"] == "voice_conversion_models":
    #             vc_path = model_path
    #             vc_config_path = config_path

    #         # tts model with multiple files to be loaded from the directory path
    #         if model_item.get("author", None) == "fairseq" or isinstance(model_item["model_url"], list):
    #             model_dir = model_path
    #             tts_path = None
    #             tts_config_path = None
    #             args.vocoder_name = None
