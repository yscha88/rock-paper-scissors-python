# 02. Python 환경 — 바이너리, venv, uv, conda, poetry, gunicorn

> "파이썬을 설치했다"는 게 정확히 무엇을 설치한 것인지, 그리고 프로젝트마다 왜 환경을
> 따로 만드는지, 어떤 도구를 언제 쓰는지 정리합니다.

## 1. Python 바이너리(인터프리터)란?

C++ 는 컴파일하면 **실행 파일(`rps.exe`)** 이 나오고, 그 파일 자체가 프로그램입니다.
반면 Python 에서 "실행 파일"에 해당하는 것은 **인터프리터 바이너리** — `python.exe`(Windows) /
`python`(macOS·Linux) 입니다. 이 프로그램이 우리의 `.py` 를 읽어 **바이트코드로 컴파일한 뒤 실행**합니다.

```
python.exe  +  game.py(소스)   ──▶  실행
   (엔진)        (연료)
```

- 우리가 흔히 쓰는 표준 구현은 **CPython**(C 로 작성된 파이썬). `python --version` 이 가리키는 그것.
- 그 외 구현도 있다: PyPy(JIT 로 빠름), Jython(JVM), GraalPy 등. 이 repo 는 CPython 기준.
- `.py` 를 한 번 실행하면 옆에 `__pycache__/*.pyc`(바이트코드 캐시)가 생긴다 — 다음 실행을 빠르게.

**핵심**: Python 코드를 실행하려면 항상 "그 코드를 돌릴 인터프리터"가 필요합니다. 그래서 아래
모든 도구의 근본 목적은 **"어떤 파이썬 바이너리로, 어떤 패키지들과 함께 이 코드를 돌릴까"**를
관리하는 것입니다.

## 2. 왜 "가상환경(virtual environment)"이 필요한가

파이썬 하나를 시스템 전역에 깔고 모든 프로젝트가 공유하면 문제가 생깁니다.

- 프로젝트 A 는 `fastapi 0.110`, 프로젝트 B 는 `fastapi 0.95` 를 요구 → **버전 충돌**.
- 전역에 아무거나 설치하다 보면 **오염**되어 재현이 안 된다.

**가상환경**은 프로젝트별로 격리된 "파이썬 + 그 프로젝트 전용 패키지 폴더"를 만듭니다.
이 repo 의 `.gitignore` 가 `.venv/` 를 무시하는 이유 — 환경은 각자 만들고, 커밋하지 않습니다.

```
전역 파이썬              프로젝트별 가상환경
python.exe          →   .venv/ (이 프로젝트만의 python + 패키지)
site-packages/           - fastapi 0.110
  (뒤죽박죽)              - pytest 9  ...
```

## 3. 도구 지도 — 무엇을 언제 쓰나

파이썬 도구가 많아 헷갈리는 이유는, 각 도구가 **서로 다른 역할**을 맡거나 **여러 역할을 겸하기**
때문입니다. 역할을 먼저 나눠 보면 정리됩니다.

| 역할 | 담당 도구 |
|---|---|
| ① 파이썬 **버전** 설치·전환 | `pyenv`, `uv`, `conda`, 공식 인스톨러 |
| ② **가상환경** 생성/격리 | `venv`(표준), `virtualenv`, `uv`, `conda`, `poetry` |
| ③ **패키지 설치** | `pip`(표준), `uv`, `poetry`, `conda` |
| ④ 의존성 **잠금(lock)·재현** | `uv`(uv.lock), `poetry`(poetry.lock), `pip`(requirements.txt) |
| ⑤ **배포용 서버** 구동 | `gunicorn`, `uvicorn` |

### venv — 표준 라이브러리 가상환경 (①은 아님, ②만)
파이썬에 기본 포함. 별도 설치가 필요 없다. 가장 기본이고 가벼운 격리 방법.
```powershell
python -m venv .venv                 # 가상환경 생성
.\.venv\Scripts\Activate.ps1         # 활성화(Windows PowerShell)
pip install -e ".[dev]"              # 이 환경 안에만 설치
```

### pip — 표준 패키지 설치기 (③)
PyPI(파이썬 패키지 저장소)에서 패키지를 내려받아 설치. `venv` 와 짝으로 가장 전통적인 조합.
```powershell
pip install fastapi                  # 설치
pip install -e .                     # 이 프로젝트를 "편집 가능" 모드로 설치
```

### uv — 초고속 통합 도구 (①②③④ 한 번에) ⭐ 이 repo 권장
Rust 로 작성돼 **매우 빠르고**, 파이썬 버전 설치 + 가상환경 + 패키지 설치 + 잠금을 하나로 통합.
`pyproject.toml` 을 그대로 읽는다.
```powershell
uv sync                              # .venv 자동 생성 + pyproject 의존성 설치 + uv.lock 생성
uv run python -m rps 바위            # 활성화 없이 그 환경에서 바로 실행
uv run pytest
uv sync --extra web                  # 선택 의존성(web) 포함
uv python install 3.13               # 파이썬 버전 자체도 설치 가능
```
> 이 repo 는 `uv sync` 한 줄이면 환경이 준비됩니다 — 오늘날 가장 간단한 경로.

### poetry — 의존성 관리 + 패키징 (②③④)
`pyproject.toml` 기반으로 의존성 해결·잠금(`poetry.lock`)·빌드·배포를 다룬다. uv 이전에 널리 쓰인
올인원 도구. 라이브러리를 PyPI 에 배포까지 하려는 경우 특히 강점.
```powershell
poetry install                       # 환경 생성 + 설치
poetry run pytest
poetry add fastapi                   # 의존성 추가 + lock 갱신
```

### conda — 과학/데이터용 환경·패키지 관리 (①②③)
`pip` 과 달리 **파이썬이 아닌 바이너리**(예: CUDA, MKL, C 라이브러리)까지 함께 설치·격리한다.
데이터 과학·머신러닝처럼 네이티브 의존성이 무거운 분야에서 선호된다.
```powershell
conda create -n rps python=3.13      # 환경 생성
conda activate rps
conda install numpy                  # 파이썬+네이티브 패키지를 함께
```
> **pip vs conda**: pip 은 "파이썬 패키지"를, conda 는 "파이썬 + 그 밑의 네이티브 스택"을 다룹니다.
> 웹/일반 앱은 pip·uv 로 충분하고, 과학 스택 호환성이 중요하면 conda 가 편합니다.

### pyenv — 파이썬 **버전** 전환 전담 (①)
여러 파이썬 버전을 깔아 두고 프로젝트별로 고른다. `.python-version` 파일로 버전을 지정한다
(이 repo 에도 있음). 요즘은 uv 가 이 역할을 흡수하는 추세.

### gunicorn / uvicorn — 배포용 서버 (⑤)
개발용 서버는 요청을 하나씩 처리해도 되지만, 운영에서는 **여러 요청을 안정적으로 동시에** 처리해야
합니다. 이때 쓰는 프로덕션 웹 서버입니다.

- **uvicorn**: **ASGI**(비동기) 서버. FastAPI 같은 async 프레임워크를 구동. 개발용으로도 씀.
- **gunicorn**: 검증된 **WSGI** 프로세스 매니저. 워커(작업 프로세스)를 여러 개 띄워 병렬 처리.
  FastAPI(ASGI)는 **uvicorn 워커**를 얹어 구동한다.

```powershell
# 개발: 자동 리로드, 단일 프로세스
uvicorn rps.web:app --reload

# 운영: gunicorn 이 uvicorn 워커 여러 개를 관리 (동시 처리 ↑, 장애 격리 ↑)
gunicorn -k uvicorn.workers.UvicornWorker rps.web:app --workers 4
```

> Java 는 이 역할을 **Spring Boot 내장 Tomcat** 이 프레임워크 안에서 해결합니다. Python 은
> 프레임워크(FastAPI)와 서버(gunicorn/uvicorn)를 **분리**해 조합하는 문화라, 서버를 따로 지정합니다.
> 이 "레고 블록처럼 조합" 하는 방식이 Python 생태계의 특징입니다.

## 4. 그래서 이 repo 는?

- **핵심 로직·CLI·테스트**: 런타임 의존성이 **0개**(표준 라이브러리만) → 사실상 환경 도구 없이도 실행.
- **웹**: `fastapi` / `uvicorn` / `gunicorn` 은 선택 의존성(`[web]` extra) — 필요할 때만 설치.

정리하면, **처음이라면 `uv` 하나만** 익히면 위 역할 대부분을 한 도구로 처리할 수 있습니다.
전통적 조합을 이해하고 싶다면 `python -m venv` + `pip` 부터 시작하세요.

## 5. `pyproject.toml` vs `requirements.txt`, 그리고 버전 제약

의존성을 적는 파일이 두 종류입니다. **성격이 다릅니다.**

| | `pyproject.toml` | `requirements.txt` |
|---|---|---|
| 성격 | 프로젝트 **정의서**(이름·버전·의존성·빌드·스크립트) | 설치할 패키지 **목록** |
| 비유 | "이 앱은 무엇인가"(레시피) | "지금 정확히 이것들"(장보기 목록) |
| 버전 표기 | 보통 느슨한 범위(`>=`) | 느슨하게도, 정확히 고정(`==`)도 |

**버전을 고정(pinning)하느냐, 범위로 두느냐**도 중요합니다.

- `fastapi==0.110.0` → **정확히 고정**(pinning): 언제 설치해도 같은 버전 → 재현성 ↑, 수동 갱신.
- `fastapi>=0.110` → **이상**(하한, lower bound) / `<=0.110` → **이하**(상한, upper bound) /
  `>=0.110,<1.0` → **범위**(하한+상한): 자동으로 버그픽스를 받지만, 새 버전이 호환을 깰 위험.
- **lock 파일**(`uv.lock`·`poetry.lock`)은 하위 의존성까지 **정확히 잠가** 완전한 재현을 보장합니다.
- 파이썬 버전 자체도 `pyproject.toml` 의 `requires-python = ">=3.11"` 로 같은 방식으로 제약합니다.

> 이 개념들은 [랩 02](labs/02-venv-pip-requirements.md)에서 **직접 파일을 만들고 설치**하며 확인합니다.

## 6. 개념을 손으로 — 실습 랩

위 도구들을 각각 **직접 만들어 보는** 실습이 준비돼 있습니다 → **[docs/labs/](labs/README.md)**
(바이너리 직접 실행 · venv+pip+requirements · uv · poetry · conda · 웹 배포).

다음: [03-python-문법](03-python-문법.md) — 변수·함수·클래스를 이 repo 코드로.
