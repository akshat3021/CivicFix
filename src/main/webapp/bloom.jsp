<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>bloom — AI Floral Sculpting</title>
<link href="https://fonts.googleapis.com/css2?family=Poppins:ital,wght@0,300;0,400;0,500;0,600;0,700;1,400;1,500&family=Source+Serif+4:ital,opsz,wght@1,8..60,400;1,8..60,500;1,8..60,600&display=swap" rel="stylesheet">
<!-- Lucide Icons CDN -->
<script src="https://unpkg.com/lucide@latest"></script>
<style>
:root {
  --radius: 1rem;
  
  /* Grayscale only - 0 0% X% HSL values */
  --color-bg: hsl(0, 0%, 2%);
  --color-white: hsl(0, 0%, 100%);
  --color-white-80: hsla(0, 0%, 100%, 0.8);
  --color-white-60: hsla(0, 0%, 100%, 0.6);
  --color-white-50: hsla(0, 0%, 100%, 0.5);
  --color-white-15: hsla(0, 0%, 100%, 0.15);
  --color-white-10: hsla(0, 0%, 100%, 0.1);
  --color-white-05: hsla(0, 0%, 100%, 0.05);
  --color-black-05: hsla(0, 0%, 0%, 0.05);
}

* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  background-color: var(--color-bg);
  color: var(--color-white);
  font-family: 'Poppins', sans-serif;
  min-height: 100vh;
  overflow: hidden;
  position: relative;
}

/* Fullscreen autoplay video background */
.video-bg {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  object-fit: cover;
  z-index: 0;
  pointer-events: none;
}

/* Page wrapper floats above video */
.page-wrapper {
  position: relative;
  z-index: 10;
  min-height: 100vh;
  display: flex;
}

/* Liquid Glass CSS */
.liquid-glass {
  background: rgba(255, 255, 255, 0.01);
  background-blend-mode: luminosity;
  backdrop-filter: blur(4px);
  -webkit-backdrop-filter: blur(4px);
  border: none;
  box-shadow: inset 0 1px 1px rgba(255, 255, 255, 0.1);
  position: relative;
  overflow: hidden;
}
.liquid-glass::before {
  content: '';
  position: absolute;
  inset: 0;
  border-radius: inherit;
  padding: 1.4px;
  background: linear-gradient(180deg, 
    rgba(255, 255, 255, 0.45) 0%, 
    rgba(255, 255, 255, 0.15) 20%, 
    transparent 40%, 
    transparent 60%, 
    rgba(255, 255, 255, 0.15) 80%, 
    rgba(255, 255, 255, 0.45) 100%
  );
  -webkit-mask: linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0);
  -webkit-mask-composite: xor;
  mask-composite: exclude;
  pointer-events: none;
}

.liquid-glass-strong {
  background: rgba(255, 255, 255, 0.01);
  background-blend-mode: luminosity;
  backdrop-filter: blur(50px);
  -webkit-backdrop-filter: blur(50px);
  border: none;
  box-shadow: 4px 4px 4px var(--color-black-05), inset 0 1px 1px rgba(255, 255, 255, 0.15);
  position: relative;
  overflow: hidden;
}
.liquid-glass-strong::before {
  content: '';
  position: absolute;
  inset: 0;
  border-radius: inherit;
  padding: 1.4px;
  background: linear-gradient(180deg, 
    rgba(255, 255, 255, 0.5) 0%, 
    rgba(255, 255, 255, 0.2) 20%, 
    transparent 40%, 
    transparent 60%, 
    rgba(255, 255, 255, 0.2) 80%, 
    rgba(255, 255, 255, 0.5) 100%
  );
  -webkit-mask: linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0);
  -webkit-mask-composite: xor;
  mask-composite: exclude;
  pointer-events: none;
}

/* Two-Panel Split Layout */
.panel-left {
  flex: 0 0 52%;
  position: relative;
  height: 100vh;
  padding: 24px;
}
.panel-right {
  flex: 0 0 48%;
  display: flex;
  flex-direction: column;
  height: 100vh;
  padding: 24px 24px 24px 0;
}

/* Responsive Hide for Right Panel */
@media (max-width: 1024px) {
  .panel-left {
    flex: 0 0 100%;
  }
  .panel-right {
    display: none;
  }
}

/* Inner Left Card styling */
.left-card-inner {
  position: absolute;
  inset: 24px;
  border-radius: 24px; /* rounded-3xl */
  padding: 32px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}

/* Fonts and Typographic Hierarchy */
h1 {
  font-family: 'Poppins', sans-serif;
  font-size: 4rem;
  font-weight: 500;
  line-height: 1.05;
  letter-spacing: -0.05em;
  color: var(--color-white);
  margin-bottom: 24px;
}
h1 em {
  font-family: 'Source Serif 4', serif;
  font-style: italic;
  color: var(--color-white-80);
  font-weight: 400;
}

.text-xs { font-size: 12px; }
.text-sm { font-size: 14px; }
.text-2xl { font-size: 24px; }
.tracking-widest { letter-spacing: 0.15em; }
.tracking-tighter { letter-spacing: -0.05em; }
.font-serif { font-family: 'Source Serif 4', serif; }
.font-semibold { font-weight: 600; }
.uppercase { text-transform: uppercase; }

/* Interactive transitions */
.hover-scale {
  transition: transform 0.2s ease;
}
.hover-scale:hover {
  transform: scale(1.05);
}
.hover-scale:active {
  transform: scale(0.95);
}

.social-link {
  color: var(--color-white);
  transition: color 0.2s ease;
}
.social-link:hover {
  color: var(--color-white-80);
}

/* Navigation items */
.navbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.nav-logo-wrap {
  display: flex;
  align-items: center;
  gap: 10px;
}
.logo-img {
  width: 32px;
  height: 32px;
  border-radius: 8px;
  object-fit: cover;
}
.menu-pill {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 18px;
  border-radius: 20px;
  font-size: 13px;
  font-weight: 500;
  cursor: pointer;
}

/* Hero Center elements */
.hero-center {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: flex-start;
  max-width: 520px;
}
.hero-logo-large {
  width: 80px;
  height: 80px;
  border-radius: 20px;
  margin-bottom: 24px;
  object-fit: cover;
  box-shadow: 0 10px 30px rgba(0,0,0,0.3);
}
.cta-btn {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 10px 24px 10px 14px;
  border-radius: 30px;
  cursor: pointer;
  margin-bottom: 32px;
  text-decoration: none;
  color: #fff;
  font-weight: 500;
  font-size: 14px;
}
.icon-circle {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: var(--color-white-15);
  display: flex;
  align-items: center;
  justify-content: center;
}
.pills-row {
  display: flex;
  gap: 10px;
}
.pill {
  padding: 6px 14px;
  border-radius: 20px;
  font-size: 11.5px;
  font-weight: 500;
  color: var(--color-white-80);
}

/* Bottom quote styling */
.bottom-quote-wrap {
  border-top: 1px solid rgba(255, 255, 255, 0.05);
  padding-top: 20px;
}
.quote-text {
  font-size: 18px;
  font-weight: 400;
  line-height: 1.4;
  color: var(--color-white-80);
  margin: 6px 0 12px;
}
.quote-text em {
  font-family: 'Source Serif 4', serif;
  font-style: italic;
}
.quote-author-row {
  display: flex;
  align-items: center;
  gap: 12px;
  font-size: 10px;
  font-weight: 600;
  letter-spacing: 0.2em;
  color: var(--color-white-50);
}
.quote-line {
  flex: 1;
  height: 1px;
  background: rgba(255, 255, 255, 0.1);
}

/* RIGHT PANEL: DESKTOP ONLY */
.right-header {
  display: flex;
  justify-content: flex-end;
  align-items: center;
  gap: 12px;
  margin-bottom: auto;
}
.social-pill {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 8px 18px;
  border-radius: 20px;
}
.account-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 40px;
  height: 40px;
  border-radius: 50%;
  cursor: pointer;
}

/* Community card layout */
.community-card {
  width: 240px;
  border-radius: 16px;
  padding: 16px;
  margin-top: 40px;
  display: flex;
  flex-direction: column;
  gap: 8px;
  align-self: flex-end;
}
.community-title {
  font-size: 13.5px;
  font-weight: 600;
}
.community-desc {
  font-size: 11px;
  color: var(--color-white-60);
  line-height: 1.5;
}

/* Bottom Feature Section */
.bottom-feature-container {
  margin-top: auto;
  border-radius: 2.5rem; /* rounded-[2.5rem] */
  padding: 20px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}
.feature-split-row {
  display: flex;
  gap: 16px;
}
.feature-small-card {
  flex: 1;
  border-radius: 24px; /* rounded-3xl */
  padding: 20px;
  display: flex;
  flex-direction: column;
  gap: 10px;
  cursor: pointer;
}
.icon-wrap-medium {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  background: var(--color-white-10);
  display: flex;
  align-items: center;
  justify-content: center;
}
.feature-card-title {
  font-size: 14px;
  font-weight: 600;
}

/* Bottom Large Card */
.feature-large-card {
  border-radius: 24px; /* rounded-3xl */
  padding: 16px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
}
.feature-img-wrap {
  width: 96px;
  height: 64px;
  border-radius: 12px;
  overflow: hidden;
  flex-shrink: 0;
  border: 1px solid rgba(255,255,255,0.05);
}
.feature-thumb-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}
.feature-details {
  flex: 1;
}
.feature-large-title {
  font-size: 13.5px;
  font-weight: 600;
}
.feature-large-desc {
  font-size: 11px;
  color: var(--color-white-60);
  margin-top: 2px;
}
.plus-icon-btn {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
}
</style>
</head>
<body>

<!-- AUTOPLAYING VIDEOS BACKGROUND -->
<video class="video-bg" autoplay loop muted playsinline>
  <source src="https://d8j0ntlcm91z4.cloudfront.net/user_38xzZboKViGWJOttwIXH07lWA1P/hf_20260315_073750_51473149-4350-4920-ae24-c8214286f323.mp4" type="video/mp4">
</video>

<div class="page-wrapper">
  <!-- LEFT PANEL: 52% WIDTH -->
  <div class="panel-left">
    <div class="left-card-inner liquid-glass-strong">
      <!-- Navbar row -->
      <div class="navbar">
        <div class="nav-logo-wrap">
          <img src="uploads/bloom_logo.png" class="logo-img" alt="bloom logo">
          <span class="text-2xl font-semibold tracking-tighter">bloom</span>
        </div>
        <div class="menu-pill liquid-glass hover-scale">
          <span>Menu</span>
          <i data-lucide="menu" style="width: 16px; height: 16px;"></i>
        </div>
      </div>

      <!-- Hero Center -->
      <div class="hero-center">
        <img src="uploads/bloom_logo.png" class="hero-logo-large" alt="bloom logo large">
        <h1>Innovating the<br><em>spirit of bloom</em> AI</h1>
        
        <a href="#" class="cta-btn liquid-glass-strong hover-scale">
          <div class="icon-circle">
            <i data-lucide="download" style="width: 15px; height: 15px;"></i>
          </div>
          <span>Explore Now</span>
        </a>
        
        <div class="pills-row">
          <div class="pill liquid-glass">Artistic Gallery</div>
          <div class="pill liquid-glass">AI Generation</div>
          <div class="pill liquid-glass">3D Structures</div>
        </div>
      </div>

      <!-- Bottom Quote -->
      <div class="bottom-quote-wrap">
        <div class="text-xs tracking-widest uppercase" style="color: var(--color-white-50); font-weight: 600;">Visionary Design</div>
        <div class="quote-text">
          "We imagined a <em>realm</em> with <em>no ending</em>."
        </div>
        <div class="quote-author-row">
          <div class="quote-line"></div>
          <span>MARCUS AURELIO</span>
          <div class="quote-line"></div>
        </div>
      </div>
    </div>
  </div>

  <!-- RIGHT PANEL: 48% WIDTH (DESKTOP ONLY) -->
  <div class="panel-right">
    <!-- Header: Social & Account row -->
    <div class="right-header">
      <div class="social-pill liquid-glass">
        <a href="#" class="social-link"><i data-lucide="twitter" style="width: 15px; height: 15px;"></i></a>
        <a href="#" class="social-link"><i data-lucide="linkedin" style="width: 15px; height: 15px;"></i></a>
        <a href="#" class="social-link"><i data-lucide="instagram" style="width: 15px; height: 15px;"></i></a>
        <a href="#" class="social-link" style="margin-left: 4px;"><i data-lucide="arrow-right" style="width: 15px; height: 15px;"></i></a>
      </div>
      <div class="account-btn liquid-glass hover-scale">
        <i data-lucide="sparkles" style="width: 16px; height: 16px;"></i>
      </div>
    </div>

    <!-- Community Ecosystem Card -->
    <div class="community-card liquid-glass hover-scale">
      <div class="community-title">Enter our ecosystem</div>
      <div class="community-desc">Connect with digital horticulturists and generate plant structures using procedural nodes.</div>
    </div>

    <!-- Bottom Feature section container -->
    <div class="bottom-feature-container liquid-glass">
      <div class="feature-split-row">
        <!-- Card 1: Processing -->
        <div class="feature-small-card liquid-glass hover-scale">
          <div class="icon-wrap-medium">
            <i data-lucide="wand-2" style="width: 16px; height: 16px;"></i>
          </div>
          <div class="feature-card-title">Processing</div>
        </div>
        <!-- Card 2: Growth Archive -->
        <div class="feature-small-card liquid-glass hover-scale">
          <div class="icon-wrap-medium">
            <i data-lucide="book-open" style="width: 16px; height: 16px;"></i>
          </div>
          <div class="feature-card-title">Growth Archive</div>
        </div>
      </div>

      <!-- Large feature card at bottom -->
      <div class="feature-large-card liquid-glass hover-scale">
        <div class="feature-img-wrap">
          <img src="uploads/bloom_flowers.png" class="feature-thumb-img" alt="Plant Sculpting preview">
        </div>
        <div class="feature-details">
          <div class="feature-large-title">Advanced Plant Sculpting</div>
          <div class="feature-large-desc">Refining generative models with real-time foliage constraints.</div>
        </div>
        <div class="plus-icon-btn liquid-glass hover-scale">
          <span style="font-size: 20px; font-weight: 500; line-height: 1;">+</span>
        </div>
      </div>
    </div>
  </div>
</div>

<script>
// Initialize Lucide icons if available
if (typeof lucide !== 'undefined') {
  try {
    lucide.createIcons();
  } catch (e) {
    console.error("Lucide icon generation failed:", e);
  }
}
</script>
</body>
</html>
