

"""
TODO read pdf get footnotes too
"""
from typing import Union
import os.path as osp
import nltk


def read_clean(text: str,
               end_numeric: bool = False,
               clean_endlines: bool = True,
               parse_sentences: bool = True) -> Union[str, list]:
    """ 
    Args
        text (str) filename or text
        end_numeric (bool [False]) / removes line numbers on files containing them
        clean_endlines (bool [True]) / joins words split by hyphen
        parse_sentences (bool [True]) returns list of sentences
    """
    if osp.isfile(text):
        with open(text, "r", encoding="utf8") as fi:
            text = fi.read()
    if end_numeric:
        text = "\n".join(remove_endnumeric(text.split("\n")))
    if clean_endlines:
        text = text.replace("-\n", "").replace("\n", " ")
    if parse_sentences:
        text = nltk.sent_tokenize(text)
    return text


def remove_endnumeric(text):
    """ for line numbered pdfs
    """
    for i, line in enumerate(text):
        text[i] = _remove_endnumeric(line)
    return text

def _remove_endnumeric(line):
    j=0
    while abs(j-1) <= len(line) and line[j-1].isnumeric():
        j -= 1
    return line[:j if j else None]
