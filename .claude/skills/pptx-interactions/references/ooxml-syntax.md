# 경로 B — raw OOXML 문법 (zip 수술)

pptx = ZIP. `ppt/slides/slideN.xml` 을 직접 수정한다. 수정 후 **반드시 PowerPoint로 열어
silent-repair 여부 검증**(SKILL.md 검증 규약).

## 0. slideN.xml 구조와 삽입 위치 (순서 고정 — 스키마 규범)

```
p:sld
 ├─ p:cSld (도형 트리 p:spTree — 줌 개체는 여기)
 ├─ p:clrMapOvr [0..1]
 ├─ p:transition [0..1]   ← 모프 등 전환 (mc:AlternateContent 래핑째 이 자리)
 ├─ p:timing [0..1]       ← 트리거 애니메이션
 └─ p:extLst [0..1]
```

## 1. 클릭 트리거 — 골든 템플릿 (PowerPoint 실산출물, 유효성 보증)

시나리오: `spid=2`(버튼) 클릭 → `spid=3`(답 상자) Appear. `spid` 는 같은 파일의
`p:spTree/p:sp/p:nvSpPr/p:cNvPr@id` 값이다. 재사용 시 spid 두 곳과 cTn id 들(문서 내 유일)만
바꾼다.

```xml
  <p:timing>
    <p:tnLst>
      <p:par>
        <p:cTn id="1" dur="indefinite" restart="never" nodeType="tmRoot">
          <p:childTnLst>
            <p:seq concurrent="1" nextAc="seek">
              <p:cTn id="2" restart="whenNotActive" fill="hold" evtFilter="cancelBubble" nodeType="interactiveSeq">
                <p:stCondLst>
                  <p:cond evt="onClick" delay="0">
                    <p:tgtEl>
                      <p:spTgt spid="2"/>
                    </p:tgtEl>
                  </p:cond>
                </p:stCondLst>
                <p:endSync evt="end" delay="0">
                  <p:rtn val="all"/>
                </p:endSync>
                <p:childTnLst>
                  <p:par>
                    <p:cTn id="3" fill="hold">
                      <p:stCondLst>
                        <p:cond delay="0"/>
                      </p:stCondLst>
                      <p:childTnLst>
                        <p:par>
                          <p:cTn id="4" fill="hold">
                            <p:stCondLst>
                              <p:cond delay="0"/>
                            </p:stCondLst>
                            <p:childTnLst>
                              <p:par>
                                <p:cTn id="5" presetID="1" presetClass="entr" presetSubtype="0" fill="hold" grpId="0" nodeType="clickEffect">
                                  <p:stCondLst>
                                    <p:cond delay="0"/>
                                  </p:stCondLst>
                                  <p:childTnLst>
                                    <p:set>
                                      <p:cBhvr>
                                        <p:cTn id="6" dur="1" fill="hold">
                                          <p:stCondLst>
                                            <p:cond delay="0"/>
                                          </p:stCondLst>
                                        </p:cTn>
                                        <p:tgtEl>
                                          <p:spTgt spid="3"/>
                                        </p:tgtEl>
                                        <p:attrNameLst>
                                          <p:attrName>style.visibility</p:attrName>
                                        </p:attrNameLst>
                                      </p:cBhvr>
                                      <p:to>
                                        <p:strVal val="visible"/>
                                      </p:to>
                                    </p:set>
                                  </p:childTnLst>
                                </p:cTn>
                              </p:par>
                            </p:childTnLst>
                          </p:cTn>
                        </p:par>
                      </p:childTnLst>
                    </p:cTn>
                  </p:par>
                </p:childTnLst>
              </p:cTn>
              <p:nextCondLst>
                <p:cond evt="onClick" delay="0">
                  <p:tgtEl>
                    <p:spTgt spid="2"/>
                  </p:tgtEl>
                </p:cond>
              </p:nextCondLst>
            </p:seq>
          </p:childTnLst>
        </p:cTn>
      </p:par>
    </p:tnLst>
    <p:bldLst>
      <p:bldP spid="3" grpId="0"/>
    </p:bldLst>
  </p:timing>
```

### 구조 해설 (ECMA-376 §19.5)

- 계층: `tnLst → par → cTn(nodeType="tmRoot") → childTnLst → seq`
- 트리거 시퀀스: `seq/cTn@nodeType="interactiveSeq"` + `stCondLst/cond@evt="onClick"` +
  `tgtEl/spTgt@spid=트리거도형`
- 효과 노드 중첩: `interactiveSeq → clickPar → clickEffect(cTn@presetClass="entr"
  @presetID=1(Appear))` — 효과 하나가 par 3중 중첩
- `nodeType` 전체 열거: clickEffect · withEffect · afterEffect · mainSeq · interactiveSeq ·
  clickPar · withGroup · afterGroup · tmRoot
- `cond@evt` 전체 열거: onBegin onEnd begin end **onClick** onDblClick onMouseOver onMouseOut
  onNext onPrev onStopAudio
- `endSync evt="end" + rtn val="all"`: 트리거 재클릭 시 시퀀스 리셋 동작
- 메인 시퀀스(발표 클릭 진행)는 별도의 `seq/cTn@nodeType="mainSeq"` — 트리거와 나란히 공존

## 2. 모프 전환 — AlternateContent 래핑 (MS-PPTX §2.2.1 + §2.6.1.1)

naked `<p:transition>` 에 morph 를 넣지 말 것. Choice(신규 ns) + Fallback(표준 전환) 구조로
**도착 슬라이드**의 transition 자리에 삽입:

```xml
<mc:AlternateContent xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006">
  <mc:Choice xmlns:p159="http://schemas.microsoft.com/office/powerpoint/2015/09/main"
             Requires="p159">
    <p:transition spd="slow" p14:dur="2000"
        xmlns:p14="http://schemas.microsoft.com/office/powerpoint/2010/main">
      <p159:morph option="byObject"/>   <!-- byObject | byWord | byChar -->
    </p:transition>
  </mc:Choice>
  <mc:Fallback>
    <p:transition spd="slow"><p:fade/></p:transition>
  </mc:Fallback>
</mc:AlternateContent>
```

- 슬라이드 루트(`p:sld`)에 mc 네임스페이스가 이미 선언돼 있지 않으면 래퍼에 선언(위 예시처럼).
- 매칭은 두 슬라이드의 `p:cNvPr@name` — 강제 매칭은 `!!이름` (같은 타입끼리만, 슬라이드 내 유일).
- ※ 이 블록은 스펙 표 + ripple 공식 예시에서 조립한 재구성이며, 아래 "실측 검증" 절의 결과를
  따른다.

## 3. 줌 — COM 불가, raw XML 전용 (MS-PPTX 2016/*zoom)

`p:spTree` 안에 AlternateContent 로 삽입. Choice = 줌 요소, Fallback = 같은 위치·크기의 일반
`p:pic`(구역/슬라이드 줌) 또는 `p:grpSp`(요약 줌).

```xml
<mc:AlternateContent xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006">
  <mc:Choice xmlns:psez="http://schemas.microsoft.com/office/powerpoint/2016/sectionzoom"
             xmlns:p166="http://schemas.microsoft.com/office/powerpoint/2016/6/main"
             Requires="psez">
    <psez:sectionZm>
      <psez:sectionZmObj sectionId="{구역GUID}">
        <psez:zmPr id="{새GUID}" returnToParent="1" imageType="preview" showBg="1">
          <p166:blipFill><a:blip r:embed="rIdN"/><a:stretch><a:fillRect/></a:stretch></p166:blipFill>
          <p166:spPr>
            <a:xfrm><a:off x="..." y="..."/><a:ext cx="..." cy="..."/></a:xfrm>
            <a:prstGeom prst="rect"><a:avLst/></a:prstGeom>
          </p166:spPr>
        </psez:zmPr>
      </psez:sectionZmObj>
    </psez:sectionZm>
  </mc:Choice>
  <mc:Fallback><p:pic><!-- 같은 위치·이미지의 일반 그림 --></p:pic></mc:Fallback>
</mc:AlternateContent>
```

- **구역 줌/요약 줌**: `sectionId` = presentation.xml 의
  `p:extLst/p:ext uri="{521415D9-36F7-43E2-AB2F-B90AF26B5E84}"/p14:sectionLst/p14:section@id`
  GUID 와 정합 필수 (구역이 없으면 먼저 sectionLst 부터 만들어야 함).
- **슬라이드 줌**(`sldZm`): `sldZmObj@sldId` = `p:sldIdLst/p:sldId@id` 정수.
- `returnToParent="1"` = "줌으로 돌아가기". 커버 이미지는 슬라이드 .rels 의 image 관계(`r:embed`).
- 요약 줌(`summaryZm`)은 `summaryZmObj*` + `gridLayout|fixedLayout` 선택 필수.
- ※ 스펙에 완결 예시가 없어 스키마에서 재구성한 것 — **실기 미검증**. 가장 안전한 대안: 줌이
  필요한 덱은 PowerPoint UI 로 줌 1개를 만든 실파일을 unzip 해 골든 템플릿을 채취한 뒤 복제.

## 4. zip 수술 절차 (Python 표준 라이브러리)

```python
import zipfile, shutil, re
shutil.copy(src, dst)
# zipfile 은 in-place 교체 불가 — 전체 재작성
with zipfile.ZipFile(src) as zin:
    items = {i.filename: zin.read(i.filename) for i in zin.infolist()}
xml = items["ppt/slides/slide2.xml"].decode("utf-8")
xml = xml.replace("</p:cSld>", "</p:cSld>" )  # 예: clrMapOvr 뒤에 전환 블록 삽입
items["ppt/slides/slide2.xml"] = xml.encode("utf-8")
with zipfile.ZipFile(dst, "w", zipfile.ZIP_DEFLATED) as zout:
    for name, data in items.items():
        zout.writestr(name, data)
```

주의: `[Content_Types].xml` · `.rels` 는 새 파트를 추가할 때만 갱신 필요(전환·타이밍 주입은 불필요,
줌 커버 이미지 추가 시엔 필요).

## 실측 검증 기록

- §1 트리거 골든 템플릿: PowerPoint 산출물 그대로 — 유효 (2026-07-24)
- §2 모프 재구성 블록: **실기 검증 성공** (2026-07-24) — zip 수술로 주입한 블록을 PowerPoint가
  `EntryEffect=3954`(ppEffectMorphByObject), `Duration=2.0`(`p14:dur="2000"` 매핑)으로 정확히
  인식, 저장 왕복 후에도 유지(= silent repair 없음).
- PowerPoint 재직렬화 골든(왕복 후 실파일 원문 — AlternateContent 유지, p159 선언은 래퍼 루트로 승격):

```xml
<mc:AlternateContent xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006" xmlns:p159="http://schemas.microsoft.com/office/powerpoint/2015/09/main">
<mc:Choice Requires="p159">
<p:transition spd="slow" xmlns:p14="http://schemas.microsoft.com/office/powerpoint/2010/main" p14:dur="2000">
<p159:morph option="byObject"/>
</p:transition>
</mc:Choice>
<mc:Fallback xmlns="">
<p:transition spd="slow">
<p:fade/>
</p:transition>
</mc:Fallback>
</mc:AlternateContent>
```
