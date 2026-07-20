# 랩 02 — venv + pip + requirements.txt (그리고 버전 고정 vs 범위)

**목표**: 표준 도구 `venv` 로 격리된 가상환경을 만들고, `pip` 으로 패키지를 설치하고,
`requirements.txt` 가 무엇이며 `pyproject.toml` 과 어떻게 다른지, 그리고 **버전을 고정(`==`)하는
것과 범위(`>=`/`<=`)로 두는 것**의 차이를 손으로 확인한다.

> 소요 시간 15분 · 준비물: PowerShell, 인터넷(패키지 다운로드)

## 0. 개념 — 가상환경은 "프로젝트 전용 상자"

파이썬을 컴퓨터에 하나만 깔고 모든 프로젝트가 공유하면, A 프로젝트는 `fastapi` 최신이,
B 프로젝트는 옛 버전이 필요할 때 **충돌**합니다. **가상환경(venv)** 은 프로젝트마다
"전용 파이썬 + 전용 패키지 폴더"를 따로 만들어 이 충돌을 막습니다.

```
전역 파이썬 (python.exe)
   └── .venv/                 ← 이 프로젝트만의 상자
        ├── Scripts/python.exe (이 상자 전용 파이썬)
        ├── Scripts/pip.exe    (이 상자 전용 설치기)
        └── Lib/site-packages/ (여기에만 설치됨)
```

## 1. 가상환경 만들기
```powershell
# Windows
cd C:\repo\yscha88\rock-paper-scissors-python
py -3.11 -m venv .venv
```
```bash
# macOS (py 런처가 없으므로 python3.11 또는 python3 로)
cd ~/repo/rock-paper-scissors-python
python3.11 -m venv .venv
```
`.venv` 라는 폴더가 생깁니다. `py -3.11` 로 만들었으니 이 상자의 파이썬은 3.11 입니다.

## 2. 활성화(activate) — 상자 "안으로" 들어가기
```powershell
# Windows
.\.venv\Scripts\Activate.ps1
```
```bash
# macOS
source .venv/bin/activate
```
성공하면 프롬프트 앞에 `(.venv)` 가 붙습니다.
```
(.venv) PS C:\repo\yscha88\rock-paper-scissors-python>
```
> **막힐 때(Windows 자주 겪는 오류)**: "이 시스템에서 스크립트를 실행할 수 없으므로..." 라고
> 나오면, 아래로 이 터미널에서만 허용한 뒤 다시 시도하세요.
> ```powershell
> Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
> ```
> 또는 활성화 대신 `.\.venv\Scripts\activate.bat` 를 써도 됩니다.

이제 `python` 은 상자 안의 3.11 을 가리킵니다:
```powershell
python --version        # Python 3.11.9
```

## 3. 방법 A — 이 프로젝트 자체를 설치 (`pyproject.toml` 기반)
```powershell
pip install -e ".[dev]"
```
- `-e` = **editable(편집 가능)** 설치. 소스를 고치면 바로 반영됩니다.
- `.` = 현재 폴더의 프로젝트. `pip` 은 **`pyproject.toml`** 을 읽어 설치합니다.
- `[dev]` = `pyproject.toml` 의 선택 의존성 중 `dev`(pytest)까지 포함.

설치 후엔 `rps` 명령과 테스트가 됩니다:
```powershell
rps 바위
pytest -q
```
예상 출력:
```
당신: ROCK / 컴퓨터: PAPER -> LOSE
........................................                                 [100%]
40 passed in 0.08s
```

## 4. 방법 B — `requirements.txt` 로 설치
웹 기능을 돌리려면 외부 패키지(fastapi 등)가 필요합니다. 그 목록이 `requirements.txt` 입니다.
```powershell
pip install -r requirements.txt
```
`-r` = "이 파일에 적힌 목록을 설치하라". 이 저장소의 파일 내용:
```
fastapi>=0.110,<1.0
uvicorn[standard]>=0.29
gunicorn>=21.2
```
설치되면 웹 서버를 띄울 수 있습니다(자세히는 [랩 06](06-웹서버-uvicorn-gunicorn.md)).

### `pyproject.toml` vs `requirements.txt` — 무엇이 다른가?

| | `pyproject.toml` | `requirements.txt` |
|---|---|---|
| 성격 | 프로젝트 **정의서** (이름·버전·의존성·빌드·스크립트) | 설치할 패키지 **목록**(플랫한 리스트) |
| 주 용도 | 이 코드를 **패키지로 배포/설치** | 특정 환경을 **그대로 재현**해 설치 |
| 버전 표기 | 보통 **느슨한 범위**(`>=`) | 느슨하게도, **정확히 고정**해서도(`==`) |
| 도구 | pip / uv / poetry / hatchling … | pip / uv |
| 비유 | "이 앱은 무엇인가"(레시피) | "지금 냉장고에 정확히 이것들"(장보기 목록) |

> 실무 흐름: **개발할 땐 `pyproject.toml`** 에 느슨한 범위로 적고,
> **배포·서버엔 정확히 고정한 목록**(`requirements.txt` 또는 lock 파일)으로 재현합니다.

## 5. 핵심 — 버전 "고정(pinning)" vs "범위(하한·상한)"

패키지 버전을 어떻게 적느냐에 따라 설치되는 버전이 달라집니다.

| 표기 | 의미 | 예 |
|---|---|---|
| `fastapi==0.110.0` | **정확히 그 버전**만 (고정/pinning) | 0.110.0 만 |
| `fastapi>=0.110` | 그 버전 **이상** (하한, lower bound / at least) | 0.110, 0.111, 1.5 … |
| `fastapi<=0.110` | 그 버전 **이하** (상한, upper bound / at most) | 0.110, 0.109 … |
| `fastapi>=0.110,<1.0` | **범위**(이상 + 미만) | 0.110 ~ 0.999 |
| `fastapi~=0.110.0` | **호환 범위**: `>=0.110.0,<0.111.0` 과 같음 | 0.110.x 만 |
| `fastapi!=0.111` | 특정 버전 **제외** | 0.111 빼고 |

### 왜 고정과 범위를 구분하나? (트레이드오프)
- **범위(`>=`)의 장점**: 자동으로 최신 버그픽스를 받는다. **단점**: 어느 날 올라온 새 버전이
  호환을 깨서 "어제는 됐는데 오늘 안 됨"이 생길 수 있다.
- **고정(`==`)의 장점**: 언제 설치해도 **똑같은 버전** → 재현 가능·안정적. **단점**: 보안·버그픽스를
  받으려면 사람이 직접 올려야 한다.

### 직접 실험해 보기
지금 설치된 정확한 버전을 확인:
```powershell
pip show fastapi        # Version: 0.11x.x 확인
pip list                # 설치된 전체 목록
```
지금 환경을 **그대로 고정한 목록**으로 뽑아내기(스냅샷):
```powershell
pip freeze > requirements-lock.txt
```
`requirements-lock.txt` 를 열어 보면 모든 패키지가 `이름==정확한버전` 으로 박혀 있습니다.
이 파일로 설치하면 **누구나 똑같은 버전 조합**을 재현합니다 — 이것이 "lock(잠금)"의 개념입니다.
(uv·poetry 는 이 잠금을 `uv.lock`·`poetry.lock` 으로 자동 관리합니다 → 랩 03·04)

> **Python 버전 자체의 제약**도 있습니다. `pyproject.toml` 의 `requires-python = ">=3.11"` 은
> "이 프로젝트는 파이썬 3.11 이상에서만"이라는 뜻입니다(패키지 버전과 같은 하한/상한 개념).

> **용어 메모**: `>=`·`<=` 의 정식 용어는 **하한(lower bound)·상한(upper bound)**, 또는
> "greater/less than or equal to" 입니다(PEP 440 은 `>=`·`<=` 를 *inclusive ordered comparison*
> 이라 부름). 한국어 "이상/이하"는 정확한 번역이고, "고정"은 영어로 **pinning** 입니다.

## 6. 비활성화 & 정리
상자에서 나오기:
```powershell
deactivate
```
실습 흔적을 완전히 지우려면 폴더만 삭제하면 됩니다(원상복구):
```powershell
# Windows
Remove-Item -Recurse -Force .venv
Remove-Item requirements-lock.txt
```
```bash
# macOS
rm -rf .venv requirements-lock.txt
```

다음: [랩 03 — uv](03-uv.md)
