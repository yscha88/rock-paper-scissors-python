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

  function render(){
    slides.forEach(function(s, idx){ s.classList.toggle('active', idx===i); });
    dots.forEach(function(d, idx){ d.classList.toggle('on', idx===i); });
    curEl.textContent = i+1;
    progress.style.width = ((i)/(total-1)*100) + '%';
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
