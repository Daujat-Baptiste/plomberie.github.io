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
