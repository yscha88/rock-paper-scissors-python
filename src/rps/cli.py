"""CLI 진입점.

실행::

    python -m rps 바위      # 다국어 인자를 주면 그대로 사용
    python -m rps           # 인자를 생략하면 대화식으로 input() 입력 (엔터만 치면 rock)
    rps 바위                # pip install -e . 후 콘솔 스크립트로

입력을 받는 두 경로:

* **명령행 인자** ``sys.argv`` — Java 의 ``String[] args``, C++ 의 ``argv`` 에 대응.
* **대화식 입력** :func:`input` — Java 의 ``Scanner``, C++ 의 ``std::getline`` 에 대응하지만,
  Python 은 ``input()`` 함수 호출 한 줄이면 표준 입력에서 한 줄을 읽어 온다.

Java 는 Spring Boot 웹 서버가, C++ 는 ``main``/``wmain`` 이 진입점이다.
Python 의 ``str`` 은 곧 유니코드라 C++ 처럼 argv 를 UTF-8 로 변환하는 코드가 필요 없다 —
CJK 인자가 그대로 들어온다.
"""
from __future__ import annotations

import sys

from .game import RockPaperScissors


def _read_input(args: list[str]) -> str:
    """손 입력 문자열을 결정한다.

    1) 명령행 인자가 있으면 그것을 쓴다.
    2) 없으면 :func:`input` 으로 대화식 입력을 받는다.
    3) 대화식 입력도 비어 있거나(엔터만) 표준 입력이 없으면(EOF) ``"rock"`` 으로 기본 진행.
    """
    if args:
        return args[0]
    try:
        entered = input("손을 입력하세요 (rock/바위/가위/묵/グー/石头 ..., 엔터=rock): ").strip()
    except EOFError:
        # 파이프 등으로 표준 입력이 닫혀 있으면 기본값으로.
        entered = ""
    return entered or "rock"


def main(argv: list[str] | None = None) -> int:
    """한 판을 진행하고 결과를 출력한다. 성공 0, 입력 오류 1을 반환한다."""
    args = sys.argv[1:] if argv is None else argv
    user_input = _read_input(args)

    game = RockPaperScissors()
    try:
        result = game.play(user_input)
    except ValueError as exc:
        print(f"오류: {exc}", file=sys.stderr)
        return 1

    print(f"당신: {result.player.name} / 컴퓨터: {result.computer.name} -> {result.outcome.name}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
