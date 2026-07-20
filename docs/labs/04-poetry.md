# 랩 04 — poetry (의존성 관리 + 패키징 도구)

**목표**: `poetry` 를 설치하고, 의존성 관리·잠금(`poetry.lock`)·실행을 경험한다.
`poetry` 는 uv 이전부터 널리 쓰인 올인원 도구로, 특히 **라이브러리를 PyPI 에 배포**할 때 강점이 있다.

> 소요 시간 10분 · 준비물: PowerShell, 인터넷
> ⚠️ 이 PC 에는 poetry 가 **아직 없습니다**. 아래 1단계에서 설치부터 합니다.
> (아래 출력은 "예상 출력"이며, 버전에 따라 조금 다를 수 있습니다.)

## 0. 개념 — poetry 가 하는 일
- 의존성 **해결·설치**(pip 역할) + **가상환경** 관리(venv 역할)
- 의존성 **잠금**: `poetry.lock` (uv.lock 과 같은 개념)
- 프로젝트 **빌드·배포**: `poetry build` / `poetry publish`

## 1. poetry 설치 (pipx 사용)
`pipx` 는 "명령줄 도구를 각자 격리해서 설치"하는 도구입니다(이 PC 에 이미 있음). poetry 처럼
**여러 프로젝트에서 공용으로 쓰는 도구**는 pipx 로 까는 게 깔끔합니다.
```powershell
pipx install poetry        # Windows·macOS 동일 (macOS 에 pipx 가 없으면: brew install pipx)
poetry --version           # 예: Poetry (version 2.x.x)
```
> 설치 후 `poetry` 명령이 안 잡히면 새 터미널을 열거나 `pipx ensurepath` 후 재시작하세요.

## 2. 이 저장소에서 실행
이 저장소의 `pyproject.toml` 은 **표준(PEP 621) `[project]`** 형식입니다.
**Poetry 2.0 이상**은 이 표준 형식을 그대로 읽어 설치할 수 있습니다.
```powershell
cd C:\repo\yscha88\rock-paper-scissors-python
poetry install            # pyproject.toml 을 읽어 가상환경 생성 + 설치 + poetry.lock 생성
poetry run python -m rps 바위
poetry run pytest -q
```
예상 출력:
```
당신: ROCK / 컴퓨터: PAPER -> LOSE
40 passed in 0.08s
```
`poetry run <명령>` 은 uv 의 `uv run` 과 같은 개념 — 가상환경 안에서 실행합니다.

## 3. poetry 로 새 프로젝트를 시작한다면 (참고)
poetry 의 진가는 **새 프로젝트를 poetry 방식으로 만들 때** 드러납니다.
```powershell
poetry new my-app          # poetry 표준 구조로 새 프로젝트 생성
cd my-app
poetry add fastapi         # 의존성 추가 → pyproject.toml + poetry.lock 자동 갱신
poetry add --group dev pytest   # 개발용 그룹에 추가
poetry install
poetry run pytest
```

### poetry 의 버전 표기 — 캐럿(`^`)과 틸데(`~`)
poetry 는 랩 02 의 `==`/`>=` 외에 **캐럿·틸데** 표기를 자주 씁니다.
| 표기 | 의미 | 허용 범위 |
|---|---|---|
| `^1.2.3` | 캐럿: 왼쪽 0 아닌 자리까지 호환 | `>=1.2.3,<2.0.0` |
| `~1.2.3` | 틸데: 마지막 자리만 유동 | `>=1.2.3,<1.3.0` |
| `1.2.3` | 정확히 고정 | `==1.2.3` |

> `^`(캐럿)는 "메이저 버전(첫 숫자)이 안 바뀌는 선에서 최신"이라는 뜻으로, poetry 의 기본
> 추가 방식입니다. 버전 고정/범위 개념은 [랩 02 의 5절](02-venv-pip-requirements.md)과 이어집니다.

## 4. 정리
```powershell
Remove-Item -Recurse -Force .venv 2>$null
Remove-Item poetry.lock 2>$null
# poetry 자체를 지우려면:
pipx uninstall poetry
```

> **언제 poetry 를 쓰나**: 라이브러리 배포까지 아우르는 성숙한 워크플로가 필요할 때, 또는 팀이
> 이미 poetry 를 쓸 때. 새로 시작한다면 uv 가 더 빠르지만, poetry 도 여전히 널리 쓰입니다.

다음: [랩 05 — conda](05-conda.md)
