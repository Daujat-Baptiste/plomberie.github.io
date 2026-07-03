// Nav scroll
const nav = document.getElementById('nav');
window.addEventListener('scroll', () => {
  nav.classList.toggle('on', window.scrollY > 30);
}, { passive: true });

// Burger
const burger = document.getElementById('burger');
const drawer = document.getElementById('drawer');
burger.addEventListener('click', () => {
  const open = burger.classList.toggle('on');
  drawer.classList.toggle('on', open);
  document.body.style.overflow = open ? 'hidden' : '';
});
drawer.querySelectorAll('a').forEach(a => {
  a.addEventListener('click', () => {
    burger.classList.remove('on');
    drawer.classList.remove('on');
    document.body.style.overflow = '';
  });
});

// Reveal
const obs = new IntersectionObserver(entries => {
  entries.forEach(e => {
    if (e.isIntersecting) { e.target.classList.add('in'); obs.unobserve(e.target); }
  });
}, { threshold: 0.1 });
document.querySelectorAll('.rv').forEach(el => obs.observe(el));

// Copie email / téléphone avec confirmation visuelle
async function copyText(text) {
  if (navigator.clipboard && window.isSecureContext) {
    try { await navigator.clipboard.writeText(text); return true; } catch (e) {}
  }
  // Repli pour contextes non sécurisés / anciens navigateurs
  const ta = document.createElement('textarea');
  ta.value = text;
  ta.style.position = 'fixed';
  ta.style.opacity = '0';
  document.body.appendChild(ta);
  ta.select();
  let ok = false;
  try { ok = document.execCommand('copy'); } catch (e) {}
  document.body.removeChild(ta);
  return ok;
}

document.querySelectorAll('.channel-copy').forEach(btn => {
  const label = btn.querySelector('.channel-copy-text');
  const original = label ? label.textContent : '';
  btn.addEventListener('click', async () => {
    const ok = await copyText(btn.dataset.copy);
    if (!ok) return;
    btn.classList.add('copied');
    if (label) label.textContent = 'Copié !';
    clearTimeout(btn._t);
    btn._t = setTimeout(() => {
      btn.classList.remove('copied');
      if (label) label.textContent = original;
    }, 2000);
  });
});
