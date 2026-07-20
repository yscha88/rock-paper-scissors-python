"""parse_hand 테스트 — Java 의 HandParserTest 에 대응."""
import pytest

from rps.game import Hand, parse_hand


@pytest.mark.parametrize(
    "text, expected",
    [
        # 영어
        ("rock", Hand.ROCK), ("ROCK", Hand.ROCK), ("r", Hand.ROCK),
        ("paper", Hand.PAPER), ("p", Hand.PAPER),
        ("scissors", Hand.SCISSORS), ("s", Hand.SCISSORS),
        # 한국어 (가위/바위/보, 묵/찌/빠)
        ("바위", Hand.ROCK), ("묵", Hand.ROCK),
        ("보", Hand.PAPER), ("빠", Hand.PAPER),
        ("가위", Hand.SCISSORS), ("찌", Hand.SCISSORS),
        # 일본어
        ("グー", Hand.ROCK), ("パー", Hand.PAPER), ("チョキ", Hand.SCISSORS),
        # 중국어
        ("石头", Hand.ROCK), ("布", Hand.PAPER), ("剪刀", Hand.SCISSORS),
    ],
)
def test_parses_multilingual_input(text: str, expected: Hand) -> None:
    assert parse_hand(text) == expected


def test_ignores_surrounding_whitespace_and_case() -> None:
    assert parse_hand("  Rock  ") == Hand.ROCK


def test_unknown_input_raises() -> None:
    with pytest.raises(ValueError):
        parse_hand("lizard")


def test_none_input_raises() -> None:
    with pytest.raises(ValueError):
        parse_hand(None)  # type: ignore[arg-type]
