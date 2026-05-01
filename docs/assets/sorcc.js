/* SORCC Jetson Handoff — site JS
   Vanilla, no build. Handles:
   - theme toggle (light/dark, persists)
   - per-step + per-section progress (localStorage)
   - copy buttons on .term blocks (COPIED morph for 1.5s)
   - active rail link from current path
   - resume strip on landing
*/
(function () {
  'use strict';

  var STORAGE_THEME = 'sorcc.theme';
  var STORAGE_PROGRESS = 'sorcc.progress.v1';
  var STORAGE_LAST = 'sorcc.lastvisit';

  // ── Theme ──────────────────────────────────────────────────
  function applyTheme(t) {
    document.documentElement.setAttribute('data-theme', t);
    var btn = document.querySelector('[data-theme-toggle]');
    if (btn) btn.textContent = t === 'dark' ? 'Light' : 'Dark';
  }
  function initTheme() {
    var saved = localStorage.getItem(STORAGE_THEME);
    var prefDark = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
    applyTheme(saved || (prefDark ? 'dark' : 'light'));
    document.addEventListener('click', function (e) {
      var btn = e.target.closest('[data-theme-toggle]');
      if (!btn) return;
      var cur = document.documentElement.getAttribute('data-theme') || 'light';
      var next = cur === 'dark' ? 'light' : 'dark';
      localStorage.setItem(STORAGE_THEME, next);
      applyTheme(next);
    });
  }

  // ── Progress ───────────────────────────────────────────────
  function getProgress() {
    try { return JSON.parse(localStorage.getItem(STORAGE_PROGRESS) || '{}'); }
    catch (e) { return {}; }
  }
  function setProgress(p) { localStorage.setItem(STORAGE_PROGRESS, JSON.stringify(p)); }

  function initStepCheckboxes() {
    var p = getProgress();
    document.querySelectorAll('input[data-step-key]').forEach(function (el) {
      var k = el.getAttribute('data-step-key');
      el.checked = !!p[k];
      el.addEventListener('change', function () {
        var pp = getProgress();
        if (el.checked) pp[k] = Date.now();
        else delete pp[k];
        setProgress(pp);
        updateRailProgress();
      });
    });
  }

  function updateRailProgress() {
    var rail = document.querySelector('[data-rail-progress]');
    if (!rail) return;
    var keys = (rail.getAttribute('data-rail-progress') || '').split(',').filter(Boolean);
    if (!keys.length) return;
    var p = getProgress();
    var done = keys.filter(function (k) { return !!p[k]; }).length;
    var pct = Math.round((done / keys.length) * 100);
    var fill = rail.querySelector('.rail__progress-fill');
    var label = rail.querySelector('.rail__progress-label');
    if (fill) fill.style.width = pct + '%';
    if (label) label.textContent = done + ' / ' + keys.length + ' STEPS';
  }

  // ── Copy buttons on terminal blocks ────────────────────────
  function initCopyButtons() {
    document.querySelectorAll('.term').forEach(function (term) {
      var btn = term.querySelector('.term__copy');
      var body = term.querySelector('.term__body');
      if (!btn || !body) return;
      btn.addEventListener('click', function () {
        // Strip prompt markers when copying
        var clones = body.cloneNode(true);
        clones.querySelectorAll('.prompt, .comment').forEach(function (n) { n.remove(); });
        var txt = (clones.textContent || '').replace(/\n+/g, '\n').replace(/^\s+|\s+$/g, '');
        // Fallback: full text minus leading $
        if (!txt) txt = body.textContent || '';
        navigator.clipboard.writeText(txt).then(function () {
          var orig = btn.textContent;
          btn.textContent = 'Copied';
          btn.classList.add('is-copied');
          setTimeout(function () {
            btn.textContent = orig || 'Copy';
            btn.classList.remove('is-copied');
          }, 1500);
        }).catch(function () {
          btn.textContent = 'Press Ctrl+C';
          setTimeout(function () { btn.textContent = 'Copy'; }, 1500);
        });
      });
    });
  }

  // ── Active rail link ───────────────────────────────────────
  function initActiveRail() {
    var here = location.pathname.replace(/\/$/, '').split('/').pop() || 'index.html';
    document.querySelectorAll('.rail a[href]').forEach(function (a) {
      var hrefFile = a.getAttribute('href').replace(/\/$/, '').split('/').pop();
      if (hrefFile === here) a.classList.add('is-active');
    });
  }

  // ── Mark visit (for "Resume" hint on landing) ──────────────
  function recordVisit() {
    var label = document.body.getAttribute('data-resume-label');
    var href = document.body.getAttribute('data-resume-href');
    if (!label || !href) return;
    localStorage.setItem(STORAGE_LAST, JSON.stringify({
      label: label, href: href, ts: Date.now(),
    }));
  }

  function showResume() {
    var slot = document.querySelector('[data-resume-slot]');
    if (!slot) return;
    var raw = localStorage.getItem(STORAGE_LAST);
    if (!raw) { slot.style.display = 'none'; return; }
    try {
      var v = JSON.parse(raw);
      var titleEl = slot.querySelector('[data-resume-title]');
      var btn = slot.querySelector('[data-resume-link]');
      if (titleEl) titleEl.textContent = v.label;
      if (btn) btn.setAttribute('href', v.href);
      // Days ago hint
      var sub = slot.querySelector('[data-resume-sub]');
      if (sub) {
        var p = getProgress();
        var done = Object.keys(p).length;
        var days = Math.floor((Date.now() - v.ts) / 86400000);
        var when = days === 0 ? 'today' : days === 1 ? 'yesterday' : days + ' days ago';
        sub.textContent = done + ' steps complete · last opened ' + when + '.';
      }
    } catch (e) { slot.style.display = 'none'; }
  }

  // ── Paste-in router ────────────────────────────────────────
  // Pattern matchers for common failure outputs. Each rule returns
  // a match object if its pattern fires.
  var ROUTER_RULES = [
    // Preflight script outputs
    {
      pattern: /FAIL\s+nvidia-container-toolkit/i,
      tag: 'PREFLIGHT',
      title: 'nvidia-container-toolkit missing',
      href: '02-base-system/01-base-bootstrap.html',
      why: 'The base bootstrap script installs <code>nvidia-container-toolkit</code> and configures Docker for GPU access. Run <code>02-base-system/01-base-bootstrap.sh</code>.',
    },
    {
      pattern: /FAIL\s+(power[_\s]?mode|MAXN)/i,
      tag: 'PREFLIGHT',
      title: 'Power mode is not MAXN_SUPER',
      href: '00-prep/02-power-and-cooling.html',
      why: 'Run <code>sudo nvpmodel -m 0</code> then <code>sudo jetson_clocks</code>. Verify with <code>nvpmodel -q</code>.',
    },
    {
      pattern: /FAIL\s+(jetpack|L4T|R36)/i,
      tag: 'PREFLIGHT',
      title: 'Wrong JetPack version detected',
      href: '01-flash-and-update/index.html',
      why: 'You need JetPack 6.x (L4T R36.4.x). Walk through Section 01 to flash the QSPI and lay down the correct OS.',
    },
    // QSPI / flashing failures
    {
      pattern: /Unable to locate package nvidia-l4t-jetson-orin-nano-qspi-updater/i,
      tag: 'APT',
      title: 'QSPI updater package not found',
      href: '01-flash-and-update/troubleshooting.html#apt-no-qspi-package',
      why: 'JetPack 5.1.3 SD must be running and apt sources must include the L4T repos. Boot the JP 5.1.3 card first, then re-run apt update before installing.',
    },
    {
      pattern: /(board did not halt|did not reach the halt|halt.*not.*detected)/i,
      tag: 'QSPI',
      title: 'Board never reached the halt state',
      href: '01-flash-and-update/01-qspi-update.html',
      why: 'The QSPI updater needs to see a clean halt before you proceed. Power-cycle, reseat the SD card, and try a different USB-C supply if it persists.',
    },
    {
      pattern: /tegra-i2c.*no acknowledge from address/i,
      tag: 'I2C',
      title: 'I2C device not acknowledging',
      href: '03-hardware/02-i2c-bus.html',
      why: 'Pin 3/5 wiring, missing pull-ups, or wrong bus number. Check the 40-pin pinout and verify with <code>i2cdetect -y -r 1</code>.',
    },
    {
      pattern: /pca9685.*failed to read register/i,
      tag: 'I2C',
      title: 'PCA9685 PWM driver cannot read',
      href: '03-hardware/03-pwm-pca9685.html',
      why: 'Almost always wiring or address. Default address is <code>0x40</code>. If you bridged A0–A5, recompute and update the device-tree overlay.',
    },
    // Docker / runtime
    {
      pattern: /could not select device driver.*nvidia.*capabilities/i,
      tag: 'DOCKER',
      title: 'NVIDIA runtime not registered with Docker',
      href: '02-base-system/02-docker-gpu.html',
      why: 'Run <code>sudo nvidia-ctk runtime configure --runtime=docker</code> then restart the daemon: <code>sudo systemctl restart docker</code>.',
    },
    {
      pattern: /docker:.*permission denied.*\/var\/run\/docker\.sock/i,
      tag: 'DOCKER',
      title: 'User not in the docker group',
      href: '02-base-system/01-base-bootstrap.html#docker-group',
      why: '<code>sudo usermod -aG docker $USER</code> then log out and back in. <code>newgrp docker</code> works for the current shell.',
    },
    // Boot / first-run
    {
      pattern: /(boots straight into JP\s*6|skipped.*halt|JP6 without halting)/i,
      tag: 'BOOT',
      title: 'Board booted JP6 without halting',
      href: '01-flash-and-update/troubleshooting.html#boots-without-halt',
      why: 'The QSPI was not actually updated. Re-flash the QSPI updater SD with <code>--reinstall</code> and verify the halt before continuing.',
    },
    {
      pattern: /(out of memory|killed.*oom|OOM)/i,
      tag: 'MEMORY',
      title: 'Out-of-memory during build or run',
      href: '02-base-system/03-swap-and-zram.html',
      why: 'The 8GB Orin Nano needs swap configured for most CV workloads. Add 8GB of swap and disable zram for build-heavy tasks.',
    },
    // Generic apt errors
    {
      pattern: /E:\s*Unable to locate package/i,
      tag: 'APT',
      title: 'apt cannot find a package',
      href: '02-base-system/01-base-bootstrap.html',
      why: 'Run <code>sudo apt update</code> first. If still missing, check that the L4T sources are configured for R36.4.x.',
    },
  ];

  function escapeHtml(s) {
    return String(s).replace(/[&<>"']/g, function (c) {
      return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c];
    });
  }

  function runRouter() {
    var input = document.getElementById('router-input');
    var out = document.querySelector('[data-router-results]');
    if (!input || !out) return;
    var text = (input.value || '').trim();
    out.innerHTML = '';
    if (!text) {
      out.innerHTML = '<p class="router__none">Paste something first.</p>';
      return;
    }
    var hits = ROUTER_RULES.filter(function (r) { return r.pattern.test(text); });
    if (!hits.length) {
      out.innerHTML = '<p class="router__none">No known signature in that snippet. Try the <a href="troubleshooting.html">troubleshooting search</a> or open the section that matches your phase.</p>';
      return;
    }
    hits.forEach(function (h, i) {
      var div = document.createElement('div');
      div.className = 'router__match' + (i === 0 ? ' router__match--top' : '');
      div.innerHTML =
        '<div class="router__match-head">' +
          '<span class="router__match-tag">' + (i === 0 ? 'GO HERE → ' : '') + escapeHtml(h.tag) + '</span>' +
          '<span class="router__match-title"><a href="' + h.href + '">' + escapeHtml(h.title) + '</a></span>' +
        '</div>' +
        '<p class="router__match-why">' + h.why + '</p>';
      out.appendChild(div);
    });
  }

  function initRouter() {
    var go = document.querySelector('[data-router-go]');
    var clear = document.querySelector('[data-router-clear]');
    var input = document.getElementById('router-input');
    if (go) go.addEventListener('click', runRouter);
    if (clear) clear.addEventListener('click', function () {
      if (input) input.value = '';
      var out = document.querySelector('[data-router-results]');
      if (out) out.innerHTML = '';
    });
    if (input) {
      input.addEventListener('keydown', function (e) {
        if ((e.ctrlKey || e.metaKey) && e.key === 'Enter') {
          e.preventDefault();
          runRouter();
        }
      });
    }
  }

  // ── Init ───────────────────────────────────────────────────
  function init() {
    initTheme();
    initCopyButtons();
    initStepCheckboxes();
    updateRailProgress();
    initActiveRail();
    recordVisit();
    showResume();
    initRouter();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
