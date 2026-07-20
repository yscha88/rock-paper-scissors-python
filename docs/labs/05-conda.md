# 랩 05 — conda (과학/데이터용 환경 관리)

**목표**: `conda` 로 가상환경을 만들고 가위바위보를 실행한다. 그러면서 `conda` 가 `pip`/`uv` 와
무엇이 다른지 — **파이썬이 아닌 네이티브 패키지까지 함께 관리**한다는 점 — 을 이해한다.

> 소요 시간 15분(설치 포함) · 준비물: PowerShell, 인터넷
> ⚠️ 이 PC 에는 conda 가 **아직 없습니다**. 1단계에서 Miniconda 를 설치합니다.
> (아래는 예상 출력입니다.)

## 0. 개념 — conda 는 왜 따로 있나
`pip` 은 **파이썬 패키지**만 다룹니다. 그런데 데이터 과학/머신러닝에서 쓰는 라이브러리
(numpy, scipy, PyTorch 등)는 내부에 **C/C++/포트란/CUDA 같은 네이티브 코드**를 품고 있어,
그 밑단까지 딱 맞게 깔아 줘야 합니다. `conda` 는 **파이썬 + 그 네이티브 스택 전체**를 하나의
환경으로 관리해, 이런 호환성 문제를 줄여 줍니다.

| | pip / uv | conda |
|---|---|---|
| 다루는 것 | 파이썬 패키지 | 파이썬 + **네이티브** 패키지(비-파이썬 포함) |
| 패키지 출처 | PyPI | conda 채널(conda-forge 등) |
| 강점 분야 | 웹·일반 앱 | 과학·데이터·ML |

## 1. Miniconda 설치
"Miniconda" 는 conda 의 **최소 설치판**입니다(전체판인 Anaconda 보다 가벼움).
- 다운로드: <https://www.anaconda.com/download/success> 에서 **Miniconda** 설치
  (Windows 64-bit / macOS 는 Apple Silicon·Intel 용 pkg, 또는 `brew install --cask miniconda`).
- 설치 후 — Windows: 시작 메뉴의 **"Anaconda Prompt"** 또는 PowerShell / macOS: 그냥 터미널 —
  에서 다음이 되면 성공 (**이후 conda 명령은 두 OS 동일**):
```powershell
conda --version            # 예: conda 24.x.x
```
> 처음 한 번은 `conda init powershell` 후 터미널을 재시작해야 PowerShell 에서 `conda activate` 가
> 동작합니다.

## 2. 환경 만들기 (파이썬 버전을 콕 집어서)
```powershell
conda create -n rps python=3.11
conda activate rps
python --version           # Python 3.11.x
```
- `-n rps` = 환경 이름을 `rps` 로.
- conda 는 `.venv` 폴더 대신 **이름으로** 환경을 관리합니다(`conda env list` 로 목록 확인).
- 활성화하면 프롬프트 앞에 `(rps)` 가 붙습니다.

## 3. 이 저장소 실행
핵심 로직은 외부 패키지가 없으므로 바로 됩니다.
```powershell
cd C:\repo\yscha88\rock-paper-scissors-python
pip install -e .           # conda 환경 안에서 pip 을 써도 됩니다
rps 바위
```
> **conda 안에서 pip?** 됩니다. 다만 원칙은 "conda 로 설치 가능한 건 conda 로, 없는 것만 pip 으로".
> 웹 의존성(fastapi 등)은 `pip install -r requirements.txt` 로 설치하면 됩니다.

## 4. 정리
```powershell
conda deactivate
conda remove -n rps --all  # rps 환경 통째로 삭제
```

> **왜 이 실습이 중요한가**: AI/ML 연구 환경에서는 PyTorch·CUDA·MKL 같은 네이티브 스택 때문에
> **conda 가 사실상 표준**입니다 — 연구실에 들어가면 가장 먼저 만나는 도구일 가능성이 높습니다.
> 가위바위보는 일부러 작은 예제일 뿐, 여기서 익힌 `create → activate → install → remove` 흐름이
> **그대로 GPU 환경 세팅으로 이어집니다.** (순수 파이썬 소품이라면 uv/venv 로도 충분하지만,
> 그 판단 기준 — "네이티브 스택이 얽히는가" — 을 갖추는 것까지가 이 실습의 목표입니다.)

다음: [랩 06 — 웹 서버 배포](06-웹서버-uvicorn-gunicorn.md)
