"""RockPaperScissors / judge 테스트 — Java 의 RockPaperScissorsTest 에 대응.

JUnit 의 ``@ParameterizedTest`` + ``@CsvSource`` 는 pytest 의 ``@pytest.mark.parametrize`` 로,
``@RepeatedTest`` 는 for 루프로 옮긴다.
"""
import pytest

from rps.game import GameResult, Hand, Outcome, RockPaperScissors, judge


@pytest.mark.parametrize(
    "player, computer, expected",
    [
        (Hand.ROCK, Hand.SCISSORS, Outcome.WIN),
        (Hand.PAPER, Hand.ROCK, Outcome.WIN),
        (Hand.SCISSORS, Hand.PAPER, Outcome.WIN),
        (Hand.ROCK, Hand.PAPER, Outcome.LOSE),
        (Hand.PAPER, Hand.SCISSORS, Outcome.LOSE),
        (Hand.SCISSORS, Hand.ROCK, Outcome.LOSE),
        (Hand.ROCK, Hand.ROCK, Outcome.DRAW),
        (Hand.PAPER, Hand.PAPER, Outcome.DRAW),
        (Hand.SCISSORS, Hand.SCISSORS, Outcome.DRAW),
    ],
)
def test_judges_nine_combinations(player: Hand, computer: Hand, expected: Outcome) -> None:
    assert judge(player, computer) == expected


def test_parses_input_and_outcome_matches_judge() -> None:
    # 결정적 난수 주입: 컴퓨터는 항상 SCISSORS(2). C++ 의 RandomSource 주입과 같은 기법을
    # Python 은 람다 하나로 해낸다.
    game = RockPaperScissors(rng=lambda _bound: 2)
    result = game.play("바위")
    assert result.player == Hand.ROCK
    assert result.computer == Hand.SCISSORS
    assert result.outcome == Outcome.WIN
    assert result.outcome == judge(result.player, result.computer)


def test_computer_hand_is_always_valid() -> None:
    game = RockPaperScissors()
    for _ in range(50):
        assert isinstance(game.play(Hand.ROCK).computer, Hand)


def test_secure_random_produces_all_three_hands() -> None:
    game = RockPaperScissors()
    seen: set[Hand] = set()
    for _ in range(300):
        seen.add(game.play(Hand.ROCK).computer)
        if len(seen) == 3:
            break
    assert seen == {Hand.ROCK, Hand.PAPER, Hand.SCISSORS}


def test_game_result_is_immutable() -> None:
    # frozen dataclass 는 필드 재할당 시 FrozenInstanceError 를 던진다.
    result = GameResult(Hand.ROCK, Hand.SCISSORS, Outcome.WIN)
    with pytest.raises(Exception):
        result.player = Hand.PAPER  # type: ignore[misc]
