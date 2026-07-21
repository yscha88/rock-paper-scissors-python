"""slides/index.html 이 docs/master.md(구조 SSOT)를 충실히 반영하는지 적대적으로 검증한다.

사용법::

    python tools/verify_slides.py

검사 항목
  A. 구조 — 슬라이드 개수·순서, eyebrow 정확 일치, h2 핵심 문구 포함
  B. 내용 — 슬라이드별 필수 키워드 존재
  C. 정책 — 위치 참조 금지(N장은 01~05장만), 금지 표기, 태그 균형
  D. 앵커 — 챕터 id 전부 존재 + 챕터 내비 버튼과 1:1
표준 라이브러리만 사용. 실패 시 종료 코드 1.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
MASTER = ROOT / "docs" / "master.md"
SLIDES = ROOT / "slides" / "index.html"

ALLOWED_CHAPTER_REFS = {"01장", "02장", "03장", "04장", "05장"}
BANNED = ["애너테이션", "(over)", "(down)", "Windows 미지원"]
REQUIRED_IDS = ["intro", "sec01", "sec02", "sec03", "sec04", "secdbg", "seclabs",
                "lab01", "lab02", "lab03", "lab04", "lab05", "lab06", "secend"]


def strip_tags(s: str) -> str:
    return re.sub(r"<[^>]+>", "", s).replace("&amp;", "&").replace("&gt;", ">").replace("&lt;", "<")


def norm(s: str) -> str:
    """포맷터가 넣는 개행·들여쓰기에 흔들리지 않도록 공백을 한 칸으로 정규화한다."""
    return re.sub(r"\s+", " ", s).strip()


def parse_master() -> list[dict]:
    rows = []
    for line in MASTER.read_text(encoding="utf-8").splitlines():
        m = re.match(r"\|\s*(\d+)\s*\|([^|]+)\|([^|]+)\|([^|]+)\|([^|]+)\|", line)
        if not m:
            continue
        rows.append({
            "n": int(m.group(1)),
            "chapter": m.group(2).strip(),
            "eyebrow": m.group(3).strip(),
            "h2": m.group(4).strip(),
            "keywords": [k.strip() for k in m.group(5).split(";") if k.strip()],
        })
    return rows


def parse_slides(html: str) -> list[dict]:
    out = []
    for attrs, body in re.findall(r"<section class=\"slide[^\"]*\"([^>]*)>(.*?)</section>", html, re.S):
        sid = (re.search(r'id="([^"]+)"', attrs) or [None, ""])[1]
        eb = re.search(r'<div class="eyebrow">(.*?)</div>', body, re.S)
        h = re.search(r"<h[12][^>]*>(.*?)</h[12]>", body, re.S)
        out.append({
            "id": sid,
            "eyebrow": norm(strip_tags(eb.group(1))) if eb else "",
            "h2": norm(strip_tags(h.group(1))) if h else "",
            "text": norm(strip_tags(body)),
            "raw": norm(body),
        })
    return out


def main() -> int:
    html = SLIDES.read_text(encoding="utf-8")
    master = parse_master()
    slides = parse_slides(html)
    fails: list[str] = []

    # A. 구조
    if len(slides) != len(master):
        fails.append(f"[A] 슬라이드 수 불일치: master {len(master)} vs slides {len(slides)}")
    for row, sl in zip(master, slides):
        n = row["n"]
        if sl["eyebrow"] != row["eyebrow"]:
            fails.append(f"[A] #{n} eyebrow: master '{row['eyebrow']}' vs slide '{sl['eyebrow']}'")
        if row["h2"] not in sl["h2"]:
            fails.append(f"[A] #{n} h2에 '{row['h2']}' 없음 (실제: '{sl['h2'][:40]}')")
        # B. 내용 키워드
        for kw in row["keywords"]:
            if kw not in sl["text"] and kw not in sl["raw"]:
                fails.append(f"[B] #{n} 키워드 누락: '{kw}'")

    # C. 정책
    body_text = strip_tags(html)
    for m in re.finditer(r"\d+장", body_text):
        if m.group(0) not in ALLOWED_CHAPTER_REFS:
            fails.append(f"[C] 위치 참조 발견: '{m.group(0)}' (챕터명 01~05장만 허용)")
    for b in BANNED:
        if b in body_text:
            fails.append(f"[C] 금지 표기: '{b}'")
    if html.count("<section") != html.count("</section>"):
        fails.append("[C] <section> 태그 불균형")
    if html.count("<pre") != html.count("</pre>"):
        fails.append("[C] <pre> 태그 불균형")

    # D. 앵커·내비
    ids = [s["id"] for s in slides if s["id"]]
    for rid in REQUIRED_IDS:
        if rid not in ids:
            fails.append(f"[D] 필수 id 누락: {rid}")
    nav_targets = re.findall(r'#chapnav|data-goto="#(\w+)"', html)
    chap_btns = re.findall(r'<nav class="chapnav"[^>]*>(.*?)</nav>', html, re.S)
    if chap_btns:
        btn_targets = re.findall(r'data-goto="#(\w+)"', chap_btns[0])
        for t in btn_targets:
            if t not in ids:
                fails.append(f"[D] 챕터 내비 대상 id 없음: #{t}")
        if len(btn_targets) != 8:
            fails.append(f"[D] 챕터 버튼 수 {len(btn_targets)} (기대 8)")

    if fails:
        print(f"FAIL — {len(fails)}건")
        for f in fails:
            print("  " + f)
        return 1
    print(f"PASS — {len(master)}장 전부 master 구조·내용·정책·앵커 일치")
    return 0


if __name__ == "__main__":
    sys.exit(main())
