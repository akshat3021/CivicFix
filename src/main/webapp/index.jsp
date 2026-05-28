<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List, com.civicfix.model.Complaint, com.civicfix.dao.ComplaintDAO" %>
<%
    // Load recent complaints to showcase on landing page
    List<Complaint> recentComplaints = ComplaintDAO.getAllComplaints();
    int totalCount = recentComplaints != null ? recentComplaints.size() : 0;
    int resolvedCount = 0;
    if (recentComplaints != null) {
        for (Complaint c : recentComplaints) {
            if ("CLOSED".equals(c.getStatus())) resolvedCount++;
        }
    }
    int activeCount = totalCount - resolvedCount;
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>CivicFix — Smart City Command Hub</title>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&family=Space+Grotesk:wght@400;500;600;700;800&display=swap" rel="stylesheet">
<!-- Lucide Icons CDN -->
<script src="https://unpkg.com/lucide@latest"></script>
<style>
:root {
  --radius: 1.25rem;
  --bg-dark: #070d0a;
  --panel-bg: rgba(13, 20, 16, 0.65);
  --border-color: rgba(255, 255, 255, 0.08);
  
  --primary: #10B981;
  --primary-glow: rgba(16, 185, 129, 0.25);
  --accent: #34D399;
  --accent-glow: rgba(52, 211, 153, 0.25);
  --magenta: #FFD700;
  --secondary: #059669;
  --success: #10B981;
  --danger: #EF4444;
  --warn: #F59E0B;
  
  --text-main: #f3f4f6;
  --text-muted: rgba(255, 255, 255, 0.7);
  --text-dim: rgba(255, 255, 255, 0.45);
}

* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  background: var(--bg-dark);
  color: var(--text-main);
  font-family: 'Inter', sans-serif;
  min-height: 100vh;
  overflow-x: hidden;
  position: relative;
}

/* Connected nodes HTML5 canvas */
#network-canvas {
  position: fixed;
  inset: 0;
  width: 100%;
  height: 100%;
  z-index: 0;
  pointer-events: none;
}

/* Subtle grid overlay */
.blueprint-grid {
  position: fixed;
  inset: 0;
  background-image: 
    linear-gradient(rgba(52, 211, 153, 0.015) 1px, transparent 1px),
    linear-gradient(90deg, rgba(52, 211, 153, 0.015) 1px, transparent 1px);
  background-size: 60px 60px;
  background-position: center;
  z-index: 1;
  pointer-events: none;
}

/* Liquid Glass CSS */
.liquid-glass {
  background: rgba(255, 255, 255, 0.01);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  border: none;
  box-shadow: inset 0 1px 1px rgba(255, 255, 255, 0.08);
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
    rgba(52, 211, 153, 0.35) 0%, 
    rgba(16, 185, 129, 0.15) 25%, 
    transparent 50%, 
    rgba(16, 185, 129, 0.15) 75%, 
    rgba(52, 211, 153, 0.35) 100%
  );
  -webkit-mask: linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0);
  -webkit-mask-composite: xor;
  mask-composite: exclude;
  pointer-events: none;
}

.liquid-glass-strong {
  background: rgba(17, 24, 39, 0.45);
  backdrop-filter: blur(40px);
  -webkit-backdrop-filter: blur(40px);
  border: none;
  box-shadow: 4px 4px 15px rgba(0, 0, 0, 0.25), inset 0 1px 1px rgba(255, 255, 255, 0.12);
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
    rgba(52, 211, 153, 0.45) 0%, 
    rgba(16, 185, 129, 0.2) 20%, 
    transparent 50%, 
    rgba(16, 185, 129, 0.2) 80%, 
    rgba(52, 211, 153, 0.45) 100%
  );
  -webkit-mask: linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0);
  -webkit-mask-composite: xor;
  mask-composite: exclude;
  pointer-events: none;
}

.page-wrapper {
  position: relative;
  z-index: 10;
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

/* Header Navbar */
.topbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 32px;
  height: 72px;
  margin: 16px 24px 0;
  border-radius: 20px;
}
.logo-wrap {
  display: flex;
  align-items: center;
  gap: 12px;
  text-decoration: none;
  color: #fff;
}
.logo-icon {
  width: 30px;
  height: 30px;
  border-radius: 8px;
  background: linear-gradient(135deg, var(--accent) 0%, var(--primary) 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 0 15px var(--accent-glow);
}
.logo-text {
  font-family: 'Space Grotesk', sans-serif;
  font-size: 22px;
  font-weight: 800;
  letter-spacing: -1.5px;
}
.logo-text span {
  background: linear-gradient(135deg, var(--accent) 30%, #fff 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}
.nav-links {
  display: flex;
  gap: 8px;
}
.nav-link {
  font-size: 13px;
  font-weight: 600;
  padding: 8px 18px;
  color: var(--text-muted);
  text-decoration: none;
  border-radius: 12px;
  transition: all 0.2s;
}
.nav-link:hover {
  color: #fff;
  background: rgba(255, 255, 255, 0.02);
}
.portal-btn {
  background: var(--primary);
  color: #fff;
  border: 1px solid rgba(16, 185, 129, 0.3);
  box-shadow: 0 4px 15px var(--primary-glow);
}
.portal-btn:hover {
  background: var(--secondary);
  box-shadow: 0 6px 20px rgba(16, 185, 129, 0.45);
}

/* Hero Section Split Layout */
.hero-container {
  max-width: 1200px;
  width: 100%;
  margin: 0 auto;
  padding: 48px 24px;
  display: grid;
  grid-template-columns: 52% 48%;
  gap: 32px;
  align-items: center;
  flex: 1;
}

@media (max-width: 1024px) {
  .hero-container {
    grid-template-columns: 1fr;
    text-align: center;
  }
}

.hero-left {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
}
@media (max-width: 1024px) {
  .hero-left {
    align-items: center;
  }
}

.hero-badge {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  font-size: 11px;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.1em;
  color: var(--accent);
  background: rgba(52, 211, 153, 0.08);
  padding: 6px 16px;
  border-radius: 20px;
  margin-bottom: 24px;
  border: 1px solid rgba(52, 211, 153, 0.15);
}
.hero-title {
  font-family: 'Space Grotesk', sans-serif;
  font-size: 52px;
  font-weight: 800;
  line-height: 1.05;
  letter-spacing: -2px;
  color: #fff;
  margin-bottom: 16px;
}
.hero-title span {
  background: linear-gradient(135deg, var(--accent) 30%, var(--primary) 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}
.hero-sub {
  font-size: 15px;
  line-height: 1.6;
  color: var(--text-muted);
  margin-bottom: 36px;
  max-width: 480px;
}
.cta-row {
  display: flex;
  gap: 16px;
  margin-bottom: 48px;
}
.btn-cta {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 14px 28px;
  border-radius: 14px;
  font-size: 14px;
  font-weight: 700;
  cursor: pointer;
  text-decoration: none;
  transition: all 0.3s ease;
}
.btn-cta-primary {
  background: var(--accent);
  color: #070d0a;
  box-shadow: 0 8px 25px var(--accent-glow);
}
.btn-cta-primary:hover {
  background: #6ee7b7;
  box-shadow: 0 10px 30px rgba(52, 211, 153, 0.4);
  transform: translateY(-2px);
}
.btn-cta-secondary {
  background: rgba(255, 255, 255, 0.02);
  border: 1px solid var(--border-color);
  color: #fff;
}
.btn-cta-secondary:hover {
  background: rgba(255, 255, 255, 0.05);
  border-color: rgba(255, 255, 255, 0.15);
  transform: translateY(-2px);
}

/* Stats Counter Row */
.stats-row {
  display: flex;
  gap: 40px;
  border-top: 1px solid rgba(255, 255, 255, 0.05);
  padding-top: 28px;
  width: 100%;
}
@media (max-width: 1024px) {
  .stats-row {
    justify-content: center;
  }
}
.stat-item {
  display: flex;
  flex-direction: column;
}
.stat-number {
  font-family: 'Space Grotesk', sans-serif;
  font-size: 38px;
  font-weight: 700;
  color: #fff;
  line-height: 1;
}
.stat-lbl {
  font-size: 11px;
  font-weight: 600;
  color: var(--text-dim);
  text-transform: uppercase;
  letter-spacing: 0.1em;
  margin-top: 6px;
}

/* HERO RIGHT: INTERACTIVE MAP COMPONENT */
.hero-right {
  display: flex;
  justify-content: center;
  align-items: center;
}
.map-canvas-card {
  width: 100%;
  max-width: 480px;
  height: 400px;
  border-radius: 28px;
  padding: 24px;
  position: relative;
  display: flex;
  flex-direction: column;
}
.map-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}
.map-title {
  font-family: 'Space Grotesk', sans-serif;
  font-size: 14px;
  font-weight: 600;
  color: #fff;
  letter-spacing: -0.3px;
  display: flex;
  align-items: center;
  gap: 8px;
}
.live-indicator {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 10px;
  font-weight: 700;
  color: var(--success);
  text-transform: uppercase;
}
.live-dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: var(--success);
  animation: pulseDot 1.5s infinite;
}
@keyframes pulseDot {
  0% { transform: scale(0.9); opacity: 0.7; }
  50% { transform: scale(1.35); opacity: 1; }
  100% { transform: scale(0.9); opacity: 0.7; }
}

.map-container {
  flex: 1;
  background: rgba(5, 8, 20, 0.4);
  border: 1px solid rgba(255, 255, 255, 0.04);
  border-radius: 20px;
  position: relative;
  overflow: hidden;
}

/* Interactive SVG Map */
.svg-city-grid {
  width: 100%;
  height: 100%;
  stroke: rgba(0, 212, 255, 0.08);
  stroke-width: 1.5;
  fill: none;
}
.map-road {
  stroke: rgba(0, 212, 255, 0.12);
  stroke-width: 2.5;
}

/* Glowing Pulsing Pins */
.map-pin {
  cursor: pointer;
  position: absolute;
}
.pin-core {
  width: 10px;
  height: 10px;
  border-radius: 50%;
  position: absolute;
  transform: translate(-50%, -50%);
}
.pin-glowing-ring {
  width: 24px;
  height: 24px;
  border-radius: 50%;
  border: 2px solid;
  position: absolute;
  transform: translate(-50%, -50%);
  animation: pinPulse 2s infinite ease-out;
  opacity: 0;
}

@keyframes pinPulse {
  0% { transform: translate(-50%, -50%) scale(0.5); opacity: 1; }
  100% { transform: translate(-50%, -50%) scale(1.6); opacity: 0; }
}

.pin-danger .pin-core { background: var(--danger); box-shadow: 0 0 10px var(--danger); }
.pin-danger .pin-glowing-ring { border-color: var(--danger); }

.pin-warn .pin-core { background: var(--warn); box-shadow: 0 0 10px var(--warn); }
.pin-warn .pin-glowing-ring { border-color: var(--warn); }

.pin-primary .pin-core { background: var(--accent); box-shadow: 0 0 10px var(--accent); }
.pin-primary .pin-glowing-ring { border-color: var(--accent); }

/* Custom floating map overlay card */
.map-card-popup {
  position: absolute;
  bottom: 16px;
  left: 16px;
  right: 16px;
  padding: 14px 18px;
  border-radius: 14px;
  display: none;
  animation: slideUp 0.3s cubic-bezier(0.16, 1, 0.3, 1) both;
}
.popup-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 4px;
}
.popup-title {
  font-size: 13.5px;
  font-weight: 700;
}
.popup-meta {
  font-size: 10px;
  font-weight: 700;
  text-transform: uppercase;
}
.popup-desc {
  font-size: 11px;
  color: var(--text-muted);
  line-height: 1.4;
}

/* Scroll Indicators */
.scroll-indicator {
  text-align: center;
  margin-top: auto;
  padding-bottom: 24px;
  font-size: 11px;
  font-weight: 600;
  color: var(--text-dim);
  letter-spacing: 0.1em;
  text-transform: uppercase;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
}
.mouse-icon {
  width: 20px;
  height: 32px;
  border-radius: 10px;
  border: 1.5px solid var(--text-dim);
  position: relative;
}
.mouse-dot {
  width: 3px;
  height: 6px;
  background: var(--accent);
  border-radius: 50%;
  position: absolute;
  left: 50%;
  transform: translateX(-50%);
  top: 6px;
  animation: scrollScroll 1.5s infinite;
}
@keyframes scrollScroll {
  0% { top: 6px; opacity: 1; }
  100% { top: 16px; opacity: 0; }
}
</style>
</head>
<body>

<canvas id="network-canvas"></canvas>
<div class="blueprint-grid"></div>

<div class="page-wrapper">
  <!-- Navigation Header bar -->
  <div class="topbar liquid-glass-strong">
    <a href="index.jsp" class="logo-wrap">
      <div class="logo-icon">
        <i data-lucide="sparkles" style="width: 16px; height: 16px; color: #fff;"></i>
      </div>
      <span class="logo-text">CIVIC<span>FIX</span></span>
    </a>
    
    <div class="nav-links">
      <a href="leaderboard.jsp" class="nav-link">Leaderboard</a>
      <a href="login.jsp" class="nav-link portal-btn hover-scale">Portal Access</a>
    </div>
  </div>

  <!-- Hero Content Split Grid -->
  <div class="hero-container">
    <!-- Left Panel: Cinematic Content -->
    <div class="hero-left">
      <div class="hero-badge">
        <i data-lucide="sparkles" style="width: 12px; height: 12px;"></i>
        <span>Urban OS v1.2</span>
      </div>
      <h1 class="hero-title">Fixing Cities<br>Through <span>Citizen Power</span></h1>
      <p class="hero-sub">
        Report infrastructural hazards, track municipal responses in real-time, and build a safer, more responsive neighborhood environment.
      </p>
      
      <div class="cta-row">
        <a href="login.jsp" class="btn-cta btn-cta-primary hover-scale">
          <span>Citizen Dashboard</span>
          <i data-lucide="arrow-right" style="width: 16px; height: 16px;"></i>
        </a>
        <a href="leaderboard.jsp" class="btn-cta btn-cta-secondary hover-scale">
          <span>Global Leaderboard</span>
        </a>
      </div>

      <!-- Stats counter rows -->
      <div class="stats-row">
        <div class="stat-item">
          <span class="stat-number" id="stat-reported"><%= totalCount %></span>
          <span class="stat-lbl">Issues Logged</span>
        </div>
        <div class="stat-item">
          <span class="stat-number" id="stat-active" style="color: var(--accent);"><%= activeCount %></span>
          <span class="stat-lbl">Active Repairs</span>
        </div>
        <div class="stat-item">
          <span class="stat-number" id="stat-resolved" style="color: var(--success);"><%= resolvedCount %></span>
          <span class="stat-lbl">Resolutions Done</span>
        </div>
      </div>
    </div>

    <!-- Right Panel: Interactive Smart-City Map Widget -->
    <!-- Right Panel: Core Capabilities Showcase -->
    <div class="hero-right">
      <div class="map-canvas-card liquid-glass-strong" style="padding: 28px; display: flex; flex-direction: column; gap: 24px; height: auto;">
        <div class="map-header" style="border-bottom: 1px solid rgba(255,255,255,0.06); padding-bottom: 16px; margin-bottom: 0;">
          <div class="map-title">
            <i data-lucide="layers" style="width: 18px; height: 18px; color: var(--accent);"></i>
            <span style="font-family: 'Space Grotesk', sans-serif; font-size: 16px; font-weight: 700; color: #fff;">Platform Capabilities</span>
          </div>
        </div>

        <div style="display: flex; flex-direction: column; gap: 20px; text-align: left;">
          <!-- Capability 1 -->
          <div style="display: flex; gap: 16px; align-items: flex-start;">
            <div style="width: 38px; height: 38px; border-radius: 12px; background: rgba(52, 211, 153, 0.08); border: 1px solid rgba(52, 211, 153, 0.2); display: flex; align-items: center; justify-content: center; flex-shrink: 0; color: var(--accent);">
              <i data-lucide="alert-triangle" style="width: 18px; height: 18px;"></i>
            </div>
            <div>
              <h4 style="font-family: 'Space Grotesk', sans-serif; font-size: 14px; font-weight: 600; color: #fff; margin-bottom: 4px;">1. Telemetry Reporting</h4>
              <p style="font-size: 11.5px; color: var(--text-muted); line-height: 1.5;">Citizens submit geotagged reports of potholes, leaks, and damage with evidence photos directly from the field.</p>
            </div>
          </div>

          <!-- Capability 2 -->
          <div style="display: flex; gap: 16px; align-items: flex-start;">
            <div style="width: 38px; height: 38px; border-radius: 12px; background: rgba(16, 185, 129, 0.08); border: 1px solid rgba(16, 185, 129, 0.2); display: flex; align-items: center; justify-content: center; flex-shrink: 0; color: var(--primary);">
              <i data-lucide="cpu" style="width: 18px; height: 18px;"></i>
            </div>
            <div>
              <h4 style="font-family: 'Space Grotesk', sans-serif; font-size: 14px; font-weight: 600; color: #fff; margin-bottom: 4px;">2. AI Severity Scoring</h4>
              <p style="font-size: 11.5px; color: var(--text-muted); line-height: 1.5;">An automated severity engine calculates threat scores to assist dispatchers in prioritizing critical repairs.</p>
            </div>
          </div>

          <!-- Capability 3 -->
          <div style="display: flex; gap: 16px; align-items: flex-start;">
            <div style="width: 38px; height: 38px; border-radius: 12px; background: rgba(16, 185, 129, 0.08); border: 1px solid rgba(16, 185, 129, 0.2); display: flex; align-items: center; justify-content: center; flex-shrink: 0; color: var(--success);">
              <i data-lucide="check-circle" style="width: 18px; height: 18px;"></i>
            </div>
            <div>
              <h4 style="font-family: 'Space Grotesk', sans-serif; font-size: 14px; font-weight: 600; color: #fff; margin-bottom: 4px;">3. Direct Resolution Tracker</h4>
              <p style="font-size: 11.5px; color: var(--text-muted); line-height: 1.5;">Real-time progress timelines show stages from review and dispatcher assignment to complete crew resolution.</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>

  <!-- Scroll Down indicator -->
  <div class="scroll-indicator">
    <div class="mouse-icon">
      <div class="mouse-dot"></div>
    </div>
    <span>Operational Control System</span>
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

// HTML5 Connected Network Canvas Particle Simulation
const canvas = document.getElementById('network-canvas');
const ctx = canvas.getContext('2d');

let particles = [];
const particleCount = 60;
const connectionDistance = 110;

function resizeCanvas() {
  canvas.width = window.innerWidth;
  canvas.height = window.innerHeight;
}
window.addEventListener('resize', resizeCanvas);
resizeCanvas();

class Particle {
  constructor() {
    this.x = Math.random() * canvas.width;
    this.y = Math.random() * canvas.height;
    this.vx = (Math.random() - 0.5) * 0.4;
    this.vy = (Math.random() - 0.5) * 0.4;
    this.radius = Math.random() * 2 + 1.5;
    this.color = Math.random() > 0.4 ? 'rgba(52, 211, 153, 0.45)' : 'rgba(255, 215, 0, 0.4)';
  }
  update() {
    this.x += this.vx;
    this.y += this.vy;
    if (this.x < 0 || this.x > canvas.width) this.vx = -this.vx;
    if (this.y < 0 || this.y > canvas.height) this.vy = -this.vy;
  }
  draw() {
    ctx.beginPath();
    ctx.arc(this.x, this.y, this.radius, 0, Math.PI * 2);
    ctx.fillStyle = this.color;
    ctx.fill();
  }
}

for (let i = 0; i < particleCount; i++) {
  particles.push(new Particle());
}

function animateParticles() {
  ctx.clearRect(0, 0, canvas.width, canvas.height);
  
  for (let i = 0; i < particles.length; i++) {
    const p1 = particles[i];
    p1.update();
    p1.draw();
    
    for (let j = i + 1; j < particles.length; j++) {
      const p2 = particles[j];
      const dist = Math.hypot(p1.x - p2.x, p1.y - p2.y);
      
      if (dist < connectionDistance) {
        ctx.beginPath();
        ctx.moveTo(p1.x, p1.y);
        ctx.lineTo(p2.x, p2.y);
        const alpha = (1 - dist / connectionDistance) * 0.12;
        ctx.strokeStyle = 'rgba(52, 211, 153, ' + alpha + ')';
        ctx.lineWidth = 1;
        ctx.stroke();
      }
    }
  }
  requestAnimationFrame(animateParticles);
}
animateParticles();

// Interactive Map popup controls removed for Option B showcase
</script>
</body>
</html>