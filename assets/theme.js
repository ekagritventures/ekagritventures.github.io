(function() {
  var root = document.documentElement;
  var btn = document.getElementById('theme-toggle');
  if (!btn) return;

  function applyTheme(theme) {
    if (theme === 'dark') {
      root.classList.add('theme-dark');
      btn.setAttribute('data-theme', 'dark');
    } else {
      root.classList.remove('theme-dark');
      btn.setAttribute('data-theme', 'light');
    }
  }

  var saved = localStorage.getItem('theme');
  if (saved) {
    applyTheme(saved);
  } else {
    var prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
    applyTheme(prefersDark ? 'dark' : 'light');
  }

  btn.addEventListener('click', function() {
    var current = btn.getAttribute('data-theme') === 'dark' ? 'dark' : 'light';
    var next = current === 'dark' ? 'light' : 'dark';
    applyTheme(next);
    localStorage.setItem('theme', next);
  });
})();