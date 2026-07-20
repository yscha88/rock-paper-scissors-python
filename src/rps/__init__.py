"""rock-paper-scissors-python — 교육용 가위바위보 도메인 패키지.

공개 심볼은 Java 원본의 ``org.yscha88.game`` 패키지에 대응한다.
"""
from .game import (
    GameResult,
    Hand,
    Outcome,
    RockPaperScissors,
    judge,
    parse_hand,
)

__all__ = [
    "Hand",
    "Outcome",
    "GameResult",
    "RockPaperScissors",
    "judge",
    "parse_hand",
]
