# rock-paper-scissors-python

같은 가위바위보를 **Java(Spring Boot)** → **C++20** → **Python** 순서로 만들어 보면서,
Python 이 얼마나 짧고 간단하게 같은 일을 해내는지 눈으로 확인하는 **교육용 저장소**입니다.

- 원본: [rock-paper-scissors](https://github.com/yscha88/rock-paper-scissors) — Java 17 + Spring Boot REST API (api · docker)
- 이식: [rock-paper-scissors-cpp](https://github.com/yscha88/rock-paper-scissors-cpp) — C++20 핵심 로직 + CLI
- **이 repo**: [rock-paper-scissors-python](https://github.com/yscha88/rock-paper-scissors-python) —
  세 번째 이식판. 같은 도메인/판정 로직을 Python 으로, **"진짜 만들어 보기" 예제용**.

세 구현의 **판정 공식은 완전히 동일**합니다 — `diff = (player - computer + 3) % 3`.
달라지는 것은 "그 로직을 감싸는 언어의 무게"입니다.

## 학습 로드맵

이 repo 는 코드를 예제 삼아 아래 순서로 읽으면 됩니다.

1. [docs/01-cs-기초.md](docs/01-cs-기초.md) — 소스코드가 실행되기까지: 컴파일 vs 인터프리터,
   네이티브 / managed 언어, 정적·동적 타입, 메모리 관리. C/C++ · Java · Python 의 공통점과 차이.
2. [docs/02-python-환경.md](docs/02-python-환경.md) — Python 바이너리(인터프리터)란 무엇이고,
   `venv` · `uv` · `conda` · `poetry` · `pip` · `gunicorn` 은 각각 왜/언제 쓰는가.
3. [docs/03-python-문법.md](docs/03-python-문법.md) — 변수 · 함수 · 클래스 작성법을
   이 repo 의 실제 코드로. Java/C++ 대비 무엇이 사라졌는가.
4. [docs/04-언어-비교.md](docs/04-언어-비교.md) — 같은 기능의 "전체 구현"을 세 언어로 통째로 비교.

그다음 **직접 손으로** 해 보세요:

5. [docs/labs/](docs/labs/README.md) — 실습 랩 6종: 바이너리 직접 실행 · venv+pip+requirements · uv · poetry · conda · 웹 배포. (터미널·명령어 개념부터, 코딩 처음을 가정)
6. [slides/](slides/index.html) — 위 문서 4편 + 실습 6종을 한 편으로 엮은 강의 슬라이드(HTML 22장).
   `slides/index.html` 을 브라우저로 열면 됩니다 (CSS/JS 는 `slides.css`/`slides.js` 로 분리).

## 세 언어 한눈에 비교

| 항목 | Java (Spring Boot) | C++20 | **Python** |
|---|---|---|---|
| 도메인 파일 수 | 5개 | 8개 (헤더 `.hpp` / 구현 `.cpp` 분리) | **1개** (`game.py`) |
| 도메인 코드 라인(주석 제외, 근사) | ~141줄 | ~213줄 | **~50줄** |
| 빌드/설정 | `build.gradle.kts` + Gradle Wrapper | `CMakeLists.txt` (47줄) | `pyproject.toml` (34줄) |
| 핵심 로직 런타임 의존성 | Spring Boot | 없음 | **없음** (전부 표준 라이브러리) |
| 테스트 도구 | JUnit 5 | GoogleTest (최초 빌드 시 네트워크 다운로드) | pytest |
| 웹 계층 | Spring MVC (Controller + ExceptionHandler + 부트 진입점) | 없음 | **FastAPI 함수 1개** |
| 난수 주입(테스트용) | 인터페이스 + 생성자 주입 | `RandomSource` 추상클래스 + `unique_ptr` | **`Callable` 인자 1개** |
| CJK 인자 처리 | JVM 이 유니코드 | Windows `wmain` UTF‑16→UTF‑8 변환 필요 | **`str` 이 곧 유니코드 — 처리 불필요** |

> 라인 수는 "적을수록 무조건 좋다"는 뜻이 아닙니다. Spring/C++ 의 무게 상당수는
> 성능·타입 안전·대규모 협업을 위한 대가입니다. 이 표는 "**같은 작은 문제**를 풀 때 Python 의
> 표현이 얼마나 가벼운가"를 보여주는 용도입니다. 장단점은 docs/01 에서 다룹니다.

## 프로젝트 구조

```
rock-paper-scissors-python
├── pyproject.toml            # 프로젝트 메타 + 의존성 (Gradle/CMake 에 대응)
├── requirements.txt          # 설치 목록 (pyproject 와의 차이는 docs/02 참고)
├── src/rps/
│   ├── game.py               # 도메인 전체: Hand · Outcome · GameResult · parse_hand · judge · RockPaperScissors
│   ├── cli.py                # CLI 진입점 (python -m rps 바위, 인자 없으면 input())
│   ├── web.py                # FastAPI REST API (선택 의존성, Spring 컨트롤러에 대응)
│   ├── __main__.py           # python -m rps 실행 지원
│   └── __init__.py           # 공개 심볼 export
├── tests/
│   ├── test_game.py          # RockPaperScissorsTest 에 대응
│   ├── test_hand_parser.py   # HandParserTest 에 대응
│   └── test_cli.py           # CLI 인자·대화식 입력 경로
├── docs/                     # 읽는 문서 (마크다운)
│   ├── 01~04 *.md            # CS 기초 · Python 환경 · 문법 · 언어 비교
│   └── labs/                 # 실습 랩 6종 + 안내
└── slides/                   # 강의 슬라이드 (발표 자료)
    ├── index.html            # 22장 — 브라우저로 열기
    ├── slides.css            # 스타일 (분리)
    └── slides.js             # 내비게이션 (분리)
```

## 빠른 시작

### 1) uv (권장 — 가장 빠름)

```powershell
uv sync                      # 가상환경 생성 + 의존성 설치
uv run python -m rps 바위    # 인자를 주면 그대로 한 판
uv run python -m rps         # 인자 없이 실행하면 대화식으로 입력받음 (input())
uv run pytest                # 테스트
```

### 2) 표준 venv + pip

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1     # macOS: source .venv/bin/activate
pip install -e ".[dev]"
python -m rps 바위
pytest
```

### 3) 설치 없이 바로 실행

핵심 로직은 표준 라이브러리만 쓰므로, 경로만 잡아 주면 설치 없이 돌아갑니다.

```powershell
$env:PYTHONPATH = "src"
python -m rps 가위
python -m pytest             # pyproject 의 pythonpath 설정으로 그냥 실행돼도 됨
```

### 웹 API (선택)

```powershell
uv sync --extra web                                        # 또는: pip install -e ".[web]"
uv run uvicorn rps.web:app --reload                        # 개발 서버 → http://127.0.0.1:8000
```

> **운영 서버**: 실제 배포는 대개 리눅스이며 `gunicorn -k uvicorn.workers.UvicornWorker rps.web:app` 를 씁니다.
> gunicorn 은 **유닉스용**이라 macOS 에서는 그대로 실행되고, Windows 에서는 직접 실행되지 않아
> **WSL·Docker(= 실제 배포 환경)** 로 돌립니다. Windows 로컬 개발은 `uvicorn`(필요시 `--workers 4`)으로 충분합니다.
> 자세히는 [랩 06](docs/labs/06-웹서버-uvicorn-gunicorn.md).

```bash
curl "http://127.0.0.1:8000/api/play?h=rock"
# {"player":"ROCK","computer":"SCISSORS","outcome":"WIN"}
```

## 입력 (다국어 허용)

CLI 인자와 웹 `h` 파라미터 모두 아래를 받습니다. CLI 는 인자를 생략하면 **`input()` 으로
대화식 입력**을 받고, 거기서 엔터만 치거나 입력이 없으면 `rock` 으로 진행합니다.

- 영어: `rock` / `paper` / `scissors` (`r` / `p` / `s`)
- 한국어: `바위` / `보` / `가위`, `묵` / `빠` / `찌`
- 일본어: `グー` / `パー` / `チョキ`
- 중국어: `石头` / `布` / `剪刀`

알 수 없거나 비어 있는 입력 → CLI 는 stderr + 종료 코드 `1`, 웹은 `400 Bad Request`.
