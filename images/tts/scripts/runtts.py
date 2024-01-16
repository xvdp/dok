import sys
import time
from typing import Union, Optional
import os
import os.path as osp

try:
    import TTS as TTS__init__
    from TTS.api import TTS
    from TTS.utils.manage import ModelManager
    from TTS.utils.synthesizer import Synthesizer
except:
    print("Project deprecated - uncomment from build and Dockerfile if need to test")


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
    assert force or 'TTS_HOME' in os.environ, "force=True to use local cache or set TTS_HOME"
    if manager is None:
        manager = get_manager()
    models = manager.list_models()
    o = {}
    for mod in models:
        model_path, config_path, model_item = manager.download_model(mod)
        o[mod] ={'path': model_path, 'config': config_path, 'item': model_item}
    return o

# ttsm = manager.list_tts_models()
# ttsc = manager.list_vc_models()
# ttsv = manager.list_vocoder_models()
def runtest(fname='lssl.txt',
             path="/home/data/Language",
             reference_wav='Feynman/Feyn_Relativity_10.wav',
             model_name=0, speaker_idx=None, language_idx='en', **kwargs):
    """ runs tts with model 
    """
    manager = get_manager()
    manager.verbose=False
    # /gridcells.txt'
    if not osp.isfile(fname):
        fname = osp.join(path, fname)
        assert osp.isfile(fname), f"reference wav file {fname}  missing"
    if reference_wav is not None and not osp.isfile(reference_wav):
        reference_wav = osp.join(path, reference_wav)
        assert osp.isfile(reference_wav), f"reference wav file {reference_wav}  missing"
    tsm = manager.list_tts_models()
    if isinstance(model_name, int):
        model_name = tsm[model_name%len(tsm)]
    with open(fname, 'r', encoding='utf8') as fi:
        text = fi.read().replace("\n", " ")
    speaker = "" if speaker_idx is None else speaker_idx.replace(" ", "_")
    out_path = lambda name, speaker="": f'{path}/{name.replace("/", "_")}{speaker}.wav'
    run_tts(model_name, text, out_path(model_name, speaker), list_speaker_idxs=True,
            list_language_idxs=True, language_idx=language_idx, reference_wav=reference_wav,
            speaker_idx=speaker_idx, **kwargs)


def run_tts(model_name,
            text,
            out_path,
            pipe_out= sys.stdout, # aplay
            speakers_file_path=None,
            language_ids_file_path=None, manager=None, vocoder_name=None, voice_dir=None,
            encoder_path=None,
            encoder_config_path=False,
            list_speaker_idxs=False,
            speaker_idx=None,
            speaker_wav=None,
            reference_speaker_idx=None,
            reference_wav=None,
            list_language_idxs=False,
            language_idx=None,
            capacitron_style_wav=None,  # Wav path file for Capacitron prosody reference.
            capacitron_style_text=None, # Transcription of the reference
            device='cuda',
            force_refwav=False): # tot force refwav
    """
    language_ids_file_path for multilingual

    voice_dir = Voice dir for tortoise model"
    encoder_path  Path to speaker encoder model file
    encoder_config_path tdout the generated TTS wav file for shell pipe
    peaker ID of the reference_wav speaker (If not provided the embedding will be computed using the Speaker Encoder).",
    reference_speaker_idx = speaker_wav  wav file(s) to condition a multi-speaker TTS model with a Speaker Encoder.

    )capacitron_style_wav", type=str, help="Wav path file for Capacitron prosody reference.", default=None
    capacitron_style_text", type=str, help="Transcription of the reference

    tts_models/multilingual/multi-dataset/xtts_v2  multispeaker multilang
    - requires speaker_idx and language_idx
        ['Claribel Dervla', 'Daisy Studious', 'Gracie Wise', 'Tammie Ema', 'Alison Dietlinde', 'Ana Florence', 'Annmarie Nele', 'Asya Anara', 'Brenda Stern', 'Gitta Nikolina', 'Henriette Usha', 'Sofia Hellen', 
        Tammy Grit', 'Tanja Adelina', 'Vjollca Johnnie', 'Andrew Chipper', 'Badr Odhiambo', 'Dionisio Schuyler',
        'Royston Min', 'Viktor Eka', 'Abrahan Mack', 'Adde Michal', 'Baldur Sanjin', 'Craig Gutsy', 'Damien Black',
        'Gilberto Mathias', 'Ilkin Urbano', 'Kazuhiko Atallah', 'Ludvig Milivoj', 'Suad Qasim', 'Torcull Diarmuid',
        'Viktor Menelaos', 'Zacharie Aimilios', 'Nova Hogarth', 'Maja Ruoho', 'Uta Obando', 'Lidiya Szekeres',
        'Chandra MacFarland', 'Szofi Granger', 'Camilla Holmström', 'Lilya Stainthorpe', 'Zofija Kendrick',
        'Narelle Moon', 'Barbora MacLean', 'Alexandra Hisakawa', 'Alma María', 'Rosemary Okafor', 'Ige Behringer',
        'Filip Traverse', 'Damjan Chapman', 'Wulf Carlevaro', 'Aaron Dreschner', 'Kumar Dahl', 'Eugenio Mataracı', 'Ferran Simen', 'Xavier Hayasaka', 'Luis Moray', 'Marcos Rudaski'])
    ['en', 'es', 'fr', 'de', 'it', 'pt', 'pl', 'tr', 'ru', 'nl', 'cs', 'ar', 'zh-cn', 'hu', 'ko', 'ja', 'hi']

    setpaths( fname=fname, model_name=2, speaker_idx='male-en-2', language_idx='en') -> crap
    setpaths( fname=fname, model_name=2, speaker_idx='male-en-2', language_idx='en', reference_wav=None, speaker_wav="/home/data/Language/Feynman/Feyn_Relativity_10.wav"
    tts_models/multilingual/multi-dataset/xtts_v1.1
    - reqiires speaker_wav and language_idx and speaker_wav - (maeh) 
    ['en', 'es', 'fr', 'de', 'it', 'pt', 'pl', 'tr', 'ru', 'nl', 'cs', 'ar', 'zh-cn', 'ja']

    tts_models/multilingual/multi-dataset/your_tts
        - requires speaker_idx and language_idx
        set speaker_idx: to {'female-en-5': 0, 'female-en-5\n': 1, 'female-pt-4\n': 2, 'male-en-2': 3, 'male-en-2\n': 4, 'male-pt-3\n': 5}
        set language_idx: to {'en': 0, 'fr-fr': 1, 'pt-br': 2}
     setpaths( fname=fname, model_name=2, speaker_idx='male-en-2', language_idx=0) / no
     setpaths( fname=fname, model_name=2, speaker_idx='male-en-2', language_idx='en', reference_wav=None, speaker_wav="/home/data/Language/Feynman/Feyn_Relativity_10.wav") - > crap



    """
    if manager is None:
        manager = get_manager()
    manager.verbose = False
    tts_models = manager.list_tts_models()
    if isinstance(model_name, int):
        model_name = tts_models[model_name%len(tts_models)]
    assert model_name in tts_models, f"model {model_name} not in {tts_models}"

    model_path, config_path, model_item = manager.download_model(model_name)
    tts_path = model_path
    tts_config_path = config_path

    if "default_vocoder" in model_item:
        vocoder_name = model_item["default_vocoder"]

    vocoder_path, vocoder_config_path = None, None
    if vocoder_name:
        vocoder_path, vocoder_config_path, _ = manager.download_model(vocoder_name)

    model_dir = None
    if model_item.get("author", None) == "fairseq" or isinstance(model_item["model_url"], list):
        print(f"model {model_name} uses model dir, no referencewav")
        model_dir = model_path
        tts_path = None
        tts_config_path = None
        vocoder_name = None

    encoder_config_path = None
    vc_path = None
    vc_config_path = None

    synthesizer = Synthesizer(
        tts_path,
        tts_config_path,
        speakers_file_path,
        language_ids_file_path,
        vocoder_path,
        vocoder_config_path,
        encoder_path,
        encoder_config_path,
        vc_path,
        vc_config_path,
        model_dir,
        voice_dir,
    ).to(device)

    if synthesizer.tts_speakers_file and (not speaker_idx and not speaker_wav):
        print(f"set speaker_idx: to {synthesizer.tts_model.speaker_manager.name_to_id}, exiting ")
        return

    try:
        if list_speaker_idxs:
            print(f"set speaker_idx: to {synthesizer.tts_model.speaker_manager.name_to_id}")
    except:
        print(f">>> model {model_name} has no .speaker_manager.name_to_id  function ")
    try:
        if list_language_idxs:
            print(f"set language_idx: to {synthesizer.tts_model.language_manager.name_to_id}")
    except:
        print(f">>> model {model_name} has no .language_manager.name_to_id  function ")


    if tts_path is not None:
        wav = synthesizer.tts(
            text,
            speaker_name=speaker_idx,
            language_name=language_idx,
            speaker_wav=speaker_wav,
            reference_wav=reference_wav,
            style_wav=capacitron_style_wav,
            style_text=capacitron_style_text,
            reference_speaker_name=reference_speaker_idx,
        )
    elif model_dir is not None:
        kw = {}
        if force_refwav and reference_wav is not None:
            kw['reference_wav'] = reference_wav
            #DONT FORCE one SpeakerManager' object has no attribute 'compute_embedding_from_clip'
        wav = synthesizer.tts(
            text,
            speaker_name=speaker_idx,
            language_name=language_idx,
            speaker_wav=speaker_wav,
            **kw)
    synthesizer.save_wav(wav, out_path, pipe_out=pipe_out)
    return out_path
# def models_by_type(manager, model_type):
#     models = manager.list_models()


# def convert_wav(manager, source_wav, target_wav):
#     model_path, config_path, model_item = manager.download_model(model_name)

#     if model_item["model_type"] == "voice_conversion_models":
#         vc_path = model_path
#         vc_config_path = config_path


def load_pretrained(manager, model_name: Union[int, str],
                    vocoder_name: Optional[str] = None,
                    device: str = 'cuda'):
    """
    there are 3 types of models
    tts
    vocoder
    conversion
    """
    models = manager.list_models()
    if isinstance(model_name, int):
        model_name = models[ model_name%len(models) ]
    assert model_name in models, f"pretrained model {model_name} not in\n{models} "

    model_path, config_path, model_item = manager.download_model(model_name)

    # tts model
    if model_item["model_type"] == "tts_models":
        tts_path = model_path
        tts_config_path = config_path
        if "default_vocoder" in model_item and vocoder_name is None:
            vocoder_name =  model_item["default_vocoder"]

    # voice conversion model
    if model_item["model_type"] == "voice_conversion_models":
        vc_path = model_path
        vc_config_path = config_path

    # tts model with multiple files to be loaded from the directory path
    if model_item.get("author", None) == "fairseq" or isinstance(model_item["model_url"], list):
        model_dir = model_path
        tts_path = None
        tts_config_path = None
        vocoder_name = None

    # get vocoder
    if vocoder_name is not None:
        vocoder_path, vocoder_config_path, _ = manager.download_model(vocoder_name)




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
