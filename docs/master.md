# master — 강의 구조 SSOT

> 이 파일이 **강의(슬라이드)의 구조적 단일 진실 원천**입니다. 슬라이드를 추가·이동·수정하면
> 이 표를 먼저 고치고, `python tools/verify_slides.py` 로 slides/index.html 이 이 표를
> 충실히 반영하는지 **적대적으로 검증**합니다.

## 전제 (변경 시 저자 컨펌 필수)

- **청중**: AI 대학원생. conda/GPU 가 주력이 될 사람들 — 폄하 프레이밍 금지.
- **매체**: 수강생은 **슬라이드만** 본다. md(docs/·labs/)는 강사·저장소 방문자용.
  내용의 무게중심은 슬라이드에 둔다.
- **원본 pptx**(`강의 개요.pptx` 계열)는 **디자인·대화 농도의 참조**이지 순서 기준이 아니다.
  단, 원본에서 온 요소(대학원생 class 조크 = 아이스브레이킹)는 형태·예시·톤을 보존한다.

## 구조 규칙 (검증 스크립트가 강제)

1. **위치 참조 금지** — 본문에서 "N장"은 챕터 이름(01~05장)만 허용. 슬라이드 번호 참조는
   이름 기반("'고정 vs 범위' 장")으로 쓴다.
2. **eyebrow 스키마** — `{챕터} · {소단원}`. 소단원 명칭은 아래 표가 정의하는 것만 사용.
3. **챕터 앵커** — `intro / sec01~04 / secdbg / seclabs / lab01~06 / secend` 가 각 구획의
   **첫 슬라이드**에 있어야 한다(챕터 내비·바로가기가 이 id 로 동작).
4. **금지 표기** — "애너테이션"(→ 어노테이션), "(over)"/"(down)"(→ 하한/상한),
   "Windows 미지원"(→ 유닉스용, WSL·Docker).
5. 문서(docs 01~05 + labs)와 챕터는 1:1 대응을 유지한다. 디버깅 슬라이드 ↔ `05-디버깅.md`.

## 덱 구조 (55장)

형식: `| # | 챕터 | eyebrow | h2 핵심 | 필수 키워드(;구분) |`
— 검증기는 ①순서·개수 ②eyebrow 일치 ③h2 포함 ④키워드 존재를 확인한다.

| # | 챕터 | eyebrow | h2 핵심 | 필수 키워드 |
|---|---|---|---|---|
| 1 | 개요 | 강의 개요 | 가위바위보로 배우는 | Java;C++20;코딩 입문 |
| 2 | 개요 | 이 강의의 논지 | Code를 이해한다는 것 | age++;버그를 찾아보세요;PhD |
| 3 | 개요 | 커리큘럼 | 문서 5편 + 실습 6종 | 05 · 디버깅;실습 06;pinning |
| 4 | 01 | 01 · CS 기초 | 레시피와 요리사 | 기계어;어셈블리;요리사 |
| 5 | 01 | 01 · CS 기초 | AI 시대에는 층이 하나 | 프롬프트;GPU;군말 없이 |
| 6 | 01 | 01 · CS 기초 | 번역을 "언제" 하느냐 | 컴파일;인터프리터;JVM |
| 7 | 01 | 01 · CS 기초 | 어셈블리라는 중간역 | 전처리기;링커;idiv |
| 8 | 01 | 01 · CS 기초 | 빌드의 유무 | cmake;gradlew;python -m rps |
| 9 | 01 | 01 · CS 기초 | 정적 타입 vs 동적 타입 | mypy;점진적 타이핑;Pydantic |
| 10 | 01 | 01 · CS 기초 | 메모리 — 빌리고 | 작업대;누수!;할당 |
| 11 | 01 | 01 · CS 기초 | 설거지는 누가 | malloc;unique_ptr;pause |
| 12 | 01 | 01 · CS 기초 | GC가 있어도 | ThreadLocal;Metaspace;-Xmx |
| 13 | 01 | 01 · CS 기초 | 강점과 약점 | GIL;배터리 포함;사람의 시간 |
| 14 | 02 | 02 · Python 환경 | 엔진과 연료 | site-packages;충돌;.venv |
| 15 | 02 | 02 · Python 환경 | 도구 지도 | uv ⭐;conda ⭐;WSL·Docker |
| 16 | 02 | 02 · 의존성 & 버전 | 고정(pinning) vs 범위 | lower bound;~=1.2.3;requires-python |
| 17 | 03 | 03 · Python 문법 | 변수 · 함수 · 클래스가 뭔가요 | 상자;붕어빵;인자 |
| 18 | 03 | 03 · 변수 | 선언 없이, 값이 곧 타입 | _ALIASES;대문자;str |
| 19 | 03 | 03 · 함수 | def — 기본값 | 들여쓰기;일급;secrets.randbelow |
| 20 | 03 | 03 · 쏟아지는 질문들 | 변수? 상수? 일급? | 常數;Final;second-class |
| 21 | 03 | 03 · 클래스 도입 | class 란 무엇인가 | 대학원생;추상화;재사용 |
| 22 | 03 | 03 · 클래스 | 멤버 변수는 어디서 | sizeof;__dict__;this |
| 23 | 03 | 03 · 클래스 심화 | 던더 — 문법을 메서드로 | Double;__sub__;operator== |
| 24 | 03 | 03 · 클래스 심화 | 자주 쓰는 __던더__ | __getitem__;scores.txt;__main__ |
| 25 | 03 | 03 · 클래스 심화 | 상속 — 사실 이미 | GradStudent;super();IntEnum |
| 26 | 03 | 03 · 정적 타입의 대안 | dataclass vs Pydantic | ValidationError;PlayResponse;의존성 0 |
| 27 | 03 | 03 · @ 의 정체 | 데코레이터 vs Java 어노테이션 | bar = foo(bar);리플렉션;@GetMapping |
| 28 | 03 | 03 · 예외 처리 | 라벨을 붙이는 계층 | from exc;삼키지 않는다;ValueError |
| 29 | 04 | 04 · 언어 비교 | 같은 게임, 다른 무게 | 스캐폴딩;unique_ptr;IntEnum |
| 30 | 04 | 04 · 비교의 원칙 | 한 줄만 보면 착시 | player.code();fromCode;34줄 |
| 31 | 04 | 04 · 전체 구현 ① | 손 열거형 | fromCode;IntEnum;41줄 |
| 32 | 04 | 04 · 전체 구현 ② | 난수 주입 | RandomSource;random_device;lambda |
| 33 | 04 | 04 · 전체 구현 ③ | 다국어 파서 | normalize;strip().lower();86줄 |
| 34 | 04 | 04 · 전체 구현 ④ | 웹 계층 | @RestController;HTTPException;71줄 |
| 35 | 04 | 04 · 언어 비교 · 요약 | 같은 기능, 필요한 | 1줄 record;86줄·2파일;71줄·3클래스 |
| 36 | 04 | 04 · 규모가 커지면 | 격차는 더 벌어진다 | Bean;쿠버네티스;투자 |
| 37 | 디버깅 | 디버깅 · 실행 순서 | 순서가 어긋나면 | static initialization;NameError;호이스팅 |
| 38 | 디버깅 | 디버깅 · OOM의 정체 | OOM — "메모리 부족"이 | OOM Killer;cgroup;위장 |
| 39 | 디버깅 | 디버깅 · 에러 라벨 | 해결책이 수십 개 | CommitMono;bad_alloc;이벤트 뷰어 |
| 40 | 디버깅 | 디버깅 · 종합 | CS를 모르면 잡을 수 없는 | 0.1+0.2;아래층;인코딩 |
| 41 | 실습 | 실습 · Labs | 실습 랩 6종 | 압축 해제;uv sync;WSL·Docker |
| 42 | 실습 | 실습 01 · 바이너리 직접 실행 | "설치"와 "직접 실행" | embeddable;레지스트리;py --list |
| 43 | 실습 | 실습 01 · 바이너리 직접 실행 | 받아서, 풀고 | Expand-Archive;python313.zip;tar -xzf |
| 44 | 실습 | 실습 01 · 바이너리 직접 실행 | 함정 → 해법 → 교훈 | No module named;._pth;Remove-Item |
| 45 | 실습 | 실습 02 · venv + pip | 상자를 만들고 | Activate.ps1;source .venv;Set-ExecutionPolicy |
| 46 | 실습 | 실습 02 · venv + pip | 설치 두 경로 | freeze;editable;'고정 vs 범위' 장 |
| 47 | 실습 | 실습 03 · uv | 실측 데모 | 클릭 = 다시 재생;실측;winget |
| 48 | 실습 | 실습 03 · uv | 잠금(uv.lock) | uv add;uv python install;커밋 대상 |
| 49 | 실습 | 실습 04 · poetry | 의존성 관리 + 패키징 | pipx;poetry install;poetry run |
| 50 | 실습 | 실습 04 · poetry | 캐럿과 틸데 | ^1.2.3;poetry new;'고정 vs 범위' 장 |
| 51 | 실습 | 실습 05 · conda | 여러분의 주력 | conda-forge;CUDA;GPU 환경 세팅 |
| 52 | 실습 | 실습 05 · conda | 만들고, 쓰고 | conda create;pytorch-cuda;Miniconda |
| 53 | 실습 | 실습 06 · 웹 서버 배포 | uvicorn으로 띄우고 | --reload;Swagger;400 |
| 54 | 실습 | 실습 06 · 웹 서버 배포 | gunicorn — 어디서 | fcntl;COPY . .;UvicornWorker |
| 55 | 끝 | 마무리 | 직접 만들 차례 | git clone;_ALIASES;uv sync |

## 챕터 앵커 ↔ 슬라이드

| id | 위치 |
|---|---|
| intro | #1 타이틀 |
| sec01 | #4 (01장 시작) |
| sec02 | #14 |
| sec03 | #17 |
| sec04 | #29 |
| secdbg | #37 (디버깅 시작 — 실행 순서) |
| seclabs | #41 (실습 개요) |
| lab01~06 | 각 실습의 첫 슬라이드 (#42/#45/#47/#49/#51/#53) |
| secend | #55 |
