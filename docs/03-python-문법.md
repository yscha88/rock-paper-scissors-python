# 03. Python 문법 — 변수 · 함수 · 클래스 (이 repo 코드로)

> **코딩이 처음이어도** 따라올 수 있게 용어를 하나씩 풀어 씁니다. `src/rps/game.py` 와 `cli.py` 의
> **실제 코드**를 예제 삼아, Python 의 변수·함수·클래스를 Java/C++ 와 비교하며 봅니다.

## 0. 먼저: 변수·함수·클래스가 뭔가요? (비유로)

| 개념 | 비유 | 한 줄 설명 |
|---|---|---|
| **변수(variable)** | 이름표 붙은 **상자** | 값을 넣어 두고, 이름으로 꺼내 쓴다 (`player = Hand.ROCK`) |
| **함수(function)** | 재료를 넣으면 결과를 주는 **기계** | 입력을 받아 정해진 일을 하고 결과를 돌려준다 (`judge(...)`) |
| **클래스(class)** | 붕어빵 **틀**(설계도) | 같은 구조의 것을 여러 개 찍어 낸다. 찍힌 하나하나가 **인스턴스(객체)** |

몇 가지 동작 용어도 미리:

- **대입(assignment)**: `=` 로 값을 상자(변수)에 **넣는 것**. `x = 5` 는 "x 라는 상자에 5 를 넣어라".
  (수학의 "같다"가 아니라 "넣어라"입니다.)
- **호출(call)**: 함수/기계를 **작동시키는 것**. `judge(a, b)` 처럼 이름 뒤에 괄호 `()` 를 붙인다.
- **반환(return)**: 함수가 일을 끝내고 **결과를 돌려주는 것**.
- **인자/매개변수(argument/parameter)**: 함수에 **넣어 주는 값**(인자)과, 함수가 그걸 **받는 이름**(매개변수).

## 1. 변수 — 선언 없이, 값이 곧 타입

Python 변수는 **미리 선언할 필요 없이**, 그냥 `=` 로 값을 넣으면 생깁니다. 타입(값의 종류)은
변수가 아니라 **값** 쪽에 붙어 있습니다.

```python
player = Hand.ROCK        # player 라는 상자에 '바위'를 넣음 — player 는 Hand 타입
computer = Hand(2)        # Hand.SCISSORS (숫자 2로 손을 되찾음)
diff = (player - computer + 3) % 3   # 계산 결과를 diff 에 넣음 — diff 는 int(정수)
```
```java
// Java: 상자마다 앞에 타입(Hand, int)을 반드시 써 줘야 한다
Hand player = Hand.ROCK;
int diff = (player.code() - computer.code() + 3) % 3;
```
Java 는 `Hand player` 처럼 **타입을 앞에 선언**해야 하지만, Python 은 `player =` 로 **바로 넣습니다**.

### 타입 힌트 — 붙여도 되고 안 붙여도 되는 안전 표시
Python 은 원하면 타입을 **덧붙여 적을 수** 있습니다(**타입 힌트**). 실행에는 영향이 없고(파이썬은
런타임에 무시), `mypy`/`pyright` 같은 **검사 도구**와 에디터가 이를 읽어 실수를 미리 알려 줍니다.
이 repo 는 힌트를 적극적으로 씁니다.

```python
def parse_hand(text: str) -> Hand:      # 입력은 str(문자열), 결과는 Hand 라는 "약속"
    ...
_ALIASES: dict[str, Hand] = { ... }     # 변수에도 힌트를 달 수 있다 (문자열→Hand 사전)
```
- `text: str` — "text 는 문자열"이라는 표시. `-> Hand` — "이 함수는 Hand 를 돌려준다"는 표시.

> 즉 Python 은 **동적 타입이 기본**이되, 원할 때 **정적 타입의 이점**을 골라 쓸 수 있는
> "점진적 타이핑(gradual typing)"을 지원합니다.

### 상수 / 모듈 변수
Python 에는 "바꾸지 마"를 강제하는 `const` 키워드가 **없습니다**. 대신 관례로 **대문자**(`_ALIASES`)
로 적어 "이건 상수처럼 취급하세요"라고 신호합니다. 이름 앞의 `_`(밑줄)은 "이 파일 안에서만 쓰는
내부용"이라는 **관례**입니다(강제는 아님).

## 2. 함수 — `def`, 기본값, 그리고 "함수도 값이다"

함수는 **입력을 받아 결과를 돌려주는 기계**입니다. Python 에서는 `def` 로 만듭니다.

```python
def judge(player: Hand, computer: Hand) -> Outcome:   # 손 두 개를 받아 승패를 돌려준다
    diff = (player - computer + 3) % 3
    return (Outcome.DRAW, Outcome.WIN, Outcome.LOSE)[diff]   # 결과를 돌려줌(return)
```

- 형태는 `def 이름(매개변수) -> 반환타입:` 이고, **함수의 몸통은 들여쓰기**로 구분합니다
  (Java/C++ 의 중괄호 `{ }` 대신 **띄어쓰기**로 블록을 나눔 — Python 의 큰 특징).
- 클래스 안에 넣지 않고 **혼자 있는 함수(자유 함수)** 도 됩니다. Java 는 모든 함수를 클래스 안에
  넣어야 하지만, Python 은 그럴 필요가 없습니다.

### 기본값(default argument) — 안 주면 알아서
매개변수에 **기본값**을 정해 두면, 호출할 때 그 값을 생략할 수 있습니다.

```python
def main(argv: list[str] | None = None) -> int:   # argv 를 안 주면 None(없음)으로
    args = sys.argv[1:] if argv is None else argv
    ...
```
- `None` 은 "값이 없음"을 뜻하는 파이썬의 특별한 값입니다(Java 의 `null` 에 해당).

### 함수는 일급 객체(first-class) — 이 repo 의 핵심 장면

먼저 용어부터 — **"일급(first-class)"** 은 "언어 안에서 **값으로서의 모든 권리**를 가진다"는
뜻입니다. 구체적으로 네 가지 권리입니다:

① **변수에 담을** 수 있다 · ② **인자로 넘길** 수 있다 · ③ **반환값으로 돌려줄** 수 있다 ·
④ **자료구조(리스트·딕셔너리)에 넣을** 수 있다.

숫자·문자열은 어느 언어에서나 일급이지만, **함수**에게 이 네 권리를 다 주는 언어는 따로
있습니다 — Python 이 그렇습니다(C 는 함수 포인터로 흉내만 냈습니다):

```python
def greet(name):
    return f"안녕, {name}"

f = greet             # ① 변수에 담기 — 괄호가 없다! 함수 "자체"를 담는 것
f("철수")             #    담아 둔 함수를 호출 → '안녕, 철수'

def twice(fn, x):     # ② 함수를 인자로 받기
    return fn(fn(x))  # ③ (반환값으로 돌려주는 것도 가능)

table = {"인사": greet}   # ④ 딕셔너리 값으로 넣기
```

> **최대 함정** — `greet` (괄호 없음) = 함수 **자체**, `greet()` = 함수를 **실행한 결과**.
> 이 repo 에서 `rng=secrets.randbelow` 라고 쓰고 `randbelow()` 라고 쓰지 않는 이유가
> 정확히 이것입니다 — 괄호를 붙이면 "함수"가 아니라 "호출 결과(숫자 하나)"가 넘어가 버립니다.

이 시민권 덕분에 "컴퓨터 손을 뽑는 난수 기계"를 **인터페이스 없이 그냥 함수로 주입**할 수
있습니다:

```python
class RockPaperScissors:
    def __init__(self, rng: Callable[[int], int] = secrets.randbelow) -> None:
        self._rng = rng                    # 넘겨받은 '함수'를 그대로 저장

    def play(self, player):
        computer = Hand(self._rng(3))      # 저장해 둔 그 함수를 호출해 0~2 를 뽑음
        ...
```
- `Callable[[int], int]` 는 "정수 하나를 받아 정수를 돌려주는 **함수**"라는 타입 힌트입니다.
- 기본값 `secrets.randbelow` 는 **보안 난수 함수**(Java `SecureRandom` 에 해당)입니다.

테스트에서는 이 자리에 **직접 만든 함수(람다)** 를 끼워 결과를 확정합니다.
```python
game = RockPaperScissors(rng=lambda _bound: 2)   # 컴퓨터는 항상 SCISSORS(2)
```
- `lambda _bound: 2` 는 "무엇을 받든 항상 2 를 돌려주는 **이름 없는 짧은 함수**"입니다.

> C++/Java 는 이 "주입"을 위해 별도 **인터페이스/추상 클래스**를 선언해야 합니다
> (→ [04-언어-비교](04-언어-비교.md)). Python 은 **함수 하나를 넘기면** 끝입니다.

### 대화식 입력도 함수 호출 한 줄
```python
entered = input("손을 입력하세요 ...: ").strip()   # 키보드로 친 한 줄을 받아 옴
```
- `input(...)` 은 사용자가 **키보드로 입력한 한 줄**을 문자열로 돌려줍니다. `.strip()` 은 앞뒤 공백
  제거. Java 의 `Scanner`, C++ 의 `std::getline` 에 해당하지만, **함수 호출 한 번**이면 됩니다.

## 3. 클래스 — `class`, `self`, 그리고 "덜 쓰게 해 주는" 도구들

**클래스는 데이터(상태)와 그 데이터를 다루는 함수(동작)를 하나로 묶은 설계도**입니다. 설계도로
찍어 낸 실체 하나하나를 **인스턴스(instance) / 객체(object)** 라고 합니다.

### 기본 형태
```python
class RockPaperScissors:
    def __init__(self, rng=secrets.randbelow):   # 생성자: 인스턴스를 만들 때 한 번 불림
        self._rng = rng                          # 이 인스턴스의 속성(데이터)에 저장

    def play(self, player):                      # 메서드: 클래스 안의 함수. 첫 인자는 self
        ...
```
용어를 풀면:

- **생성자(constructor)**: 인스턴스를 처음 만들 때 자동 실행되는 준비 함수. Python 에선 `__init__`.
- **속성(attribute)**: 인스턴스가 가진 **데이터**. `self._rng` 처럼 `self.` 을 붙여 저장·접근한다.
- **메서드(method)**: 클래스 **안에 든 함수**. `play` 처럼.
- **`self`**: **인스턴스 자기 자신**을 가리키는 이름. 메서드의 첫 매개변수로 항상 받는다
  (C++ 의 숨은 `this` 를 Python 은 **드러내 놓고** 씁니다).
- **던더(dunder) 메서드**: `__init__`, `__eq__` 처럼 앞뒤에 밑줄 두 개(`__`)가 붙은 **특수 메서드**.
  파이썬이 특정 상황(생성 시, `==` 비교 시 등)에 **자동으로** 불러 줍니다. ("double underscore" → 던더)

### `__init__` 이 왜 필요한가 — Java/C++ 의 "멤버 변수"와 비교

C/C++/Java 를 모르면 "왜 `__init__` 안에서 `self._rng = rng` 를 해야 하나"가 와닿지 않습니다.
이 지점은 **C++ 가 가장 명확하게** 보여 줍니다 — 멤버 변수를 클래스 본문에 먼저 **"선언"** 하면
그것이 곧 **객체의 메모리 배치도**가 되고, **생성자가 그 칸을 채우는** 2단계 구조입니다:

```cpp
class Student {
    int    age;     // ① 멤버 "선언" — 이 클래스로 찍는 객체마다 이 칸들이 실제 메모리에 잡힌다
    double gpa;
public:
    Student(int a, double g)
        : age(a), gpa(g) {}   // ② 생성자 — 선언된 칸을 채운다 (초기화 리스트)
};

Student s1(20, 3.8);   // s1 의 메모리: [age=20][gpa=3.8]
Student s2(24, 4.1);   // s2 는 별도 메모리 — 서로 독립
// sizeof(Student) == 멤버 칸들의 합(+정렬) — "배치도"라는 말이 문자 그대로다
```

Java 도 같은 구조입니다(`private SecureRandom random;` 선언 + 생성자에서 `this.random = ...`).

Python 에는 이 **선언부가 아예 없습니다**. `__init__` 안에서 `self.x = 값` 이라고 **대입하는
순간이 곧 멤버 변수를 만드는 순간**입니다 — ①선언과 ②초기화가 동시에 일어납니다:

```python
class RockPaperScissors:
    def __init__(self, rng=secrets.randbelow):
        self._rng = rng      # "_rng 라는 멤버 변수를 만들고 채운다" — 선언+초기화 동시
```

그래서 Python 에서 `__init__` 은 생성자이자 사실상 **"이 클래스의 멤버 변수 목록"** 역할을
합니다. 인스턴스를 만들 때마다 `__init__` 이 한 번씩 실행되어 **각자의** 멤버를 갖습니다:

```python
g1 = RockPaperScissors()                  # g1 의 _rng = 보안 난수
g2 = RockPaperScissors(rng=lambda _: 2)   # g2 의 _rng = 항상 2 — 서로 독립
```

`self` 가 바로 "지금 만들어지고 있는 **그 인스턴스**"이고, `self._rng` 는 그 인스턴스에 붙는
데이터입니다 — Java 의 `this.random` 과 정확히 같은 자리입니다.

### 던더란 무엇인가 — 문법을 메서드로 "번역"하는 규약

**용어부터** — "던더(dunder)"는 **D**ouble **UNDER**score(밑줄 두 개)의 준말입니다.
`__init__` 처럼 이름 앞뒤에 밑줄 두 개를 두른 데서 온 별명이고, "매직 메서드"라고도 부릅니다.
밑줄을 두 개나 두르는 이유는 **일반 메서드와 격리**하기 위해서입니다 — "이 이름은 내가 부르는 게
아니라 **파이썬 문법이 부르는 자리**"라는 시각적 표시죠.

**역할** — 파이썬의 문법 요소들은 사실 **객체의 던더 메서드 호출로 번역**됩니다:

| 이렇게 쓰면 | 파이썬이 실제로 부르는 것 |
|---|---|
| `a == b` | `a.__eq__(b)` |
| `a - b` | `a.__sub__(b)` — `Hand.ROCK - Hand.PAPER` 가 되는 이유 |
| `len(x)` | `x.__len__()` |
| `x[i]` | `x.__getitem__(i)` |
| `for v in x` | `x.__iter__()` |
| `print(x)` | `x.__str__()` |
| `with x:` | `x.__enter__()` / `x.__exit__(...)` |

즉 던더를 정의하면 **내가 만든 타입을 언어의 문법에 끼워 넣을** 수 있습니다. dataclass 가
`__eq__` 를 자동 생성해 주면 `==` 가 그냥 동작하는 것도, 튜플 인덱싱 `(DRAW, WIN, LOSE)[diff]`
가 되는 것도 전부 이 번역 덕입니다.

**다른 언어는 같은 문제("내 타입을 문법에 끼워 넣기")를 어떻게 푸나** —

| | Python | C++ | Java |
|---|---|---|---|
| 방식 | **이름 규약**(던더)만 지키면 문법이 자동 호출 | `operator` **키워드**로 연산자 오버로딩 | 오버로딩 **없음** — 정해진 이름을 **직접 호출** |
| `==` 재정의 | `__eq__` | `bool operator==(...)` | 불가 — `a.equals(b)` 를 손수 부른다 |
| 출력용 문자열 | `__str__` | `operator<<` 오버로딩 | `toString()` (println 이 불러 줌) |
| 인덱싱 `x[i]` | `__getitem__` | `operator[]` | 불가 — `get(i)` 메서드로 |
| 정리 보장 | `__exit__` (`with`) | **소멸자** `~T()` — RAII | `close()` (try-with-resources 의 `AutoCloseable`) |

- **Java**: `==` 는 참조 비교로 **고정**되어 있어, 값 비교는 늘 `equals()` 를 직접 불러야 합니다 —
  특별한 이름들이 문법과 연결되지 않습니다(예외: 문자열 `+` 정도).
- **C++**: 문법과 연결되지만 `operator` 라는 **별도의 선언 문법**을 배워야 하고, 정리 보장은
  소멸자+RAII 라는 다른 축으로 풉니다.
- **Python**: 선언도 호출도 특별할 게 없습니다 — **이름만 규약대로** 지으면 문법이 알아서 부릅니다.
  세 언어 중 "끼워 넣기"의 비용이 가장 낮은 방식입니다.

### 자주 쓰는 던더 — 파이썬이 "약속한 이름"들

클래스를 만들 때 자주 만나는 던더 메서드들입니다. 공통 원리는 위에서 봤듯 — **내가 직접 부르는
게 아니라, 정해진 상황에서 파이썬이 대신 불러 준다**:

| 던더 | 언제 불리나 | 이 repo 에서 |
|---|---|---|
| `__init__` | 인스턴스 생성 시 | `RockPaperScissors.__init__` (위) |
| `__repr__` | 디버깅 출력·REPL 표시 | `@dataclass` 가 자동 생성 |
| `__eq__` | `a == b` 비교 시 | `@dataclass` 가 자동 생성 (테스트에서 사용) |
| `__str__` | `print(obj)`·`str(obj)` | (없으면 `__repr__` 로 대체) |
| `__len__` | `len(obj)` | — |
| `__iter__` | `for x in obj` | — |
| `__getitem__` | `obj[key]` | 튜플 인덱싱 `(DRAW, WIN, LOSE)[diff]` 가 이것 |
| `__call__` | `obj()` 처럼 인스턴스를 함수처럼 부를 때 | — |
| `__enter__` / `__exit__` | `with` 블록 **진입/퇴장** 시 | 아래 설명 |

`__enter__`/`__exit__` 는 **컨텍스트 매니저** — `with` 문이 쓰는 짝입니다:

```python
with open("scores.txt") as f:   # 진입: __enter__ 가 파일을 돌려줌
    data = f.read()
# 퇴장: __exit__ 가 호출되어 파일을 닫는다 — 블록 안에서 예외가 터져도!
```

`__exit__` 의 존재 이유가 곧 [§4 예외 처리](#4-예외-처리--우리도-라벨을-붙이는-계층이다)와
이어집니다 — **"무슨 일이 있어도 정리는 보장한다"** 를 언어 차원에서 제공하는 장치입니다.

한 가지 중요한 구분 — **`__main__` 은 메서드가 아니라 "예약된 모듈 이름"** 입니다. 파이썬은
직접 실행된 모듈의 이름(`__name__`)을 `"__main__"` 으로 정해 줍니다:

- `python -m rps` 로 실행하면 → 패키지의 **`__main__.py`** 파일이 진입점으로 실행됩니다.
  이 repo 의 `src/rps/__main__.py` 가 바로 그것.
- 흔히 보는 `if __name__ == "__main__":` 은 "이 파일이 **직접 실행**됐을 때만(임포트 말고)
  아래를 돌려라"라는 관용구입니다.
- 이처럼 던더 이름 규약은 메서드만이 아니라 **모듈·변수에도** 쓰입니다 — `__name__`, `__file__`,
  그리고 위에서 본 인스턴스의 `__dict__`.

### 상속 — 사실 우리는 이미 쓰고 있었다

**상속(inheritance)** 은 "부모 클래스의 것을 물려받아, 필요한 것만 더하거나 바꾸는" 문법입니다.
`class 자식(부모)` 형태로 씁니다. 슬라이드 2 의 대학원생으로 예를 들면:

```python
class Student:
    def __init__(self, name):
        self.name = name
    def daily(self):
        eat(); sleep()

class GradStudent(Student):          # Student 의 모든 것을 물려받는다
    def __init__(self, name, lab):
        super().__init__(name)       # ① 부모의 __init__ 을 먼저 (super() = 부모)
        self.lab = lab               # ② 내 멤버를 추가
    def daily(self):                 # ③ 오버라이드(재정의) — 같은 이름을 내 방식으로
        super().daily()              #    부모 것도 부르고
        research(); repeat()         #    대학원생의 하루를 덧붙인다
```

- `super()` = 부모 클래스. 부모의 `__init__`/메서드를 이어서 부를 때 씁니다.
- **오버라이드** = 부모의 메서드를 같은 이름으로 다시 정의해 동작을 바꾸는 것.

그리고 돌아보면 — **이 문서에서 이미 상속을 계속 쓰고 있었습니다**:

| 코드 | 정체 |
|---|---|
| `class Hand(IntEnum)` | `IntEnum` 을 **상속** — 그래서 산술·역조회가 공짜 |
| `class Outcome(Enum)` | `Enum` 을 상속 |
| `class PlayResponse(BaseModel)` | Pydantic `BaseModel` 을 상속 — 그래서 런타임 검증이 공짜 |

즉 파이썬에서 상속의 주된 쓰임은 "부모가 만들어 둔 **능력을 물려받는 것**"입니다. 반면
C++/Java 에서 흔한 "**교체 지점을 만들기 위한 상속**"(인터페이스·추상 클래스 — 04장의
`RandomSource` 가 그 예)은, 파이썬에서는 덕 타이핑과 일급 함수 덕분에 **훨씬 덜 필요**합니다 —
같은 문제를 `Callable` 인자 하나로 풀었던 것을 떠올려 보세요.

### `Enum` / `IntEnum` — 정해진 값들의 목록(열거형)
**열거형(enum)** 은 "미리 정해진 몇 가지 값" 중 하나만 갖게 하는 타입입니다(요일, 색, 손 …).

```python
class Hand(IntEnum):        # 멤버가 곧 정수(int)라서 산술 연산이 됨
    ROCK = 0
    PAPER = 1
    SCISSORS = 2

class Outcome(Enum):
    WIN = "WIN"
    LOSE = "LOSE"
    DRAW = "DRAW"
```
`Hand.ROCK`(멤버 접근), `Hand(2)`(숫자로 되찾기 = 역조회), `Hand.ROCK.name`(→ `"ROCK"`),
`Hand.ROCK - Hand.PAPER`(IntEnum 이라 뺄셈 가능) 이 **모두 표준 기능**입니다. Java 는 enum 에
`code` 필드와 접근자를 따로 만들어야 하던 것을 **IntEnum 이 통째로 흡수**합니다.

### `@dataclass` — 데이터 담는 클래스를 한 줄로
값 몇 개를 묶어 두는 "데이터 그릇" 클래스는, 보통 생성자·비교·출력 코드를 손으로 써야 합니다.
Python 은 `@dataclass` 한 줄로 그걸 **자동 생성**합니다.

```python
@dataclass(frozen=True)
class GameResult:
    player: Hand
    computer: Hand
    outcome: Outcome
```
데코레이터 `@dataclass(frozen=True)` 하나가 아래를 만들어 줍니다.

- `__init__` — `GameResult(Hand.ROCK, Hand.SCISSORS, Outcome.WIN)` 처럼 생성
- `__eq__` — 값이 같으면 `==` 가 참 (테스트에서 결과 비교에 사용)
- `__repr__` — 화면 출력이 `GameResult(player=<Hand.ROCK: 0>, ...)` 로 읽기 좋게
- `frozen=True` — **불변**(만든 뒤 필드를 못 바꿈. 바꾸려 하면 오류). Java 의 `record` 에 대응.

> `@데코레이터`는 "함수/클래스를 감싸 기능을 덧입히는" 문법입니다(아래에서 Java 어노테이션과의
> 차이를 따로 설명합니다). 이 repo 에는 `@dataclass`(클래스 변형)와 `@app.get("/api/play")`
> (FastAPI 라우팅 등록)로 등장합니다.

### 정적 타입의 대안 — Pydantic (dataclass 를 대체하기도)

타입 힌트(`player: Hand`)는 **런타임에는 무시**된다(위 "타입 힌트" 절). 그런데 외부에서 들어오는
데이터(웹 요청, 설정 파일, JSON)는 "정말 그 타입이 맞는지"를 실행 중에 **검증**해야 안전하다.
그 역할을 하는 대표 라이브러리가 **Pydantic** 이다.

```python
from pydantic import BaseModel

class PlayResponse(BaseModel):
    player: str
    computer: str
    outcome: str

PlayResponse(player="ROCK", computer="SCISSORS", outcome="WIN")   # OK
PlayResponse(player=123, computer="X", outcome="Y")               # ← 타입 안 맞으면 ValidationError
```

`BaseModel` 을 상속하면 타입 힌트를 **런타임에 강제**하고, 가능한 값은 자동 변환하며(`"3"` → `3`),
JSON 직렬화(`model_dump()` / `model_dump_json()`)를 공짜로 준다.

**dataclass vs Pydantic — 언제 무엇을?**

| | `@dataclass` | `pydantic.BaseModel` |
|---|---|---|
| 출처 | 표준 라이브러리 (의존성 0) | 서드파티 (`pip install pydantic`) |
| 런타임 타입 검증 | 없음 | **있음** (안 맞으면 `ValidationError`) |
| 값 자동 변환 | 없음 | 있음 (`"3"` → `3` 등) |
| JSON 직렬화 | 수동 | 내장 |
| 속도 | 매우 가벼움 | 검증 비용 (Pydantic v2 는 Rust 로 빠름) |
| 적합한 곳 | **내부** 순수 데이터 묶음 | **외부 경계** (API 입출력·설정·외부 데이터) |

이 저장소는 이 분담을 그대로 따른다 — **순수 도메인(`GameResult`)은 `@dataclass` 로 의존성 없이**,
**웹 응답(`rps/web.py` 의 `PlayResponse`)은 Pydantic 으로** 표현한다. FastAPI 자체가 Pydantic
기반이라, 웹 경계에서는 Pydantic 이 dataclass 를 자연스럽게 대체한다.

> 한 줄 정리: dataclass 는 "믿을 수 있는 **내부** 데이터", Pydantic 은 "믿을 수 없는 **외부** 입력을
> 검증하는 문지기". 정적 타입이 약한 Python 에서 Pydantic 은 **런타임 타입 안전**을 보태 주는
> 사실상의 표준이다.

### 데코레이터로 웹 엔드포인트도 함수 하나
```python
@app.get("/api/play")
def play(h: str) -> dict[str, str]:
    result = _game.play(h)
    return {"player": result.player.name, ...}
```
Spring 이 컨트롤러 **클래스** + 어노테이션 여러 개로 하던 일을, FastAPI 는 **함수 + 데코레이터 한 줄**로 합니다.

### 잠깐 — 파이썬 데코레이터 `@` vs Java 어노테이션 `@`

생김새(`@`)가 같아서 헷갈리지만, **동작 방식이 근본적으로 다르다.** 먼저 파이썬에서 "어노테이션
(annotation)"이라 부르는 건 사실 **타입 힌트**(`player: Hand`)다 — `__annotations__` 에 저장되는
**수동적 메타데이터**로, 기본적으로 실행에 영향이 없다(mypy·Pydantic·FastAPI 가 읽어서 쓴다).
`@dataclass`·`@app.get(...)` 처럼 `@` 가 붙은 것은 파이썬에선 **데코레이터(decorator)** 라 부른다.

- **파이썬 데코레이터** `@foo` 는 **실제 실행되는 함수**다. `@foo` 를 붙인 `def bar` 는 곧
  `bar = foo(bar)` 와 같다 — **정의(import) 시점에 즉시 실행**되어 대상을 감싸거나 등록한다.
  `@app.get("/api/play")` 는 그 자리에서 라우트를 **등록**하는 함수 호출이다.
- **Java/Spring 어노테이션** `@RestController`·`@Autowired` 는 **수동적 라벨(메타데이터)** 이다.
  그 자체론 아무 일도 안 하고, 프레임워크가 시작할 때 **리플렉션으로 스캔·해석**해서 연결한다.

| | Python 데코레이터 `@foo` | Java 어노테이션 `@Foo` |
|---|---|---|
| 정체 | 실행되는 **함수** (`bar = foo(bar)`) | 수동적 **메타데이터**(라벨) |
| 작동 시점 | import(정의) 시 **즉시 실행** | 런타임 리플렉션 / 컴파일러가 **스캔**해야 |
| 처리 주체 | 데코레이터 함수가 그 자리에서 | 별도 프레임워크(스프링)가 발견·해석 |
| 예 | `@app.get(...)` → 그 자리서 라우트 등록 | `@GetMapping` → 스프링이 스캔해 매핑 |

> 즉 파이썬의 `@`(데코레이터)는 **능동적 코드 실행**, Java 의 `@`(어노테이션)는 **선언적 메타데이터**다.
> 파이썬에서 Java 어노테이션에 가장 가까운 것은 `@` 데코레이터가 아니라 **타입 힌트**(`x: int`)다
> — 도구가 읽는 수동 메타데이터라는 점에서. 단 파이썬 타입 힌트는 타입 정보에 한정된다.

## 4. 예외 처리 — 우리도 "라벨을 붙이는 계층"이다

[01장](01-cs-기초.md)에서 봤듯, 에러 라벨('oom' 같은)은 **마지막으로 잡은 계층**이 붙입니다.
그런데 `try/except` 를 쓰는 순간 — **우리가 바로 그 계층이 됩니다.** 우리가 붙인(또는 삼킨)
라벨이, 다음에 디버깅하는 사람(대개 미래의 나)이 보게 될 전부입니다.

그래서 예외 처리의 출발은 문법이 아니라 **명확한 자기 분석**입니다:

1. **나는 지금 뭘 하고 있는가** — 이 블록이 시도하는 일은 무엇인가.
2. **어떤 상황이 발생할 수 있는가** — 여기서 "예상 가능한" 실패는 무엇인가
   (잘못된 입력? 파일 없음? 연결 끊김?).
3. **각각에 대해 나는 뭘 할 수 있는가** — 복구? 기본값? 재시도? **할 수 있는 게 없으면
   잡지 말고 흘려보낸다**(전파 — 올라간 traceback 이 가장 정확한 라벨이다).
4. **조용히 삼키지 않는다** — 맨몸 `except:` 로 덮으면, 내가 다음 사람에게 'oom' 같은
   오리무중 라벨을 남기는 셈이다.

이 저장소의 코드가 그 원칙대로 쓰여 있습니다:

```python
# cli.py — "내가 예상했고, 처리법을 아는 상황"만 좁게 잡는다
try:
    result = game.play(user_input)
except ValueError as exc:          # 잘못된 손 입력 — 예상한 상황
    print(f"오류: {exc}", file=sys.stderr)
    return 1                       # 사람에게는 메시지, 기계에게는 종료 코드

# _read_input — 예상한 실패(표준 입력 닫힘)만 기본값으로 복구
try:
    entered = input("손을 입력하세요 ...: ").strip()
except EOFError:                   # 파이프 등으로 입력이 없는 상황
    entered = ""
```

```python
# web.py — 라벨을 "변환"하되 인과 사슬은 보존한다
except ValueError as exc:
    raise HTTPException(status_code=400, detail=str(exc)) from exc
    # ^^^^ from exc: "이 400 의 원인은 저 ValueError"
    #      — 라벨을 바꿔도 원인 사슬을 지우지 않는 문법
```

- `except ValueError` 처럼 **구체적으로** 잡는다 — 맨몸 `except:` 는 Ctrl+C(KeyboardInterrupt)와
  내 버그까지 전부 삼킨다.
- 잡을 이유가 없으면 **안 잡는 것이 처리다** — 전파가 기본값.
- 라벨을 바꿀 때는 `raise ... from exc` — 01장에서 본 "사인만 남고 범인이 지워지는" 문제를
  **우리 코드에서 만들지 않는** 방법이다.

> 한 줄 정리: **좋은 예외 처리 = 좋은 라벨 달기.** "내가 뭘 하는지, 무엇이 일어날 수 있는지"를
> 분석한 만큼만 잡고, 나머지는 정직하게 흘려보내라.

## 5. 한 장 요약 — Python 이 "덜 쓰게" 해 주는 것들

| 하고 싶은 일 | Java/C++ 에서 | Python 에서 |
|---|---|---|
| 변수 만들기 | 타입 선언 필수 | 대입만 (`x = ...`), 힌트는 선택 |
| enum 에 정수 코드 | 필드 + 접근자 추가 | `IntEnum` 이 곧 int |
| 불변 데이터 묶음 | record / struct + 보일러플레이트 | `@dataclass(frozen=True)` 한 줄 |
| 값 비교(`==`)·출력 | equals/hashCode/toString 구현 | dataclass 가 자동 생성 |
| 의존성 주입 | 인터페이스 + 구현 클래스 | `Callable` 인자 하나 |
| 자유 함수 | 클래스에 static 으로 감싸야 | 모듈에 그냥 `def` |
| 한 줄 입력 | Scanner / getline | `input()` |

## 6. 쏟아지는 질문들 (Q&A)

수업에서 실제로 연쇄로 터져 나오는 질문들입니다.

**Q. 변수(變數)는 "변하는 수"라는 뜻인가?**
맞습니다 — 한자 그대로 變(변할 변)·數(셈 수). 담긴 값을 **다시 대입해 바꿀 수 있어서** 변수입니다.
`player = Hand.ROCK` 했다가 `player = Hand.PAPER` 로 바꿔 넣을 수 있죠.

**Q. 그럼 "안 변하는 것"은?**
**상수(常數)** — 常(항상 상). 한번 정하면 바뀌지 않는 값입니다. C++ 의 `const`, Java 의 `final` 이
"이 이름에는 재대입 금지"를 **컴파일러가 강제**하는 장치입니다.

**Q. 파이썬에는 왜 상수(const)가 없나?**
세 겹의 답이 있습니다.

1. **철학** — 파이썬 커뮤니티의 오랜 표어: *"우리는 모두 책임질 줄 아는 어른이다(consenting
   adults)."* 금지를 문법으로 강제하기보다 **대문자 이름(`_ALIASES`)이라는 관례**로 신호하고,
   책임은 프로그래머에게 맡깁니다.
2. **구조** — 파이썬 변수는 상자보다 **값에 붙이는 이름표**에 가깝습니다. "이름표를 다른 값으로
   못 옮기게 막는" 장치가 언어 코어에 없습니다. 대신 타입 힌트 **`Final`** 로 적으면
   (`PI: Final = 3.14159`) — 런타임 강제는 아니지만 — `mypy`/`pyright` 가 재대입을 잡아 줍니다
   (§1 의 "힌트는 도구가 검사한다" 원리 그대로).
3. **값 쪽의 불변** — "이름 고정" 대신 "**값 자체가 안 바뀌는 타입**"을 골라 쓰는 게 파이썬식
   입니다: tuple(불변 리스트), `frozen=True` dataclass(우리의 `GameResult`), frozenset.
   Enum 멤버(`Hand.ROCK`)도 재할당이 막혀 있어 **사실상 상수**입니다.

**Q. 그래서 "일급 함수"가 뭔가?**
"일급(first-class)"은 **시민권 등급** 비유입니다 — 일급 시민 = 차별 없이 모든 권리를 가진 시민.
값의 4대 권리(①변수에 담기 ②인자로 넘기기 ③반환하기 ④자료구조에 넣기)를 **함수도 전부 누리는
언어**에서 그 함수를 "일급 함수"라 부릅니다. 함수의 종류가 아니라 **언어가 함수를 어떻게
대우하는가**에 대한 말이고 — 파이썬 함수는 전부 일급입니다(§2).

**Q. 일급이 있으면 이급도 있나?**
실제로 쓰이는 용어입니다 — 권리가 제한된 것을 **second-class** 라 부릅니다. C 의 함수가 그 예
(변수에 직접 담기지 않고 함수 포인터라는 우회로만 존재). 파이썬 안에도 있습니다 — `if` 문이나
`=` 대입문 같은 **문(statement)** 은 값이 아니라서 변수에 담을 수 없죠. "모든 것이 일급"인
언어는 생각보다 드뭅니다.

다음: [04-언어-비교](04-언어-비교.md) — 같은 기능의 "전체 구현"을 세 언어로 통째로 비교합니다.
