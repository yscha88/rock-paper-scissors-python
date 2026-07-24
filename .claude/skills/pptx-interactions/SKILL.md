---
name: pptx-interactions
description: pptx에 인터랙션(클릭 트리거 애니메이션·모프 전환·구역/슬라이드/요약 줌·액션 하이퍼링크)을 프로그래매틱으로 저작·검증할 때 사용. "pptx 트리거", "모프", "줌 내비게이션", "pptx 애니메이션 코드로", "PowerPoint 자동화" 요청 시 트리거. python-pptx로는 불가한 영역을 COM/raw OOXML로 해결한다.
---

# pptx 인터랙션 저작 스킬

pptx의 인터랙션은 **전부 파일 포맷(OOXML)에 존재**한다 — "포맷이 못 한다"는 진단은 금지.
비용이 다른 세 경로 중에서 고른다. (근거: 이 저장소에서 실측·리서치 완료, 2026-07)

## 경로 결정 트리

```
인터랙션 필요
├─ Windows + PowerPoint 설치 환경인가?
│   ├─ 예 → 경로 A: COM 오토메이션 (기본값 — 아래 표의 O 항목 전부 가능)
│   └─ 아니오 → 경로 B: raw OOXML 주입 (zip 수술)
└─ 줌(구역/슬라이드/요약)인가? → COM 생성 API가 없음 → 항상 경로 B
```

| 인터랙션 | 경로 A (COM) | 경로 B (raw XML) |
|---|---|---|
| 도형 클릭 트리거 애니메이션 | **O** `InteractiveSequences.Add() → AddTriggerEffect(...)` | O — 골든 템플릿 있음 |
| 모프 전환 | **O** 숨은 상수 `ppEffectMorphByObject=3954` + `Duration` | O — `p159:morph` + AlternateContent |
| 클릭/호버 액션(슬라이드 점프·URL·매크로) | **O** `ActionSettings(ppMouseClick).Action=...` | O — `a:hlinkClick` |
| 미디어 북마크 트리거 | O `msoAnimTriggerOnMediaBookmark=5` (실기 미검증) | O |
| 줌(구역/슬라이드/요약) | **X — 생성 API 없음** | O — `2016/*zoom` ns (실기 미검증) |
| python-pptx | 전부 불가 (이슈 #1106 등) — lxml로 경로 B 수행만 가능 | — |

상세 문법·레시피: [references/com-recipes.md](references/com-recipes.md) ·
[references/ooxml-syntax.md](references/ooxml-syntax.md)

## 필수 규칙

1. **자동 DOM/HTML 변환으로 pptx를 만들지 말 것** — 이 저장소에서 실패·폐기된 경로.
   콘텐츠는 pptx 모델(도형·텍스트런·타이밍)로 네이티브 저작한다.
2. **트리거는 MainSequence가 아니라 InteractiveSequences** — MainSequence 효과에
   `Timing.TriggerType`을 직접 세팅하면 `Invalid request` (실측).
3. **raw XML 주입 후에는 반드시 PowerPoint로 열어 검증** — 틀린 XML은 열리되 PowerPoint가
   조용히 '복구'하며 제거한다. 검증 = COM으로 열어 개수/속성 확인 + 저장 후 재확인
   (레시피의 verify 절).
4. **확장 전환·줌은 mc:AlternateContent 래핑 필수** — naked 확장 요소 금지. Choice(신규 ns
   Requires) + Fallback(ISO 표준 대체물: 전환은 `p:fade`, 줌은 `p:pic`/`p:grpSp`).
5. **id 정합**: 트리거 `spid` = 같은 slideN.xml의 `p:cNvPr@id` / 모프 매칭 = 두 슬라이드에서
   같은 `p:cNvPr@name`(강제 매칭은 `!!` 접두, 같은 타입끼리만) / 줌 `sectionId` GUID =
   presentation.xml의 `p14:sectionLst` GUID.
6. **전환은 도착 슬라이드에 저장** — N→N+1 모프는 slideN+1.xml에 쓴다.
7. COM 사용 후 반드시 `Presentation.Close()` + `Application.Quit()` (finally 블록) — 좀비
   POWERPNT 프로세스가 프로필/파일 잠금을 유발한다.

## 검증 규약 (모든 산출물에 적용)

1. **구조 검증**: COM으로 열어 `TimeLine.InteractiveSequences.Count`,
   `SlideShowTransition.EntryEffect` 등 기대값 확인 → `SaveAs` → 다시 열어 재확인
   (PowerPoint의 silent repair 탐지).
2. **동작 검증**: `SlideShowSettings.Run()` + `View.GotoSlide/Next` + 트리거 도형의
   `ActionSettings.Hyperlink.Follow()` 패턴으로 슬라이드쇼 자동화 (com-recipes.md §검증).
3. 실패 시: 원본과 산출물의 slideN.xml을 unzip diff — PowerPoint가 무엇을 제거/수정했는지가
   곧 오류 지점이다.
