"""가위바위보 REST API — Java 의 ``GameController`` + ``ApiExceptionHandler`` 에 대응한다.

FastAPI 로 작성했다. 의존성(fastapi/uvicorn/gunicorn/pydantic)은 **선택 사항**이라, 이 모듈을
쓸 때만 설치하면 된다::

    pip install -e ".[web]"          # 또는:  uv sync --extra web

실행::

    uvicorn rps.web:app --reload                              # 개발용 (자동 리로드)
    gunicorn -k uvicorn.workers.UvicornWorker rps.web:app     # 운영용 (리눅스/WSL/Docker)

호출 예::

    GET /api/play?h=rock
    → {"player": "ROCK", "computer": "SCISSORS", "outcome": "WIN"}

``h`` 파라미터는 다국어를 허용한다(rock/바위/묵/グー/石头 ...).
알 수 없거나 누락된 입력은 400 Bad Request 로 응답한다.

**dataclass vs Pydantic 의 역할 분담**: 순수 도메인 타입 ``GameResult`` 는 표준 라이브러리
``@dataclass`` 로 (의존성 0), **외부로 나가는 API 경계**는 Pydantic ``BaseModel`` 로 표현한다.
Pydantic 은 타입 힌트를 런타임에 검증하고 JSON 직렬화·자동 문서(/docs)를 만들어 준다.
(→ docs/03-python-문법.md 의 "정적 타입의 대안 — Pydantic")

Spring 은 컨트롤러/예외 핸들러/부트 진입점에 각각 클래스와 어노테이션이 필요하지만,
FastAPI 는 함수 하나에 데코레이터를 붙이는 것으로 끝난다.
"""
from __future__ import annotations

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

from .game import GameResult, RockPaperScissors

app = FastAPI(title="rock-paper-scissors-python")
_game = RockPaperScissors()


class PlayResponse(BaseModel):
    """API 응답 스키마 — Pydantic 모델.

    필드 타입을 런타임에 검증하고, FastAPI 가 이 모델로 응답 스키마와 자동 문서를 만든다.
    내부 도메인 ``GameResult``(dataclass)를 외부 경계 표현으로 옮기는 얇은 계층이다.
    """

    player: str
    computer: str
    outcome: str

    @classmethod
    def of(cls, result: GameResult) -> "PlayResponse":
        return cls(
            player=result.player.name,
            computer=result.computer.name,
            outcome=result.outcome.name,
        )


@app.get("/api/play", response_model=PlayResponse)
def play(h: str) -> PlayResponse:
    """다국어 손 문자열 ``h`` 를 받아 한 판을 진행한다."""
    try:
        result = _game.play(h)
    except ValueError as exc:
        # Java 의 ApiExceptionHandler(IllegalArgumentException → 400) 에 대응.
        raise HTTPException(status_code=400, detail=str(exc)) from exc

    return PlayResponse.of(result)
