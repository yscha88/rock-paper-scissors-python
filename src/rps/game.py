"""가위바위보 도메인 로직 — 전부 이 한 파일에.

Java 판(../rock-paper-scissors)은 game 패키지에 클래스 하나당 파일 하나, 총 5개로 나뉜다::

    Hand.java  Outcome.java  GameResult.java  HandParser.java  RockPaperScissors.java

C++ 판(../rock-paper-scissors-cpp)은 여기에 헤더(.hpp)/구현(.cpp)까지 갈려 파일이 더 많다.
Python 에서는 같은 도메인을 이 파일 하나(약 90줄)로 표현한다. "클래스 하나당 파일 하나"는
Java 의 관례일 뿐 Python 의 규칙이 아니다 — 관련된 것은 한 모듈에 모으는 편이 Python 답다.

판정 규칙::

    ROCK(0) 이 SCISSORS(2) 를,  PAPER(1) 이 ROCK(0) 을,  SCISSORS(2) 가 PAPER(1) 을 이긴다.
"""
from __future__ import annotations

import secrets
from collections.abc import Callable
from dataclasses import dataclass
from enum import Enum, IntEnum


class Hand(IntEnum):
    """가위바위보의 손. 멤버 값(0/1/2)이 그대로 판정 모듈러 연산에 쓰인다.

    Java 는 ``enum Hand`` 에 별도 ``int code`` 필드와 ``code()`` 접근자를 두고,
    C++ 는 ``enum class`` 에 ``to_code()`` 를 둔다. Python 의 ``IntEnum`` 은
    멤버 자체가 int 이므로 그런 보조 코드가 아예 필요 없다 — ``Hand.ROCK - Hand.PAPER`` 처럼
    바로 산술 연산이 된다.
    """

    ROCK = 0
    PAPER = 1
    SCISSORS = 2


class Outcome(Enum):
    """플레이어 기준 승부 결과."""

    WIN = "WIN"
    LOSE = "LOSE"
    DRAW = "DRAW"


@dataclass(frozen=True)
class GameResult:
    """한 판의 결과: 플레이어 손, 컴퓨터 손, 플레이어 기준 결과.

    Java 의 ``record GameResult(Hand player, Hand computer, Outcome outcome)`` 에 대응한다.
    ``@dataclass(frozen=True)`` 한 줄로 불변성 + ``__init__`` + ``__eq__`` + ``__repr__`` 가
    자동 생성된다.
    """

    player: Hand
    computer: Hand
    outcome: Outcome


# 다국어 별칭 → Hand. 항목만 추가하면 언어를 쉽게 확장할 수 있다.
# Java HandParser 의 ``Map.ofEntries(...)`` 와 같은 구성이지만, Python 은 dict 리터럴이면 끝이다.
_ALIASES: dict[str, Hand] = {
    # ROCK
    "rock": Hand.ROCK, "r": Hand.ROCK, "바위": Hand.ROCK, "묵": Hand.ROCK, "グー": Hand.ROCK, "石头": Hand.ROCK,
    # PAPER
    "paper": Hand.PAPER, "p": Hand.PAPER, "보": Hand.PAPER, "빠": Hand.PAPER, "パー": Hand.PAPER, "布": Hand.PAPER,
    # SCISSORS
    "scissors": Hand.SCISSORS, "scissor": Hand.SCISSORS, "s": Hand.SCISSORS,
    "가위": Hand.SCISSORS, "찌": Hand.SCISSORS, "チョキ": Hand.SCISSORS, "剪刀": Hand.SCISSORS,
}


def parse_hand(text: str) -> Hand:
    """다국어 입력 문자열을 :class:`Hand` 로 변환한다. 앞뒤 공백과 영문 대소문자를 무시한다.

    Java ``HandParser.parse`` / C++ ``parse_hand`` 에 대응한다. Python 의 ``str`` 은 처음부터
    유니코드라, C++ 가 Windows 에서 하던 UTF-16 → UTF-8 변환 같은 처리가 필요 없다.

    :raises ValueError: 입력이 ``None`` 이거나 알 수 없는 값일 때.
    """
    if text is None:
        raise ValueError("입력이 없습니다.")
    hand = _ALIASES.get(text.strip().lower())
    if hand is None:
        raise ValueError(f"알 수 없는 손 입력: {text!r}")
    return hand


def judge(player: Hand, computer: Hand) -> Outcome:
    """플레이어 기준 승패 판정. int 모듈러 연산 (Java/C++ 와 완전히 동일한 공식).

    ::

        diff = (player - computer + 3) % 3   →   0: DRAW, 1: WIN, 2: LOSE

    ``Hand`` 가 ``IntEnum`` 이라 ``player - computer`` 를 곧바로 뺄 수 있고,
    분기(switch/if)는 튜플 인덱싱 한 줄로 대신한다.
    """
    diff = (player - computer + 3) % 3
    return (Outcome.DRAW, Outcome.WIN, Outcome.LOSE)[diff]


class RockPaperScissors:
    """가위바위보 게임 로직.

    컴퓨터 손은 주입된 난수 공급원으로 산출한다. 기본값 :func:`secrets.randbelow` 는
    Java 의 ``SecureRandom``, C++ 의 ``std::random_device`` 에 대응하는 **암호학적 보안 난수**이며,
    모듈로 편향이 없다.

    난수를 '주입'하기 위해 C++ 는 ``RandomSource`` 추상 클래스 + ``std::unique_ptr`` 를,
    Java 는 별도 인터페이스 + 생성자 주입을 동원한다. Python 은 함수가 일급 객체이므로
    그냥 ``Callable[[int], int]`` 하나를 받으면 끝이다 — 인터페이스 선언이 필요 없다(덕 타이핑).
    테스트는 ``rng=lambda n: 2`` 처럼 결정적 함수를 넣어 승패를 확정적으로 검증한다.
    """

    def __init__(self, rng: Callable[[int], int] = secrets.randbelow) -> None:
        self._rng = rng

    def play(self, player: Hand | str) -> GameResult:
        """한 판을 진행한다. ``player`` 는 :class:`Hand` 또는 다국어 문자열 둘 다 허용한다.

        Java/C++ 는 ``play(String)`` 과 ``play(Hand)`` 두 오버로드로 나눠야 하지만,
        Python 은 오버로딩이 없는 대신 유니온 타입 하나로 두 경우를 함께 받는다.
        """
        if isinstance(player, str):
            player = parse_hand(player)
        computer = Hand(self._rng(3))
        return GameResult(player, computer, judge(player, computer))
