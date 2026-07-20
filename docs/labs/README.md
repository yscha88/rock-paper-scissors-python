# 실습(Lab) 모음 — 환경/도구를 직접 만들어 보기

[02-python-환경](../02-python-환경.md) 에서 **개념**으로 배운 도구들을, 여기서는 **손으로 직접**
만들어 봅니다. 가위바위보를 각 방식으로 실행하는 게 목표입니다.

## 이 문서는 "코딩 처음"을 가정합니다 — 먼저 알아둘 것

### 터미널(terminal)이란?
컴퓨터에 **글자 명령을 입력해 실행**하는 창입니다. 마우스로 아이콘을 누르는 대신, 명령어를
타이핑해서 프로그램을 실행합니다. 이 실습은 **Windows 는 PowerShell, macOS 는 기본 터미널(zsh)**
기준이며, 명령이 다른 곳은 실습마다 **둘 다 표기**합니다.

- 열기 — Windows: 시작 메뉴에서 **"PowerShell"** 검색 → 실행 /
  macOS: ⌘+Space → **"터미널"** 검색 → 실행. (또는 VS Code 안의 터미널)
- 프로젝트 폴더로 이동: `cd C:\repo\yscha88\rock-paper-scissors-python` (Windows) /
  `cd ~/repo/rock-paper-scissors-python` (macOS — 실제 클론 위치에 맞게)
  (`cd` = change directory, 폴더 이동 명령)

### "명령을 실행한다"는 것
아래처럼 회색 상자에 있는 줄을 **한 줄씩 복사해 붙여넣고 Enter** 를 누르면 됩니다.
```powershell
python --version
```
맨 앞의 `python` 은 **프로그램 이름**, 뒤의 `--version` 은 그 프로그램에 주는 **옵션**입니다.
성공하면 보통 결과가 출력되고, 실패하면 빨간 오류 메시지가 나옵니다.

### 프롬프트(prompt) 읽는 법
명령을 입력하는 자리 앞에 `PS C:\...>` 같은 표시가 있습니다. 가상환경을 켜면 이 앞에
`(.venv)` 같은 **접두사**가 붙어서 "지금 이 환경 안에 있다"는 걸 알려줍니다.
```
(.venv) PS C:\repo\yscha88\rock-paper-scissors-python>
 ^^^^^^ 이게 붙으면 가상환경 활성화 상태
```

### 이 PC 에 이미 깔려 있는 것 (2026-07 기준 확인됨)
- Python **3.11 / 3.12 / 3.13 / 3.15** (여러 버전 공존) — `py --list` 로 확인
- **uv**, **pip**, **venv**, **pipx** 사용 가능
- **poetry · conda** 는 아직 없음 → 해당 랩에 설치 단계 포함

## 랩 목록 (순서대로 하면 좋음)

| # | 랩 | 배우는 것 |
|---|---|---|
| 01 | [바이너리 직접 실행](01-바이너리-직접-실행.md) | 설치 없이 **zip(embeddable)을 받아 압축만 풀고** `python.exe` 직접 실행 — 인터프리터의 정체 |
| 02 | [venv + pip + requirements](02-venv-pip-requirements.md) | 표준 가상환경, 패키지 설치, `requirements.txt`, **버전 고정/범위** |
| 03 | [uv](03-uv.md) | 요즘 가장 빠른 통합 도구 |
| 04 | [poetry](04-poetry.md) | 의존성 관리 + 패키징 도구 |
| 05 | [conda](05-conda.md) | 과학/데이터용 환경 관리 |
| 06 | [웹 서버 배포 (uvicorn/gunicorn)](06-웹서버-uvicorn-gunicorn.md) | 개발·운영 서버 구동, gunicorn 의 Windows 제약 |

> **팁**: 각 랩은 끝에 **"정리(삭제)"** 단계가 있습니다. 실습으로 만든 `.venv` 폴더 등은
> 그냥 삭제하면 원상복구됩니다. 겁내지 말고 만들고 지워 보세요.
