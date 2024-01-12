

"""

TODO read pdf get footnotes too
"""
def read_clean(fname):
    with open(fname, "r", encoding="utf8") as fi:
        text = fi.read().split("\n")
    return remove_endnumeric(text)

def remove_endnumeric(text):
    for i, line in enumerate(text):
        text[i] = _remove_endnumeric(line)
    return ("\n".join(text)).replace("-\n", "").split("\n")

def _remove_endnumeric(line):
    j=0
    while abs(j-1) <= len(line) and line[j-1].isnumeric():
        j -= 1
    return line[:j if j else None]
