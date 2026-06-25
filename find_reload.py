# -*- coding: utf-8 -*-
content = open("entry/src/main/ets/pages/Index.ets", "r", encoding="utf-8").read()
idx = content.find("reloadSettingsFromDB")
if idx >= 0:
    # Show from function name through end brace
    start = idx
    # find opening { of function
    brace = content.find("{", idx)
    # find matching closing }
    depth = 1
    pos = brace + 1
    while depth > 0 and pos < len(content):
        if content[pos] == "{":
            depth += 1
        elif content[pos] == "}":
            depth -= 1
        pos += 1
    print(content[start:pos])