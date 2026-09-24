#!/usr/bin/env python3
"""Generate local Mox speech assets for RätselKids via ElevenLabs.

The API key and voice ID are read from environment variables and are never
written into the Flutter app. Existing clips are kept, so unchanged text does
not consume additional ElevenLabs credits.
"""

from __future__ import annotations

import hashlib
import json
import os
import re
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PUZZLES_FILE = ROOT / "lib" / "data" / "sample_puzzles.dart"
OUT_DIR = ROOT / "assets" / "audio" / "mox"
MANIFEST_FILE = OUT_DIR / "manifest.json"

# Keep generation settings in this script so a settings change invalidates the cache.
MODEL_ID = "eleven_multilingual_v2"
OUTPUT_FORMAT = "mp3_44100_128"
VOICE_SETTINGS = {
    "stability": 0.50,
    "similarity_boost": 0.75,
    "style": 0.0,
    "use_speaker_boost": True,
    "speed": 1.0,
}


def _dart_unescape(value: str) -> str:
    return value.replace("\\'", "'").replace("\\\\", "\\")


def collect_spoken_texts(source: str) -> list[str]:
    puzzle_pattern = re.compile(
        r"Puzzle\(question:\s*'((?:\\.|[^'])*)'.*?answers:\s*\[([^\]]+)\]",
        re.DOTALL,
    )
    quoted = re.compile(r"'((?:\\.|[^'])*)'")

    texts: list[str] = []
    puzzle_count = 0
    for match in puzzle_pattern.finditer(source):
        puzzle_count += 1
        texts.append(_dart_unescape(match.group(1)).strip())
        for answer in quoted.findall(match.group(2)):
            texts.append(_dart_unescape(answer).strip())

    if puzzle_count != 70:
        raise RuntimeError(
            f"Expected 70 German puzzles, found {puzzle_count}. "
            "Update the generator parser before producing audio."
        )

    texts.extend(["Antwort 1", "Antwort 2", "Antwort 3"])

    # Preserve first occurrence for deterministic generation order.
    return list(dict.fromkeys(text for text in texts if text))


def filename_for(text: str) -> str:
    digest = hashlib.sha256(text.encode("utf-8")).hexdigest()[:20]
    return f"mox_{digest}.mp3"


def create_speech(api_key: str, voice_id: str, text: str, output: Path) -> None:
    endpoint = (
        "https://api.elevenlabs.io/v1/text-to-speech/"
        + urllib.parse.quote(voice_id, safe="")
        + f"?output_format={OUTPUT_FORMAT}"
    )
    payload = json.dumps(
        {
            "text": text,
            "model_id": MODEL_ID,
            "voice_settings": VOICE_SETTINGS,
        },
        ensure_ascii=False,
    ).encode("utf-8")

    request = urllib.request.Request(
        endpoint,
        data=payload,
        method="POST",
        headers={
            "Content-Type": "application/json",
            "Accept": "audio/mpeg",
            "xi-api-key": api_key,
        },
    )

    last_error: Exception | None = None
    for attempt in range(4):
        try:
            with urllib.request.urlopen(request, timeout=90) as response:
                audio = response.read()
            if not audio:
                raise RuntimeError("ElevenLabs returned an empty audio response.")
            temp = output.with_suffix(".tmp")
            temp.write_bytes(audio)
            temp.replace(output)
            return
        except urllib.error.HTTPError as exc:
            body = exc.read().decode("utf-8", errors="replace")
            last_error = RuntimeError(
                f"ElevenLabs HTTP {exc.code} for {text!r}: {body[:300]}"
            )
            if exc.code not in {429, 500, 502, 503, 504}:
                break
        except Exception as exc:  # network/timeout retry
            last_error = exc

        time.sleep(2 ** attempt)

    raise RuntimeError(f"Could not generate {text!r}: {last_error}")


def main() -> int:
    api_key = os.environ.get("ELEVENLABS_API_KEY", "").strip()
    voice_id = os.environ.get("MOX_VOICE_ID", "").strip()

    OUT_DIR.mkdir(parents=True, exist_ok=True)

    if not api_key or not voice_id:
        print(
            "Mox audio generation skipped: ELEVENLABS_API_KEY and/or "
            "MOX_VOICE_ID is not configured."
        )
        return 0

    source = PUZZLES_FILE.read_text(encoding="utf-8")
    texts = collect_spoken_texts(source)

    clips: dict[str, str] = {}
    generated = 0
    reused = 0

    for index, text in enumerate(texts, start=1):
        filename = filename_for(text)
        output = OUT_DIR / filename
        clips[text] = filename

        if output.exists() and output.stat().st_size > 0:
            reused += 1
            continue

        print(f"[{index}/{len(texts)}] Generating Mox audio: {text}")
        create_speech(api_key, voice_id, text, output)
        generated += 1

    manifest = {
        "schema": 1,
        "voice": "Mox",
        "model": MODEL_ID,
        "output_format": OUTPUT_FORMAT,
        "voice_settings": VOICE_SETTINGS,
        "clips": clips,
    }
    MANIFEST_FILE.write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )

    print(
        f"Mox audio ready: {len(texts)} clips referenced, "
        f"{generated} generated, {reused} reused."
    )
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f"Mox audio generation failed: {exc}", file=sys.stderr)
        raise
