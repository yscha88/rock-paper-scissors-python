# verify_pptx.ps1 — 산출 pptx의 구조(인터랙션)·텍스트를 실측 덤프한다
# 스킬 검증 규약: COM으로 열어 기대값 확인 → 저장 왕복 → 재확인(silent repair 탐지)
param(
  [string]$DumpDir = ""
)
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$src  = Join-Path $root "slides\스터디_슬라이드.pptx"
if (-not $DumpDir) { $DumpDir = Join-Path $root "tools\_verify" }
New-Item -ItemType Directory -Force $DumpDir | Out-Null

function Get-ShapeTexts($shape) {
  $out = @()
  if ($shape.Type -eq 6) {                      # msoGroup
    foreach ($it in $shape.GroupItems) { $out += Get-ShapeTexts $it }
    return $out
  }
  if ($shape.HasTable -eq -1) {
    $tbl = $shape.Table
    for ($rr = 1; $rr -le $tbl.Rows.Count; $rr++) {
      for ($cc = 1; $cc -le $tbl.Columns.Count; $cc++) {
        try { $t = $tbl.Cell($rr, $cc).Shape.TextFrame.TextRange.Text; if ($t) { $out += $t } } catch {}
      }
    }
    return $out
  }
  try {
    if ($shape.HasTextFrame -eq -1 -and $shape.TextFrame.HasText -eq -1) {
      $out += $shape.TextFrame.TextRange.Text
    }
  } catch {}
  return $out
}

function Read-Deck($pres) {
  $slides = @()
  foreach ($s in $pres.Slides) {
    $texts = @()
    foreach ($sh in $s.Shapes) { $texts += Get-ShapeTexts $sh }
    $notes = ""
    try {
      foreach ($ph in $s.NotesPage.Shapes) {
        if ($ph.PlaceholderFormat.Type -eq 2) { $notes = $ph.TextFrame.TextRange.Text }
      }
    } catch {}
    $slides += [pscustomobject]@{ n = $s.SlideIndex; texts = $texts; notes = $notes }
  }
  return $slides
}

function Assert-Structure($pres, [string]$tag) {
  $rep = [ordered]@{}
  $rep.slideCount = $pres.Slides.Count
  $rep.iseqSlide2 = $pres.Slides.Item(2).TimeLine.InteractiveSequences.Count
  $rep.morph2 = $pres.Slides.Item(2).SlideShowTransition.EntryEffect
  $rep.morph3 = $pres.Slides.Item(3).SlideShowTransition.EntryEffect
  $rep.morph5 = $pres.Slides.Item(5).SlideShowTransition.EntryEffect
  $rep.mainSeq4 = $pres.Slides.Item(4).TimeLine.MainSequence.Count    # 기대 5 (흐름 3클릭)
  $rep.mainSeq10 = $pres.Slides.Item(10).TimeLine.MainSequence.Count  # 기대 9 (할당5+누수2+강조2)
  $links = @()
  for ($i = 0; $i -lt 6; $i++) {
    $sh = $pres.Slides.Item(3).Shapes.Item("cardLink$i")
    $as = $sh.ActionSettings.Item(1)
    $links += "$($as.Action):$($as.Hyperlink.SubAddress)"
  }
  $rep.cardLinks = $links
  $secs = @()
  for ($k = 1; $k -le $pres.SectionProperties.Count; $k++) {
    $secs += "$($pres.SectionProperties.Name($k)) [$($pres.SectionProperties.SlidesCount($k))]"
  }
  $rep.sections = $secs
  Write-Output "== $tag =="
  Write-Output ($rep | ConvertTo-Json -Depth 3)
}

$app = New-Object -ComObject PowerPoint.Application
try {
  $pres = $app.Presentations.Open($src, 0, 0, 0)   # RW, 창 없음
  Assert-Structure $pres "1차 (빌드 직후)"

  # silent-repair 탐지: 왕복 저장 → 재열기
  $tmp = Join-Path $DumpDir "roundtrip.pptx"
  $pres.SaveCopyAs($tmp, 24)
  $pres.Close()
  $pres2 = $app.Presentations.Open($tmp, 0, 0, 0)
  Assert-Structure $pres2 "2차 (저장 왕복 후)"

  # 텍스트 덤프 + 대표 슬라이드 PNG
  $deck = Read-Deck $pres2
  $deck | ConvertTo-Json -Depth 5 | Set-Content (Join-Path $DumpDir "pptx_texts.json") -Encoding UTF8
  foreach ($n in 1,2,3,4,7,10,11,15,22,25,31,37,47,55) {
    $pres2.Slides.Item($n).Export((Join-Path $DumpDir ("s{0:d2}.png" -f $n)), "PNG", 1280, 720)
  }
  Write-Output "덤프: $DumpDir (pptx_texts.json + PNG 14장)"
  $pres2.Close()
} finally { $app.Quit() | Out-Null }
