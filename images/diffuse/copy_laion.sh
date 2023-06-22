#!/bin/bash
# for some reason that I havent traced,
# setting caches for hugging face is not respected while loading the laion model we need
MODEL=models--laion--CLIP-ViT-H-14-laion2B-s32B-b79K
CACHE=huggingface/hub
USER_CACHE=/home/weights
mkdir -p "${HOME}/.cache/${CACHE}"
echo "${USER_CACHE}/${CACHE}/${MODEL}"
if [ -d "${USER_CACHE}/${CACHE}/${MODEL}" ]; then
    cp -r "${USER_CACHE}/${CACHE}/${MODEL}" "${HOME}/.cache/${CACHE}"
fi
