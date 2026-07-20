"""CLI 테스트 — 인자 경로와 대화식 input() 경로를 함께 검증한다.

``monkeypatch`` 로 :func:`input` 을 가짜 함수로 바꿔 대화식 입력을 흉내 낸다.
표준 입력을 실제로 주지 않고도 대화식 동작을 테스트할 수 있다는 것 자체가
Python 테스트의 간결함을 보여 준다.
"""
import pytest

from rps import cli


def test_uses_command_line_argument() -> None:
    assert cli.main(["바위"]) == 0


def test_falls_back_to_interactive_input(monkeypatch: pytest.MonkeyPatch) -> None:
    # 인자가 없으면 input() 으로 받은 값을 쓴다.
    monkeypatch.setattr("builtins.input", lambda _prompt="": "가위")
    assert cli._read_input([]) == "가위"


def test_empty_interactive_input_defaults_to_rock(monkeypatch: pytest.MonkeyPatch) -> None:
    # 엔터만 치면(빈 문자열) rock 으로 진행.
    monkeypatch.setattr("builtins.input", lambda _prompt="": "")
    assert cli._read_input([]) == "rock"


def test_eof_defaults_to_rock(monkeypatch: pytest.MonkeyPatch) -> None:
    # 파이프 등으로 표준 입력이 닫혀 있으면(EOFError) rock 으로 진행.
    def _raise(_prompt: str = "") -> str:
        raise EOFError

    monkeypatch.setattr("builtins.input", _raise)
    assert cli._read_input([]) == "rock"


def test_unknown_input_returns_error_code() -> None:
    assert cli.main(["lizard"]) == 1
