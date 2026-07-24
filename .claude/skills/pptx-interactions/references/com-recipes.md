# 경로 A — PowerPoint COM 오토메이션 레시피

실측 검증 환경: Windows 11 + PowerShell 7 + PowerPoint(M365). 모든 상수는 공식 VBA 레퍼런스
원문 확인(출처는 SKILL.md 리서치 기록). **finally에서 Quit 필수.**

## 1. 클릭 트리거 리빌 (실측 검증됨 — 13줄)

"버튼 클릭 → 답 상자 나타남". 핵심: `InteractiveSequences`에 저작한다.

```powershell
$app = New-Object -ComObject PowerPoint.Application
try {
  $pres  = $app.Presentations.Add(0)              # 0 = 창 없이
  $slide = $pres.Slides.Add(1, 12)                # 12 = ppLayoutBlank
  $btn = $slide.Shapes.AddShape(5, 80, 400, 280, 60)   # 5 = msoShapeRoundedRectangle
  $btn.Name = "revealBtn"; $btn.TextFrame.TextRange.Text = "버그를 찾아보세요"
  $ans = $slide.Shapes.AddTextbox(1, 420, 390, 520, 120)
  $ans.Name = "answerBox"; $ans.TextFrame.TextRange.Text = "정답 텍스트"
  $seq = $slide.TimeLine.InteractiveSequences.Add(1)
  $eff = $seq.AddTriggerEffect($ans, 1, 4, $btn)  # Appear=1, OnShapeClick=4, 트리거=버튼
  $pres.SaveAs("C:\경로\out.pptx", 24)            # 24 = ppSaveAsOpenXMLPresentation
  $pres.Close()
} finally { $app.Quit() | Out-Null }
```

`AddTriggerEffect(pShape, effectId, trigger, pTriggerShape, [bookmark], [Level])` → `Effect` 반환.

**함정(실측)**: `MainSequence.AddEffect(...)` 후 `Timing.TriggerType = 4` 직접 세팅은
`Invalid request` — 트리거는 반드시 InteractiveSequences 경유.

### 자주 쓰는 열거값

| 열거 | 값 |
|---|---|
| `MsoAnimEffect` | Appear=1, Fly=2, Dissolve=9, Fade=10, Split=16, Wipe=22, Zoom=23, GrowShrink=59, Spin=61, MediaPlay=83/Pause=84/Stop=85 |
| `MsoAnimTriggerType` | None=0, OnPageClick=1, WithPrevious=2, AfterPrevious=3, **OnShapeClick=4**, OnMediaBookmark=5 |
| `PpActionType` | None=0, NextSlide=1, PrevSlide=2, FirstSlide=3, LastSlide=4, EndShow=6, **Hyperlink=7**, RunMacro=8, RunProgram=9, Play=12 |

## 2. 모프 전환 (숨은 상수 — 공식 열거 문서에 누락)

`PpEntryEffect` 웹 문서에는 없지만 타입 라이브러리에 존재(MVP 확인):
`ppEffectMorphByObject=3954, ByWord=3955, ByChar=3956`.

```powershell
# 전환은 "도착" 슬라이드에 건다 (N→N+1 모프면 슬라이드 N+1에)
$sl2 = $pres.Slides.Item(2)
$sl2.SlideShowTransition.EntryEffect = 3954   # ppEffectMorphByObject
$sl2.SlideShowTransition.Duration   = 1.5     # 주의: Speed가 아니라 Duration
```

매칭 규칙: 두 슬라이드에서 **같은 타입 + 같은 `Shape.Name`**. 강제 매칭은 이름을 `!!`로
시작(`!!diag` ↔ `!!diag`). `!!` 개체는 비-`!!` 개체와 절대 매칭되지 않고, 한 슬라이드 안에서
`!!이름`은 유일해야 한다. 차트는 모프 대상이 아니라 cross-fade.

## 3. 클릭 액션 — 슬라이드 점프/URL

```powershell
$as = $shape.ActionSettings.Item(1)       # 1 = ppMouseClick (2 = ppMouseOver)
$as.Action = 7                            # ppActionHyperlink
$as.Hyperlink.SubAddress = "$($target.SlideID),$($target.SlideIndex),$($target.Name)"  # 같은 파일 내 점프
# 외부 URL이면: $as.Hyperlink.Address = "https://..."
```

문서 주의 원문: Action을 올바른 값으로 먼저 설정하지 않으면 다른 속성이 적용되지 않는다.

**함정(실측)**: SubAddress 형식은 **`SlideID,슬라이드인덱스,제목` 순서**다. 인덱스-먼저
(`"4,259,..."`)나 제목 생략(`"4,259,"`) 등 틀린 형식은 **대입 직후 읽으면 그대로 보이지만
저장 시점에 조용히 제거**된다(action=0으로 소실). 링크 검증은 반드시 저장 왕복 후에 할 것.

## 4. 검증 — 슬라이드쇼 자동화

```powershell
$app = New-Object -ComObject PowerPoint.Application
try {
  $app.Visible = -1
  $pres = $app.Presentations.Open($path, 0, 0, -1)
  # (1) 구조: 기대 개수/속성
  $n = $pres.Slides.Item(1).TimeLine.InteractiveSequences.Count   # 기대: 1
  $fx = $pres.Slides.Item(2).SlideShowTransition.EntryEffect      # 기대: 3954
  # (2) silent-repair 탐지: 저장 → 닫기 → 재열기 → 재확인
  # (3) 동작: 쇼 실행 후 트리거 도형 강제 클릭
  $pres.SlideShowSettings.ShowType = 2
  $pres.SlideShowSettings.Run() | Out-Null
  $show = $app.SlideShowWindows.Item(1)
  $show.View.GotoSlide(1)
  $pres.Slides.Item(1).Shapes.Item("revealBtn").ActionSettings.Item(1).Hyperlink.Follow()
  # 이후 View.State/GetClickIndex 로 진행 상태 assert
  $show.View.Exit()
  $pres.Close()
} finally { $app.Quit() | Out-Null }
```

COM 호출은 일시적 실패가 잦다 — 재시도 래퍼(250ms × 20회) 권장.

## 한계 (경로 B로 넘어갈 것)

- **줌(구역/슬라이드/요약)**: Shapes.Add* 계열에 줌 생성 메서드가 없다 → raw XML만.
- 헤드리스 CI: COM은 데스크톱 세션 필요. CI 검증이 필요하면 산출 pptx의 XML 정적 검사
  (ooxml-syntax.md의 구조 대조)로 대체.
