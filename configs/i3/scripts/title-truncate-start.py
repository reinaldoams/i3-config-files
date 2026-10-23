#!/usr/bin/env python3
"""i3bar filter: give the window_title block a short_text holding the START of the title.

i3bar clips an overflowing status line from the left, which hides the
beginning of the window title. When the line does not fit, i3bar switches to
each block's short_text, so we set short_text to the title truncated to the
space left on the narrowest output.
"""
import html
import json
import re
import subprocess
import sys
import time

CHAR_PX = 10        # approx. advance width of FiraCode Nerd Font 12 on the bar
RESERVE_CHARS = 6   # safety margin (separators, tray, rounding)
REFRESH_SECS = 5
TITLE_NAME = "window_title"
ELLIPSIS = "…"

TAG_RE = re.compile(r"<[^>]*>")


def i3_query(kind):
    try:
        out = subprocess.run(["i3-msg", "-t", kind], capture_output=True, text=True, timeout=2).stdout
        return json.loads(out)
    except Exception:
        return []


def narrowest_output_chars():
    """Chars available on the narrowest active output, minus its workspace buttons."""
    outputs = [o for o in i3_query("get_outputs") if o.get("active")]
    if not outputs:
        return None
    narrow = min(outputs, key=lambda o: o["rect"]["width"])
    ws_chars = sum(len(w["name"]) + 2 for w in i3_query("get_workspaces") if w["output"] == narrow["name"])
    return narrow["rect"]["width"] // CHAR_PX - ws_chars


def visible_len(block):
    text = block.get("full_text", "")
    if block.get("markup") == "pango":
        text = html.unescape(TAG_RE.sub("", text))
    return len(text)


def process(blocks, avail):
    if avail is None:
        return blocks
    title = next((b for b in blocks if b.get("name") == TITLE_NAME), None)
    if title is None:
        return blocks
    others = sum(visible_len(b) for b in blocks if b is not title)
    budget = max(avail - others - RESERVE_CHARS, 1)
    text = title.get("full_text", "")
    title["short_text"] = text if len(text) <= budget else text[: budget - 1] + ELLIPSIS
    return blocks


def main():
    # Pass through the protocol header and the opening "[" of the infinite array.
    for _ in range(2):
        line = sys.stdin.readline()
        if not line:
            return
        sys.stdout.write(line)
    sys.stdout.flush()

    avail, last = None, 0.0
    for line in sys.stdin:
        now = time.monotonic()
        if now - last > REFRESH_SECS:
            avail, last = narrowest_output_chars(), now
        prefix = ""
        body = line.strip()
        if body.startswith(","):
            prefix, body = ",", body[1:]
        try:
            blocks = process(json.loads(body), avail)
            sys.stdout.write(prefix + json.dumps(blocks, ensure_ascii=False) + "\n")
        except json.JSONDecodeError:
            sys.stdout.write(line)
        sys.stdout.flush()


if __name__ == "__main__":
    main()
