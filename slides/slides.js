/* 가위바위보로 배우는 CS & Python — 슬라이드 내비게이션
   키보드 ←/→/Space, 터치 스와이프, 닷 인디케이터, 진행바, 테마 전환, 버그 리빌 */
(function(){
  var slides = Array.prototype.slice.call(document.querySelectorAll('.slide'));
  var total = slides.length, i = 0;
  var curEl = document.getElementById('cur');
  var totalEl = document.getElementById('total');
  var progress = document.getElementById('progress');
  var dotsWrap = document.getElementById('dots');
  totalEl.textContent = total;

  // 닷 인디케이터 생성
  slides.forEach(function(_, idx){
    var b = document.createElement('button');
    b.setAttribute('aria-label', (idx+1)+'번 슬라이드로');
    b.addEventListener('click', function(){ go(idx); });
    dotsWrap.appendChild(b);
  });
  var dots = Array.prototype.slice.call(dotsWrap.children);

  // 챕터 내비: 각 버튼이 가리키는 슬라이드 인덱스를 미리 계산
  var chapBtns = Array.prototype.slice.call(document.querySelectorAll('#chapnav [data-goto]'));
  var chapStarts = chapBtns.map(function(b){
    return slides.indexOf(document.querySelector(b.getAttribute('data-goto')));
  });

  // 챕터 드롭다운: 버튼 호버 → 그 챕터의 슬라이드(섹션) 목록을 보여 주고 클릭으로 점프
  var chapnav = document.getElementById('chapnav');
  var drop = document.createElement('div');
  drop.className = 'chapdrop';
  chapnav.appendChild(drop);
  function slideTitle(s){
    var h = s.querySelector('h2') || s.querySelector('h1');
    return h ? h.textContent.replace(/\s+/g, ' ').trim() : '';
  }
  chapBtns.forEach(function(b, k){
    b.addEventListener('mouseenter', function(){
      var start = chapStarts[k];
      if(start < 0) return;
      var end = total - 1;
      for(var m = k + 1; m < chapStarts.length; m++){
        if(chapStarts[m] >= 0){ end = chapStarts[m] - 1; break; }
      }
      drop.innerHTML = '';
      for(var s = start; s <= end; s++){
        (function(s){
          var it = document.createElement('button');
          it.type = 'button';
          it.textContent = (s + 1) + '. ' + slideTitle(slides[s]);
          if(s === i) it.classList.add('cur');
          it.addEventListener('click', function(){ go(s); drop.classList.remove('show'); });
          drop.appendChild(it);
        })(s);
      }
      drop.style.left = b.offsetLeft + 'px';
      drop.classList.add('show');
    });
  });
  chapnav.addEventListener('mouseleave', function(){ drop.classList.remove('show'); });

  function render(){
    slides.forEach(function(s, idx){ s.classList.toggle('active', idx===i); });
    dots.forEach(function(d, idx){ d.classList.toggle('on', idx===i); });
    curEl.textContent = i+1;
    progress.style.width = ((i)/(total-1)*100) + '%';
    // 현재 챕터 하이라이트: 시작 인덱스가 i 이하인 마지막 챕터
    var cur = -1;
    chapStarts.forEach(function(s, k){ if(s >= 0 && s <= i) cur = k; });
    chapBtns.forEach(function(b, k){ b.classList.toggle('on', k === cur); });
  }
  function go(n){ i = Math.max(0, Math.min(total-1, n)); render(); }
  function next(){ go(i+1); }
  function prev(){ go(i-1); }

  document.getElementById('next').addEventListener('click', next);
  document.getElementById('prev').addEventListener('click', prev);
  document.addEventListener('keydown', function(e){
    if(e.key==='ArrowRight' || e.key===' ' || e.key==='PageDown'){ e.preventDefault(); next(); }
    else if(e.key==='ArrowLeft' || e.key==='PageUp'){ e.preventDefault(); prev(); }
    else if(e.key==='Home'){ go(0); } else if(e.key==='End'){ go(total-1); }
    else if(e.key >= '1' && e.key <= '9'){           // 숫자키 = 챕터 점프
      var k = Number(e.key) - 1;
      if(chapStarts[k] !== undefined && chapStarts[k] >= 0) go(chapStarts[k]);
    }
  });

  // 터치 스와이프
  var x0=null;
  document.addEventListener('touchstart', function(e){ x0=e.touches[0].clientX; }, {passive:true});
  document.addEventListener('touchend', function(e){
    if(x0===null) return; var dx=e.changedTouches[0].clientX-x0;
    if(Math.abs(dx)>50){ dx<0?next():prev(); } x0=null;
  }, {passive:true});

  // "버그 찾기" 리빌 (3번 슬라이드)
  var bugBtn = document.getElementById('bugBtn');
  if(bugBtn){
    bugBtn.addEventListener('click', function(){
      document.getElementById('bugOut').classList.add('show');
      document.getElementById('bugline').classList.add('show');
      bugBtn.textContent = '🐛 age++ 가 매일 실행된다!';
      bugBtn.disabled = true; bugBtn.style.opacity = .8; bugBtn.style.cursor='default';
    });
  }

  // 바로가기: data-goto="#섹션id" → 해당 슬라이드로 점프 (슬라이드 4 카드·칩)
  document.querySelectorAll('[data-goto]').forEach(function(el){
    el.addEventListener('click', function(){
      var t = document.querySelector(el.getAttribute('data-goto'));
      var idx = slides.indexOf(t);
      if(idx >= 0) go(idx);
    });
  });

  // 클릭 리빌: data-reveal="#요소id" → 감춰둔 요소 표시 (슬라이드 2 등)
  document.querySelectorAll('[data-reveal]').forEach(function(btn){
    btn.addEventListener('click', function(){
      var t = document.querySelector(btn.getAttribute('data-reveal'));
      if(t){ t.classList.remove('reveal-hide'); t.classList.add('reveal-in'); }
      btn.style.display = 'none';
    });
  });

  // 테마 전환 (시스템 → light → dark 순환)
  var root = document.documentElement;
  var themeBtn = document.getElementById('themeBtn');
  themeBtn.addEventListener('click', function(){
    var cur = root.getAttribute('data-theme');
    var nextT = cur==='light' ? 'dark' : cur==='dark' ? '' : 'light';
    if(nextT) root.setAttribute('data-theme', nextT); else root.removeAttribute('data-theme');
  });

  render();
})();
