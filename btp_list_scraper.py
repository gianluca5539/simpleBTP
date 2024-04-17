import time
import requests
import re


def to_dict(matches):
    res = {}
    # find the BTP, number and date
    for match in matches:
        match = match.lower()
        if match.startswith("btp"):
            res["btp"] = match
        if match.startswith("cedola"):
            split = match.split(" ")
            if len(split) > 1:
                res["cedola"] = split[1]
        if match.startswith("scadenza"):
            res["scadenza"] = match.split(" ")[1]
        if match.startswith("ultimo"):
            split = match.split(" ")
            if len(split) > 1:
                res["ultimo"] = match.split(" ")[1]

    return res


page = 1
raw_count = 0
isin_dict = {}

while True:
    start = 0
    t_isin_list = []

    start_timestamp = time.time()
    url = f"https://www.borsaitaliana.it/borsa/obbligazioni/mot/btp/lista.html?lang=it&page={page}"
    text = requests.get(url).text
    print(f"Page {page} ({time.time() - start_timestamp:.2f}s):", end=" ")

    # find list of strings that start with IT000 and have 12 characters
    while (i := text.find("IT000", start)) != -1:
        isin = text[i : i + 12]
        if isin not in t_isin_list:
            t_isin_list.append(isin)
        start = i + 12

    print(f"found {len(t_isin_list)} ISINs")
    raw_count += len(t_isin_list)

    for i in range(len(t_isin_list)):
        isin_start = text.find(t_isin_list[i])  # find first occurrence
        end = text.find(t_isin_list[i + 1]) if i + 1 < len(t_isin_list) else len(text)  # find next isin
        subtext = text[text.find(t_isin_list[i]):end]  # get text between the first isin and the next isin
        matches = [match.group(1).strip() for match in re.finditer(r'<span class="t-text[^"]*">(.*?)</span>', subtext, re.DOTALL)]
        isin_dict[t_isin_list[i]] = to_dict(matches)

    if len(t_isin_list) == 0:
        break

    page += 1

print(f"Total ISINs: {len(isin_dict)} (raw: {raw_count})")
