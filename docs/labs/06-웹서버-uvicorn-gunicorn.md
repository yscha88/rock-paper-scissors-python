# 랩 06 — 웹 서버로 띄우기 (uvicorn / gunicorn)

**목표**: 가위바위보를 **웹 API** 로 띄워 브라우저·`curl` 로 호출한다. 개발용 서버(uvicorn)와
운영용 서버(gunicorn)의 차이, 그리고 **gunicorn 은 Windows 에서 못 돈다**는 중요한 사실을 익힌다.

> 소요 시간 10분 · 준비물: 웹 의존성 설치(`uv sync --extra web` 또는 `pip install -r requirements.txt`)

## 0. 개념 — 프레임워크 vs 서버
Python 웹은 보통 **둘을 분리**해 조합합니다(→ [02-python-환경](../02-python-환경.md)).
- **프레임워크**(FastAPI): "요청이 오면 무슨 로직을 실행할지"를 정의. 이 저장소의 `rps/web.py`.
- **서버**(uvicorn/gunicorn): 실제로 포트를 열고 요청을 받아 프레임워크에 넘김.

Java 의 Spring Boot 는 이 서버(내장 Tomcat)를 프레임워크 안에 품고 있어 구분이 안 보이지만,
Python 은 명시적으로 서버를 골라 실행합니다.

## 1. 웹 의존성 설치
```powershell
cd C:\repo\yscha88\rock-paper-scissors-python
uv sync --extra web          # 또는:  pip install -r requirements.txt
```

## 2. 개발 서버 — uvicorn
```powershell
uv run uvicorn rps.web:app --reload
```
- `rps.web:app` = "`rps/web.py` 안의 `app` 객체를 띄워라".
- `--reload` = 코드를 고치면 자동 재시작(개발 편의).

예상 출력:
```
INFO:     Started server process [19960]
INFO:     Waiting for application startup.
INFO:     Application startup complete.
INFO:     Uvicorn running on http://127.0.0.1:8000 (Press CTRL+C to quit)
```

## 3. 호출해 보기
서버를 켠 채로 **다른 터미널**에서:
```powershell
curl "http://127.0.0.1:8000/api/play?h=rock"
```
정상 응답:
```json
{"player":"ROCK","computer":"ROCK","outcome":"DRAW"}
```
잘못된 입력이면 **400** 과 이유가 옵니다:
```powershell
curl "http://127.0.0.1:8000/api/play?h=lizard"
```
```json
{"detail":"알 수 없는 손 입력: 'lizard'"}
```
브라우저 주소창에 `http://127.0.0.1:8000/docs` 를 치면 FastAPI 가 만든 **자동 문서(Swagger)** 도
볼 수 있습니다. 서버는 켠 터미널에서 **Ctrl+C** 로 끕니다.

## 4. 운영 서버 — gunicorn (배포 환경은 대개 리눅스)

운영 환경에서는 요청을 안정적으로 **동시에 많이** 처리하려고 **gunicorn** 으로 워커(작업
프로세스)를 여러 개 띄웁니다. FastAPI(ASGI)는 gunicorn 위에 **uvicorn 워커**를 얹어 돌립니다.
```bash
gunicorn -k uvicorn.workers.UvicornWorker rps.web:app --workers 4
```
gunicorn 은 리눅스/유닉스용 도구이고, 실제 서비스도 대개 **리눅스 서버나 도커 컨테이너**에서
돌립니다. 그래서 Windows 에서 개발하더라도 gunicorn 은 그 **배포 환경(리눅스)** 에서 쓰면 됩니다.

### Windows 에서 gunicorn 을 쓰는 법 — WSL 또는 Docker
Windows 에서 gunicorn 을 직접 실행하면 리눅스 전용 모듈(`fcntl`) 때문에 뜨지 않습니다
(`ModuleNotFoundError: No module named 'fcntl'`). 이는 "gunicorn 이 설 자리는 리눅스"라는
뜻일 뿐이며, 아래 둘은 **실제 배포와 같은 리눅스 환경**을 그대로 줍니다.

- **WSL**(Windows Subsystem for Linux) — Windows 안의 리눅스에서 그대로:
  ```bash
  # WSL(우분투 등) 터미널에서
  gunicorn -k uvicorn.workers.UvicornWorker rps.web:app --workers 4
  ```
- **Docker** — 리눅스 컨테이너로 빌드해 실행(배포와 동일 환경). 최소 예:
  ```dockerfile
  FROM python:3.13-slim
  WORKDIR /app
  COPY . .
  RUN pip install -e ".[web]"
  CMD ["gunicorn", "-k", "uvicorn.workers.UvicornWorker", "rps.web:app", "--bind", "0.0.0.0:8000"]
  ```

### macOS 는 유닉스 계열이라 그대로 돈다
macOS 에서는 gunicorn 이 **네이티브로 바로 실행**됩니다 — 별도 절차가 필요 없습니다:
```bash
gunicorn -k uvicorn.workers.UvicornWorker rps.web:app --workers 4
```
즉 "gunicorn 이 직접 안 도는 곳"은 Windows 뿐이고, 그마저 WSL·Docker 로 해결됩니다.

### Windows 로컬 개발은 uvicorn 으로
가벼운 개발/테스트는 uvicorn 이면 충분하고, 다중 워커도 됩니다.
```powershell
uv run uvicorn rps.web:app --host 0.0.0.0 --port 8000 --workers 4
```

> 이건 [01-cs-기초](../01-cs-기초.md) 의 "같은 코드도 OS·환경에 따라 다르다"의 실제 사례입니다.
> 그래서 요즘은 개발·배포 환경을 리눅스(WSL·Docker)로 맞추는 흐름이 강합니다.

## 5. 정리
서버는 Ctrl+C 로 끄고, 설치한 가상환경은 [랩 03](03-uv.md)의 정리 단계처럼 `.venv` 를 지우면 됩니다.

이전: [랩 목록](README.md)
