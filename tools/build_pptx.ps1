# build_pptx.ps1 — master.md 파생 덱 JSON(tools/pptx_deck.json)을 PowerPoint COM으로 네이티브 조립
# 사용법: pwsh -File tools/build_pptx.ps1
# 규칙: .claude/skills/pptx-interactions (자동 DOM 변환 금지 — 이 스크립트는 '조립'만 한다)
param([string]$Out = "")
$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$deck = Get-Content (Join-Path $root "tools\pptx_deck.json") -Raw -Encoding UTF8 | ConvertFrom-Json
$out  = if ($Out) { $Out } else { Join-Path $root "slides\스터디_슬라이드.pptx" }

# ── 팔레트 (slides.css 토큰, COM RGB = R + G*256 + B*65536) ──
function RGB([int]$r,[int]$g,[int]$b){ $r + $g*256 + $b*65536 }
$C = @{
  bg     = RGB 242 243 245; ink    = RGB 35 38 45;   muted = RGB 91 98 112
  accent = RGB 229 100 94;  rock   = RGB 224 164 88; paper = RGB 51 167 156
  codebg = RGB 245 246 248; border = RGB 215 218 224; codetx = RGB 43 47 56
  white  = RGB 255 255 255
}
$SANS = "Segoe UI"; $MONO = "Consolas"
$W = 960.0; $H = 540.0; $MX = 56.0   # 슬라이드 크기(pt)·좌우 여백

function New-Text($slide,[double]$x,[double]$y,[double]$w,[double]$h,[string]$text,
                  [double]$size,[bool]$bold,[int]$color,[string]$font=$SANS){
  $tb = $slide.Shapes.AddTextbox(1,$x,$y,$w,$h)
  $tr = $tb.TextFrame.TextRange; $tr.Text = $text
  $tr.Font.Name = $font; $tr.Font.Size = $size; $tr.Font.Bold = [int]$bold; $tr.Font.Color.RGB = $color
  $tb.TextFrame.WordWrap = -1; $tb.TextFrame.MarginLeft=0; $tb.TextFrame.MarginRight=0
  $tb.TextFrame.MarginTop=0; $tb.TextFrame.MarginBottom=0
  return $tb
}
# ── 요소 렌더러: 각자 "실측" 사용 높이를 반환 (추정식 금지 — 편집본 백포트) ──
function Draw-Elem($slide,$e,[double]$x,[double]$y,[double]$w){
  switch ($e.t) {
    "lead" {
      $tb = New-Text $slide $x $y $w 24 $e.text 15 $false $C.ink
      $tb.TextFrame.AutoSize = 1                       # 텍스트에 맞게 높이 실측
      return $tb.Height + 10
    }
    "text" {
      $col = if ($e.muted) { $C.muted } else { $C.ink }
      $tb = New-Text $slide $x $y $w 18 $e.text 12 $false $col
      $tb.TextFrame.AutoSize = 1
      return $tb.Height + 8
    }
    "bullets" {
      $cy = $y
      foreach($it in $e.items){
        $dot = $slide.Shapes.AddShape(9,$x,$cy+6,5,5); $dot.Fill.ForeColor.RGB = $C.accent
        $dot.Line.Visible = 0
        $tb = New-Text $slide ($x+14) $cy ($w-16) 20 $it 13 $false $C.ink
        $tb.TextFrame.AutoSize = 1
        $cy += $tb.Height + 6
      }
      return ($cy - $y) + 4
    }
    "code" {
      $pad = 10.0; $titleH = if ($e.title) { 18.0 } else { 0.0 }
      $lineArr = @($e.lines)
      $codeText = ($lineArr -join "`r")
      # 텍스트 먼저 실측(AutoSize) — 한글 주석 섞인 줄의 실제 행높이를 반영
      $tb = New-Text $slide ($x+$pad) ($y+$titleH+$pad) ($w-$pad*2) 20 $codeText 11 $false $C.codetx $MONO
      $tb.TextFrame.WordWrap = 0
      $tb.TextFrame.AutoSize = 1
      if ($tb.Width -gt ($w - $pad*2)) {               # 최장 줄이 폭 초과 → 자동 줄바꿈 전환
        $tb.TextFrame.WordWrap = -1
        $tb.Width = $w - $pad*2
      }
      if ($lineArr.Count -le 8) {                      # 짧은 블록은 행간 1.5 (편집본 반영)
        $pf = $tb.TextFrame.TextRange.ParagraphFormat
        $pf.LineRuleWithin = -1; $pf.SpaceWithin = 1.5
      }
      $txH = $tb.Height
      $script:codeMeta = @{ y0 = ($y+$titleH+$pad); lh = ($txH / [math]::Max(1,$lineArr.Count)) }
      $hgt = $titleH + $pad*2 + $txH + 4               # 하단 숨통(편집본 반영)
      $box = $slide.Shapes.AddShape(5,$x,$y,$w,$hgt)   # roundRect
      $box.Fill.ForeColor.RGB = $C.codebg; $box.Line.ForeColor.RGB = $C.border; $box.Line.Weight = 0.75
      $box.Adjustments.Item(1) = 0.04
      $box.ZOrder(1)                                   # msoSendToBack — 텍스트 뒤로
      if ($e.title) {
        [void](New-Text $slide ($x+$pad) ($y+4) ($w-$pad*2) 14 $e.title 9 $false $C.muted $MONO)
      }
      return $hgt + 10
    }
    "table" {
      $hdr = @($e.header); $rows = @($e.rows)
      $nR = $rows.Count + 1; $nC = $hdr.Count
      $rowH = 22.0; $hgt = $nR * $rowH
      $shape = $slide.Shapes.AddTable($nR,$nC,$x,$y,$w,$hgt)
      $tbl = $shape.Table
      # 주의: 루프 변수에 $c/$r 금지 — PS는 대소문자 무시라 팔레트 $C를 가린다
      for($cc=1;$cc -le $nC;$cc++){
        $cell = $tbl.Cell(1,$cc); $cell.Shape.Fill.ForeColor.RGB = $C.ink
        $tr = $cell.Shape.TextFrame.TextRange; $tr.Text = [string]$hdr[$cc-1]
        $tr.Font.Name=$SANS; $tr.Font.Size=11; $tr.Font.Bold=-1; $tr.Font.Color.RGB=$C.white
      }
      for($rr=1;$rr -le $rows.Count;$rr++){
        $rowArr = @($rows[$rr-1])
        for($cc=1;$cc -le $nC;$cc++){
          $cell = $tbl.Cell($rr+1,$cc)
          $cell.Shape.Fill.ForeColor.RGB = if ($rr % 2 -eq 0) { $C.bg } else { $C.white }
          $tr = $cell.Shape.TextFrame.TextRange
          $tr.Text = if ($cc -le $rowArr.Count) { [string]$rowArr[$cc-1] } else { "" }
          $tr.Font.Name=$SANS; $tr.Font.Size=10.5; $tr.Font.Bold=0; $tr.Font.Color.RGB=$C.ink
        }
      }
      # 셀을 채우며 부풀려진 행 높이는 자동 축소되지 않는다 — 리셋하면 콘텐츠 최소치로 클램프됨
      for($rr2=1;$rr2 -le $nR;$rr2++){ $tbl.Rows.Item($rr2).Height = $rowH }
      return $shape.Height + 12   # 리셋 후의 실측 높이(= 내용 반영 최소)
    }
    default { return 0 }
  }
}

function Draw-Chrome($slide,[string]$eyebrow,[string]$title){
  $slide.FollowMasterBackground = 0
  $slide.Background.Fill.ForeColor.RGB = $C.bg
  $tick = $slide.Shapes.AddShape(1,$MX,34,22,3); $tick.Fill.ForeColor.RGB = $C.accent; $tick.Line.Visible = 0
  [void](New-Text $slide ($MX+30) 27 500 16 $eyebrow 10 $false $C.muted $MONO)
  [void](New-Text $slide $MX 50 ($W-$MX*2) 34 $title 24 $true $C.ink)
}
function Set-Notes($slide,[string]$notes){
  if (-not $notes) { return }
  try {
    foreach($ph in $slide.NotesPage.Shapes){
      if ($ph.PlaceholderFormat.Type -eq 2) { $ph.TextFrame.TextRange.Text = $notes; return }
    }
  } catch {}
}

# ── 도형 다이어그램 (#4·#5 번역 흐름 + 모프, #10 메모리 작업대 + 애니) ──
function Draw-FlowBox($slide,[double]$x,[double]$y,[double]$w,[double]$h,[string]$text,[string]$name,[int]$fill,[int]$txcol){
  $b = $slide.Shapes.AddShape(5,$x,$y,$w,$h)
  $b.Name = $name
  $b.Fill.ForeColor.RGB = $fill; $b.Line.ForeColor.RGB = $C.border; $b.Line.Weight = 0.75
  $tr = $b.TextFrame.TextRange; $tr.Text = $text
  $tr.Font.Name = $SANS; $tr.Font.Size = 12; $tr.Font.Bold = -1; $tr.Font.Color.RGB = $txcol
  return $b
}
function Draw-Arrow($slide,[double]$x,[double]$y,[double]$w,[string]$name){
  $a = $slide.Shapes.AddShape(33,$x,$y,$w,14)          # msoShapeRightArrow
  $a.Name = $name; $a.Fill.ForeColor.RGB = $C.muted; $a.Line.Visible = 0
  return $a
}
# 특수 렌더러: 해당하면 사용 높이, 아니면 -1
function Draw-Special($slide,[int]$n,$e,[double]$x,[double]$y,[double]$w){
  if ($e.t -ne "code") { return -1.0 }
  $bw=214.0; $bh=58.0; $aw=52.0; $gap=17.0
  $rowW = 3*$bw + 2*$aw + 4*$gap
  if ($n -eq 4 -and $e.title -like "소스코드가*") {
    $x0 = $x + ($w - $rowW)/2; $ty = $y + 16; $cx = $x0
    $src = Draw-FlowBox $slide $cx $ty $bw $bh "📝 소스코드`r(사람이 읽는 글)" "!!flow-src" $C.white $C.ink
    $cx += $bw + $gap
    [void](New-Text $slide $cx ($ty-14) ($aw+2) 13 "번역" 9.5 $false $C.muted $MONO)
    $a1 = Draw-Arrow $slide $cx ($ty+$bh/2-7) $aw "!!flow-a1"; $cx += $aw + $gap
    $mc  = Draw-FlowBox $slide $cx $ty $bw $bh "🔢 기계어`r(0과 1)" "!!flow-mc" $C.white $C.ink
    $cx += $bw + $gap
    $a2 = Draw-Arrow $slide $cx ($ty+$bh/2-7) $aw "!!flow-a2"; $cx += $aw + $gap
    $cpu = Draw-FlowBox $slide $cx $ty $bw $bh "⚙️ CPU 실행`r(요리 완성)" "!!flow-cpu" $C.ink $C.white
    $seq = $slide.TimeLine.MainSequence                 # 클릭 3단계 등장
    [void]$seq.AddEffect($src,10,0,1); [void]$seq.AddEffect($a1,10,0,1); [void]$seq.AddEffect($mc,10,0,2)
    [void]$seq.AddEffect($a2,10,0,1); [void]$seq.AddEffect($cpu,10,0,2)
    return $bh + 16 + 26
  }
  if ($n -eq 5 -and $e.title -like "번역의 층*") {      # #4와 같은 !!이름 → 모프로 층이 얹힘
    $x0 = $x + ($w - $rowW)/2; $rowY = $y + 92
    $pr = Draw-FlowBox $slide $x0 $y $bw $bh "🗣 프롬프트`r(사람의 말)" "flowPrompt" $C.paper $C.white
    $da = $slide.Shapes.AddShape(36, $x0+$bw/2-12, $y+$bh+3, 24, ($rowY-$y-$bh-6))   # msoShapeDownArrow
    $da.Name = "flowAiArrow"; $da.Fill.ForeColor.RGB = $C.paper; $da.Line.Visible = 0
    [void](New-Text $slide ($x0+$bw/2+20) ($y+$bh+8) 130 14 "AI 가 코딩" 9.5 $false $C.muted $MONO)
    $cx = $x0
    [void](Draw-FlowBox $slide $cx $rowY $bw $bh "📝 소스코드`r(사람이 읽는 글)" "!!flow-src" $C.white $C.ink)
    $cx += $bw + $gap
    [void](New-Text $slide $cx ($rowY-14) ($aw+2) 13 "번역" 9.5 $false $C.muted $MONO)
    [void](Draw-Arrow $slide $cx ($rowY+$bh/2-7) $aw "!!flow-a1"); $cx += $aw + $gap
    [void](Draw-FlowBox $slide $cx $rowY $bw $bh "🔢 기계어`r(0과 1)" "!!flow-mc" $C.white $C.ink)
    $cx += $bw + $gap
    [void](Draw-Arrow $slide $cx ($rowY+$bh/2-7) $aw "!!flow-a2"); $cx += $aw + $gap
    [void](Draw-FlowBox $slide $cx $rowY $bw $bh "⚙️ CPU/GPU 실행`r(AI 는 GPU 도)" "!!flow-cpu" $C.ink $C.white)
    return 92 + $bh + 20
  }
  if ($n -eq 10 -and $e.title -like "메모리 생애주기*") {
    $pw=236.0; $ph=52.0; $paw=44.0; $pg=12.0
    $x0 = $x + ($w - (3*$pw + 2*$paw + 4*$pg))/2; $cx = $x0
    $texts = @("📥 빌린다 — 할당`r(malloc · new · 객체 생성)", "✍️ 쓴다`r(값을 올려 두고 읽는다)", "📤 반납한다 — 해제`r(free · GC 회수)")
    for($k2=0;$k2 -lt 3;$k2++){
      $p = Draw-FlowBox $slide $cx $y $pw $ph $texts[$k2] "memPill$k2" $C.white $C.ink
      $p.TextFrame.TextRange.Font.Size = 11
      $cx += $pw + $pg
      if ($k2 -lt 2) { [void](Draw-Arrow $slide $cx ($y+$ph/2-7) $paw "memPillA$k2"); $cx += $paw + $pg }
    }
    return $ph + 16
  }
  if ($n -eq 10 -and $e.title -like "작업대 상태*") {
    $cw2=96.0; $gap2=8.0; $chh=44.0
    $x0 = $x + ($w - (8*$cw2 + 7*$gap2))/2
    for($k2=0;$k2 -lt 8;$k2++){                          # 바탕 8칸 (빈 작업대)
      $b = $slide.Shapes.AddShape(1, $x0+$k2*($cw2+$gap2), $y, $cw2, $chh)
      $b.Name = "cellBase$k2"; $b.Fill.ForeColor.RGB = $C.white
      $b.Line.ForeColor.RGB = $C.border; $b.Line.Weight = 0.75
    }
    $seq = $slide.TimeLine.MainSequence
    $uses = @()
    foreach($k2 in 0,1,2,3,4){                           # 클릭1: 할당 — 5칸이 채워진다
      $u = $slide.Shapes.AddShape(1, $x0+$k2*($cw2+$gap2), $y, $cw2, $chh)
      $u.Name = "cellUse$k2"; $u.Fill.ForeColor.RGB = $C.ink; $u.Line.Visible = 0
      $tr = $u.TextFrame.TextRange; $tr.Text = "사용 중"
      $tr.Font.Name=$SANS; $tr.Font.Size=10; $tr.Font.Bold=0; $tr.Font.Color.RGB=$C.white
      $uses += $u
    }
    [void]$seq.AddEffect($uses[0],10,0,1)
    foreach($k2 in 1,2,3,4){ [void]$seq.AddEffect($uses[$k2],10,0,2) }
    $leaks = @()
    foreach($k2 in 2,4){                                 # 클릭2: 반납을 잊은 두 칸이 누수로 반전
      $l = $slide.Shapes.AddShape(1, $x0+$k2*($cw2+$gap2), $y, $cw2, $chh)
      $l.Name = "cellLeak$k2"; $l.Fill.ForeColor.RGB = $C.accent; $l.Line.Visible = 0
      $tr = $l.TextFrame.TextRange; $tr.Text = "누수!"
      $tr.Font.Name=$SANS; $tr.Font.Size=10.5; $tr.Font.Bold=-1; $tr.Font.Color.RGB=$C.white
      $leaks += $l
    }
    [void]$seq.AddEffect($leaks[0],10,0,1); [void]$seq.AddEffect($leaks[1],10,0,2)
    [void]$seq.AddEffect($leaks[0],59,0,3); [void]$seq.AddEffect($leaks[1],59,0,2)   # GrowShrink 강조
    return $chh + 14
  }
  return -1.0
}

# ── 본 조립 ──
$app = New-Object -ComObject PowerPoint.Application
try {
  $pres = $app.Presentations.Add(0)
  $pres.PageSetup.SlideWidth = $W; $pres.PageSetup.SlideHeight = $H

  # 1) 특수 슬라이드 1~3 (인터랙션 쇼케이스) ------------------------------
  # #1 타이틀
  $s1 = $pres.Slides.Add(1,12)
  $s1.FollowMasterBackground = 0; $s1.Background.Fill.ForeColor.RGB = $C.bg
  $hands = New-Text $s1 $MX 90 500 80 "✊ ✋ ✌️" 54 $false $C.ink
  $hands.Name = "!!hands"
  $tick = $s1.Shapes.AddShape(1,$MX,190,22,3); $tick.Fill.ForeColor.RGB=$C.accent; $tick.Line.Visible=0
  [void](New-Text $s1 ($MX+30) 183 300 16 "강의 개요" 10 $false $C.muted $MONO)
  [void](New-Text $s1 $MX 208 760 110 "가위바위보로 배우는`rCS & Python" 44 $true $C.ink)
  [void](New-Text $s1 $MX 330 720 60 "같은 가위바위보를 Java · C++ · Python 세 언어로 만들어 보며, 컴퓨터가 코드를 실행하는 원리부터 Python 환경·문법·언어별 무게 차이까지 익힌다." 15 $false $C.muted)
  [void](New-Text $s1 $MX 420 760 24 "Java Spring Boot   ·   C++20 CLI   ·   Python 3.11+   ·   코딩 입문, 기초 전제 없음" 12 $false $C.muted $MONO)
  Set-Notes $s1 "AI 대학원생 대상. 세 언어 비교로 시작을 연다."

  # #2 논지 + 트리거 리빌 (스킬 §1: InteractiveSequences)
  $s2 = $pres.Slides.Add(2,12)
  Draw-Chrome $s2 "이 강의의 논지" "Code를 이해한다는 것"
  $h2s = New-Text $s2 820 30 90 30 "✊✋✌️" 16 $false $C.muted; $h2s.Name = "!!hands"
  [void](New-Text $s2 $MX 96 840 40 "프롬프트 엔지니어링 시대에도 코딩을 배우는 이유 — 이 코드에는 버그가 하나 있다. 코드를 모르면 이 버그를 못 찾는다." 14 $false $C.ink)
  $codeE = [pscustomobject]@{ t="code"; title="life.c — 인생 1년"; lines=@(
    "for (int i=0; i<365; i++) {   // 하루 단위로 1년",
    "    money++;                  // 매일 돈을 번다 -> OK",
    "    age++;                    // ???",
    "    if (age > 30)",
    "        changeJOB(PhD);",
    "}") }
  [void](Draw-Elem $s2 $codeE $MX 150 470)
  $btn = $s2.Shapes.AddShape(5,590,160,240,44)
  $btn.Fill.ForeColor.RGB = $C.accent; $btn.Line.Visible = 0; $btn.Name = "revealBtn"
  $btn.TextFrame.TextRange.Text = "버그를 찾아보세요"
  $btn.TextFrame.TextRange.Font.Name=$SANS; $btn.TextFrame.TextRange.Font.Size=13; $btn.TextFrame.TextRange.Font.Bold=-1
  $btn.TextFrame.TextRange.Font.Color.RGB = $C.white
  # 정답(강조 사각형 + 해설) — 그룹으로 묶어 클릭 한 번에 등장
  # 하이라이트는 코드 3행(age++)을 실측 행높이 기준 중앙에 덮는다
  $hlH = [math]::Min($script:codeMeta.lh + 2, 20)
  $hlY = $script:codeMeta.y0 + 2*$script:codeMeta.lh + ($script:codeMeta.lh - $hlH)/2
  $hl = $s2.Shapes.AddShape(1,($MX+8),$hlY,452,$hlH)
  $hl.Fill.ForeColor.RGB = $C.accent; $hl.Fill.Transparency = 0.72; $hl.Line.ForeColor.RGB=$C.accent; $hl.Name="bugHl"
  $ansT = New-Text $s2 590 220 300 40 "age++ 가 하루 루프 안에 있다 — 1년에 365살. 한 달이면 30을 넘겨 changeJOB이 엉뚱한 시점에 발동한다. 수정은 한 줄 이동이 아니라 바깥에 '해(年)' 루프가 하나 더 필요하다." 12.5 $false $C.ink
  $ansT.TextFrame.AutoSize = 1
  $ansT.Name = "bugAns"
  $grp = $s2.Shapes.Range(@("bugHl","bugAns")).Group(); $grp.Name = "bugReveal"
  $seq = $s2.TimeLine.InteractiveSequences.Add(1)
  [void]$seq.AddTriggerEffect($grp, 10, 4, $btn)     # Fade=10, OnShapeClick=4
  Set-Notes $s2 "버튼 클릭 시 정답 그룹 페이드 인(트리거). 리빌 전에는 답이 보이지 않는다."

  # #3 커리큘럼 + 목차 하이퍼링크 (섹션 점프)
  $s3 = $pres.Slides.Add(3,12)
  Draw-Chrome $s3 "커리큘럼" "무엇을 배우나 — 문서 5편 + 실습 6종"
  $h3s = New-Text $s3 820 30 90 30 "✊✋✌️" 12 $false $C.muted; $h3s.Name = "!!hands"
  $cards = @(
    @{ label="01 · CS 기초";     desc="컴파일 vs 인터프리터 · 타입 · 메모리(GC)";  goto=4;  col=$C.rock },
    @{ label="02 · Python 환경"; desc="venv · uv · conda · poetry · pinning";      goto=14; col=$C.paper },
    @{ label="03 · Python 문법"; desc="변수·함수·클래스 · 던더 · Pydantic";        goto=17; col=$C.accent },
    @{ label="04 · 언어 비교";   desc="같은 기능의 전체 구현을 통째로";            goto=29; col=$C.ink },
    @{ label="05 · 디버깅";      desc="에러 라벨 · OOM의 정체 · 역추적";           goto=37; col=$C.accent },
    @{ label="실습 6종";         desc="바이너리·venv·uv·poetry·conda·웹 서버";     goto=41; col=$C.paper }
  )
  $cw=272; $ch=96; $gx=16; $gy=14; $x0=$MX; $y0=118; $i=0
  foreach($cd in $cards){
    $cx = $x0 + ($i % 3) * ($cw+$gx); $cy = $y0 + [math]::Floor($i/3) * ($ch+$gy)
    $card = $s3.Shapes.AddShape(5,$cx,$cy,$cw,$ch)
    $card.Name = "cardLink$i"
    $card.Fill.ForeColor.RGB = $C.white; $card.Line.ForeColor.RGB = $C.border; $card.Line.Weight=0.75
    $chip = $s3.Shapes.AddShape(9,$cx+14,$cy+16,8,8); $chip.Fill.ForeColor.RGB = $cd.col; $chip.Line.Visible=0
    [void](New-Text $s3 ($cx+30) ($cy+10) ($cw-40) 18 $cd.label 11 $true $C.ink $MONO)
    [void](New-Text $s3 ($cx+14) ($cy+36) ($cw-28) 48 $cd.desc 11 $false $C.muted)
    $i++
  }
  [void](New-Text $s3 $MX 350 700 20 "발표 모드에서 카드를 클릭하면 해당 장으로 이동합니다." 11 $false $C.muted)
  Set-Notes $s3 "각 카드는 하이퍼링크(섹션 첫 장 점프). 실습 06 웹 서버까지 포함."

  # 2) 본문 슬라이드 (JSON 저작물 조립) -----------------------------------
  foreach($sl in ($deck.slides | Sort-Object n)){
    $idx = $pres.Slides.Count + 1
    $s = $pres.Slides.Add($idx,12)
    Draw-Chrome $s $sl.eyebrow $sl.title
    $yTop = 100.0
    if ($sl.left -or $sl.right) {
      $wCol = ($W - $MX*2 - 24) / 2
      $y = $yTop; foreach($e in @($sl.left))  { if($e){ $y += Draw-Elem $s $e $MX $y $wCol } }
      $y = $yTop; foreach($e in @($sl.right)) { if($e){ $y += Draw-Elem $s $e ($MX+$wCol+24) $y $wCol } }
    } else {
      $y = $yTop
      foreach($e in @($sl.body)) {
        if(-not $e){ continue }
        $hSp = Draw-Special $s $sl.n $e $MX $y ($W-$MX*2)
        if ($hSp -ge 0) { $y += $hSp } else { $y += Draw-Elem $s $e $MX $y ($W-$MX*2) }
      }
    }
    $noteExtra = @{ 4=" (클릭 3번: 소스코드→기계어→CPU 순서로 등장)"
                    5=" (모프 도착 — #4의 흐름이 내려가며 프롬프트 층이 얹힘)"
                    10=" (클릭1: 할당 5칸 채워짐 · 클릭2: 두 칸이 누수!로 반전+강조)" }
    Set-Notes $s ($sl.notes + $noteExtra[[int]$sl.n])
  }

  # 3) 마무리(#55) --------------------------------------------------------
  $sE = $pres.Slides.Add($pres.Slides.Count+1,12)
  Draw-Chrome $sE "마무리" "이제, 직접 만들 차례"
  [void](New-Text $sE $MX 100 840 56 "같은 판정식 (player - computer + 3) % 3 이 언어마다 다른 무게를 입는 것을 봤다 — Java의 계층, C++의 소유권, Python의 한 파일. 이 저장소는 그 차이를 손으로 확인하는 `"진짜 만들어 보기`" 예제다." 14 $false $C.ink)
  $cl = [pscustomobject]@{ t="code"; title="지금 시작"; lines=@(
    "git clone https://github.com/yscha88/rock-paper-scissors-python",
    "cd rock-paper-scissors-python",
    "uv sync",
    "uv run python -m rps 바위",
    "# -> 당신: ROCK / 컴퓨터: SCISSORS -> WIN") }
  [void](Draw-Elem $sE $cl $MX 180 620)
  [void](New-Text $sE $MX 330 840 40 "이어서 해볼 것 — ① _ALIASES에 새 언어 별칭 추가  ② uv run pytest 로 확인  ③ rps.web 을 API로. 고치고 확인하는 것까지가 실습이다." 12.5 $false $C.muted)
  Set-Notes $sE "클론-실행 시퀀스로 마무리. 과제 3종 안내."

  # 4) 커리큘럼 카드 하이퍼링크(슬라이드 확정 후) + 모프 + 섹션 ------------
  $i = 0
  foreach($cd in $cards){
    $target = $pres.Slides.Item([int]$cd.goto)
    $shape = $s3.Shapes.Item("cardLink$i")
    $as = $shape.ActionSettings.Item(1)
    $as.Action = 7                            # ppActionHyperlink
    # 주의(실측): 형식은 "SlideID,인덱스,제목" — 순서가 다르면 저장 시 조용히 제거됨
    $as.Hyperlink.SubAddress = "$($target.SlideID),$($target.SlideIndex),$($target.Name)"
    $i++
  }
  foreach($n in 2,3,5){                        # 모프: 2·3=!!hands, 5=!!flow-* 층 얹힘 (도착 슬라이드에)
    $pres.Slides.Item($n).SlideShowTransition.EntryEffect = 3954   # ppEffectMorphByObject
    $pres.Slides.Item($n).SlideShowTransition.Duration = 0.9
  }
  $secDef = @(@(1,"개요"),@(4,"01 CS 기초"),@(14,"02 Python 환경"),@(17,"03 Python 문법"),
              @(29,"04 언어 비교"),@(37,"디버깅"),@(41,"실습"),@(55,"마무리"))
  for($k=$secDef.Count-1;$k -ge 0;$k--){
    [void]$pres.SectionProperties.AddBeforeSlide($secDef[$k][0], $secDef[$k][1])
  }
  for($k=$pres.SectionProperties.Count;$k -ge 1;$k--){   # 빈 "기본 구역" 제거
    if ($pres.SectionProperties.SlidesCount($k) -eq 0) { $pres.SectionProperties.Delete($k, $false) }
  }

  $pres.SaveAs($out, 24)
  Write-Output ("저장: {0} — 총 {1}장, 섹션 {2}개" -f $out, $pres.Slides.Count, $pres.SectionProperties.Count)
  $pres.Close()
} finally { $app.Quit() | Out-Null }
