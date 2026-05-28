<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List, com.civicfix.model.User, com.civicfix.dao.UserDAO, com.civicfix.dao.ComplaintDAO, com.civicfix.model.Complaint" %>
<%
    List<User> topUsers    = UserDAO.getLeaderboard(10);
    List<Complaint> recent = ComplaintDAO.getAllComplaints();
    int totalComplaints    = (recent != null) ? recent.size() : 0;
    int totalResolved      = 0;
    int totalVotes         = 0;
    if (recent != null) {
        for (Complaint c : recent) {
            if ("CLOSED".equals(c.getStatus())) {
                totalResolved++;
            }
            totalVotes += c.getVotes();
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>CivicFix — Leaderboard</title>
<link href="https://fonts.googleapis.com/css2?family=Poppins:ital,wght@0,300;0,400;0,500;0,600;0,700;1,400;1,500&family=Source+Serif+4:ital,opsz,wght@1,8..60,400;1,8..60,500;1,8..60,600&display=swap" rel="stylesheet">
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
  --secondary: #059669;
  --warn: #F59E0B;
  
  --gold: #FFD700;
  --silver: #cbd5e1;
  --bronze: #d97706;
  
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

/* Grid overlay for blueprint effect */
.grid-overlay {
  position: absolute;
  inset: 0;
  background-image: 
    linear-gradient(rgba(255, 255, 255, 0.02) 1px, transparent 1px),
    linear-gradient(90deg, rgba(255, 255, 255, 0.02) 1px, transparent 1px);
  background-size: 50px 50px;
  z-index: 1;
  pointer-events: none;
}

/* Liquid Glass CSS */
.liquid-glass {
  background: rgba(255, 255, 255, 0.01);
  background-blend-mode: luminosity;
  backdrop-filter: blur(8px);
  -webkit-backdrop-filter: blur(8px);
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
    rgba(52, 211, 153, 0.35) 0%, 
    rgba(16, 185, 129, 0.15) 20%, 
    transparent 40%, 
    transparent 60%, 
    rgba(16, 185, 129, 0.15) 80%, 
    rgba(52, 211, 153, 0.35) 100%
  );
  -webkit-mask: linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0);
  -webkit-mask-composite: xor;
  mask-composite: exclude;
  pointer-events: none;
}

.liquid-glass-strong {
  background: rgba(255, 255, 255, 0.01);
  background-blend-mode: luminosity;
  backdrop-filter: blur(40px);
  -webkit-backdrop-filter: blur(40px);
  border: none;
  box-shadow: 4px 4px 10px rgba(0,0,0,0.15), inset 0 1px 1px rgba(255, 255, 255, 0.15);
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
    transparent 40%, 
    transparent 60%, 
    rgba(16, 185, 129, 0.2) 80%, 
    rgba(52, 211, 153, 0.45) 100%
  );
  -webkit-mask: linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0);
  -webkit-mask-composite: xor;
  mask-composite: exclude;
  pointer-events: none;
}

/* Page wrapper */
.page-wrapper {
  position: relative;
  z-index: 10;
  height: 100vh;
  display: flex;
  flex-direction: column;
  overflow-y: auto;
}

/* Header bar */
.topbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 32px;
  height: 72px;
  margin: 16px 16px 0;
  border-radius: 20px;
}
.logo-wrap {
  display: flex;
  align-items: center;
  gap: 12px;
}
.logo-icon-box {
  width: 28px;
  height: 28px;
  border-radius: 8px;
  background: linear-gradient(135deg, var(--warn) 0%, var(--secondary) 100%);
  display: flex;
  align-items: center;
  justify-content: center;
}
.logo-text {
  font-family: 'Space Grotesk', sans-serif;
  font-size: 22px;
  font-weight: 700;
  letter-spacing: -1px;
}
.logo-text em {
  font-family: 'Source Serif 4', serif;
  font-style: italic;
  font-weight: 400;
  color: rgba(255, 255, 255, 0.85);
}
.nav-links {
  display: flex;
  gap: 8px;
}
.nav-link {
  font-size: 13px;
  font-weight: 600;
  padding: 8px 16px;
  color: var(--text-muted);
  text-decoration: none;
  border-radius: 12px;
  transition: all 0.2s ease;
}
.nav-link:hover {
  color: #fff;
  background: rgba(255, 255, 255, 0.02);
}
.nav-link.active {
  color: var(--primary);
  background: rgba(255, 255, 255, 0.02);
}

.main {
  max-width: 900px;
  width: 100%;
  margin: 0 auto;
  padding: 40px 24px;
}

/* Hero Title */
.hero {
  text-align: center;
  margin-bottom: 36px;
}
.hero-badge {
  display: inline-block;
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 1px;
  text-transform: uppercase;
  color: var(--warn);
  background: rgba(245, 158, 11, 0.08);
  border: 1px solid rgba(245, 158, 11, 0.15);
  padding: 6px 16px;
  border-radius: 20px;
  margin-bottom: 16px;
}
.hero-title {
  font-family: 'Space Grotesk', sans-serif;
  font-size: 44px;
  font-weight: 500;
  letter-spacing: -1.5px;
  color: #fff;
  line-height: 1.1;
  margin-bottom: 8px;
}
.hero-title span {
  color: var(--secondary);
}
.hero-title em {
  font-family: 'Source Serif 4', serif;
  font-style: italic;
  font-weight: 400;
  color: rgba(255, 255, 255, 0.85);
}
.hero-sub {
  font-size: 14.5px;
  color: var(--text-muted);
}

/* Statistics Widgets */
.city-stats {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 20px;
  margin-bottom: 40px;
}
.cstat {
  border-radius: 20px;
  padding: 24px;
  text-align: center;
  transition: transform 0.25s ease;
}
.cstat:hover {
  transform: translateY(-2px);
}
.cstat-val {
  font-family: 'Space Grotesk', sans-serif;
  font-size: 38px;
  font-weight: 500;
  color: var(--primary);
  line-height: 1;
}
.cstat-lbl {
  font-size: 10px;
  font-weight: 700;
  text-transform: uppercase;
  color: var(--text-dim);
  letter-spacing: 0.1em;
  margin-top: 8px;
}

/* Glass podium standings */
.podium {
  display: flex;
  align-items: flex-end;
  justify-content: center;
  gap: 20px;
  margin-bottom: 40px;
  height: 250px;
}
.pod {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12px;
  flex: 1;
  max-width: 140px;
  transition: transform 0.25s ease;
}
.pod:hover {
  transform: scale(1.03);
}
.pod-avatar {
  width: 58px;
  height: 58px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-family: 'Space Grotesk', sans-serif;
  font-size: 22px;
  font-weight: 700;
  border: 3px solid;
  background: rgba(255, 255, 255, 0.02);
  box-shadow: 0 10px 20px rgba(0, 0, 0, 0.2);
  animation: floatAvatar 6s ease-in-out infinite;
}
@keyframes floatAvatar {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-5px); }
}
.pod-1 .pod-avatar {
  border-color: var(--gold);
  color: var(--gold);
  box-shadow: 0 0 20px rgba(251, 191, 36, 0.25);
  animation-delay: 0s;
}
.pod-2 .pod-avatar {
  border-color: var(--silver);
  color: var(--silver);
  box-shadow: 0 0 20px rgba(203, 213, 225, 0.15);
  animation-delay: 1s;
}
.pod-3 .pod-avatar {
  border-color: var(--bronze);
  color: var(--bronze);
  box-shadow: 0 0 20px rgba(217, 119, 6, 0.15);
  animation-delay: 2s;
}
.pod-name {
  font-size: 13.5px;
  font-weight: 600;
  color: #fff;
  text-align: center;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  width: 100%;
}
.pod-pts {
  font-size: 11px;
  font-weight: 600;
  color: var(--secondary);
}
.pod-block {
  border-radius: 16px 16px 0 0;
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  border-bottom: none;
}
.pod-rank {
  font-family: 'Space Grotesk', sans-serif;
  font-size: 30px;
  font-weight: 600;
}
.pod-1 .pod-block { height: 130px; }.pod-1 .pod-rank { color: var(--gold); }
.pod-2 .pod-block { height: 95px; }.pod-2 .pod-rank { color: var(--silver); }
.pod-3 .pod-block { height: 70px; }.pod-3 .pod-rank { color: var(--bronze); }

/* Rankings Table Card */
.lb-card {
  border-radius: 24px;
  overflow: hidden;
  box-shadow: 0 15px 35px rgba(0, 0, 0, 0.25);
}
.lb-head {
  display: grid;
  grid-template-columns: 80px 1fr 140px 100px;
  padding: 16px 24px;
  border-bottom: 1px solid var(--glass-border);
  background: rgba(15, 23, 42, 0.2);
}
.lb-head span {
  font-size: 11px;
  font-weight: 700;
  text-transform: uppercase;
  color: var(--text-dim);
  letter-spacing: 0.05em;
}
.lb-row {
  display: grid;
  grid-template-columns: 80px 1fr 140px 100px;
  align-items: center;
  padding: 16px 24px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.04);
  transition: all 0.2s;
}
.lb-row:last-child {
  border-bottom: none;
}
.lb-row:hover {
  background: rgba(255, 255, 255, 0.01);
}

.rank-cell {
  font-family: 'Space Grotesk', sans-serif;
  font-size: 16px;
  font-weight: 600;
}
.rank-1 { color: var(--gold); }
.rank-2 { color: var(--silver); }
.rank-3 { color: var(--bronze); }
.rank-other { color: var(--text-dim); }

.user-cell {
  display: flex;
  align-items: center;
  gap: 12px;
}
.user-avatar {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.02);
  border: 1px solid rgba(255, 255, 255, 0.05);
  display: flex;
  align-items: center;
  justify-content: center;
  font-family: 'Space Grotesk', sans-serif;
  font-size: 14px;
  font-weight: 600;
  color: var(--accent);
  flex-shrink: 0;
}
.user-name {
  font-size: 14.5px;
  font-weight: 500;
  color: #fff;
}
.pts-cell {
  font-family: 'Space Grotesk', sans-serif;
  font-size: 15px;
  font-weight: 600;
  color: var(--secondary);
}
.bar-cell {
  padding-right: 16px;
}
.pts-bar {
  height: 4px;
  background: rgba(16, 185, 129, 0.08);
  border-radius: 10px;
  overflow: hidden;
}
.pts-fill {
  height: 100%;
  background: linear-gradient(90deg, var(--primary) 0%, var(--secondary) 100%);
  border-radius: 10px;
  width: 0;
  transition: width 1.2s cubic-bezier(0.16, 1, 0.3, 1);
}

.empty-lb {
  text-align: center;
  padding: 48px;
  color: var(--text-dim);
}
.back-link {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  font-size: 13px;
  font-weight: 600;
  color: var(--text-muted);
  text-decoration: none;
  margin-top: 32px;
  padding: 10px 20px;
  border-radius: 12px;
  transition: all 0.2s;
}
.back-link:hover {
  color: #fff;
  border-color: var(--primary);
}
</style>
</head>
<body>

<!-- Animated connected nodes canvas background -->
<canvas id="network-canvas" style="position:fixed; inset:0; width:100%; height:100%; z-index:0; pointer-events:none;"></canvas>
<div class="blueprint-grid" style="position:fixed; inset:0; background-image: linear-gradient(rgba(52, 211, 153, 0.015) 1px, transparent 1px), linear-gradient(90deg, rgba(52, 211, 153, 0.015) 1px, transparent 1px); background-size: 60px 60px; background-position: center; z-index:1; pointer-events:none;"></div>

<div class="page-wrapper">
  <!-- Header row -->
  <div class="topbar liquid-glass-strong">
    <div class="logo-wrap">
      <div class="logo-icon-box">
        <i data-lucide="sparkles" style="width: 16px; height: 16px; color: #fff;"></i>
      </div>
      <span class="logo-text">CIVIC<em>FIX</em></span>
    </div>
    <div class="nav-links">
      <a href="user-dashboard.jsp" class="nav-link">Feed Hub</a>
      <a href="leaderboard.jsp" class="nav-link active">Leaderboard</a>
      <% if(session.getAttribute("currentUser") != null) { %>
        <a href="auth?action=logout" class="nav-link" style="color:var(--danger);">Logout</a>
      <% } else { %>
        <a href="login.jsp" class="nav-link">Login</a>
      <% } %>
    </div>
  </div>

  <div class="main">
    <div class="hero">
      <div class="hero-badge">Civic Champions</div>
      <h1 class="hero-title">City <em>Leaderboard</em></h1>
      <p class="hero-sub">Recognizing citizens making a differences in our community.</p>
    </div>

    <!-- Stats -->
    <div class="city-stats">
      <div class="cstat liquid-glass">
        <div class="cstat-val"><%= totalComplaints %></div>
        <div class="cstat-lbl">Issues Reported</div>
      </div>
      <div class="cstat liquid-glass">
        <div class="cstat-val" style="color:var(--secondary);"><%= totalResolved %></div>
        <div class="cstat-lbl">Issues Resolved</div>
      </div>
      <div class="cstat liquid-glass">
        <div class="cstat-val" style="color:var(--warn);"><%= totalVotes %></div>
        <div class="cstat-lbl">Community Upvotes</div>
      </div>
    </div>

    <!-- Podium standings -->
    <% if (topUsers != null && topUsers.size() >= 3) { %>
    <div class="podium">
      <!-- 2nd place -->
      <div class="pod pod-2">
        <div class="pod-avatar"><%= topUsers.get(1).getUsername().substring(0,1).toUpperCase() %></div>
        <div class="pod-name"><%= topUsers.get(1).getUsername() %></div>
        <div class="pod-pts"><%= topUsers.get(1).getRewardPoints() %> pts</div>
        <div class="pod-block liquid-glass-strong"><span class="pod-rank">2</span></div>
      </div>
      <!-- 1st place -->
      <div class="pod pod-1">
        <div class="pod-avatar"><%= topUsers.get(0).getUsername().substring(0,1).toUpperCase() %></div>
        <div class="pod-name"><%= topUsers.get(0).getUsername() %></div>
        <div class="pod-pts"><%= topUsers.get(0).getRewardPoints() %> pts</div>
        <div class="pod-block liquid-glass-strong"><span class="pod-rank">1</span></div>
      </div>
      <!-- 3rd place -->
      <div class="pod pod-3">
        <div class="pod-avatar"><%= topUsers.get(2).getUsername().substring(0,1).toUpperCase() %></div>
        <div class="pod-name"><%= topUsers.get(2).getUsername() %></div>
        <div class="pod-pts"><%= topUsers.get(2).getRewardPoints() %> pts</div>
        <div class="pod-block liquid-glass-strong"><span class="pod-rank">3</span></div>
      </div>
    </div>
    <% } %>

    <!-- Table standings -->
    <div class="lb-card liquid-glass-strong">
      <div class="lb-head">
        <span>Rank</span><span>Citizen</span><span>Progress</span><span>Points</span>
      </div>
      <% if (topUsers == null || topUsers.isEmpty()) { %>
        <div class="empty-lb">// Be the first to register and report issues to claim rank #1!</div>
      <% } else {
          int maxPts = topUsers.get(0).getRewardPoints();
          if (maxPts <= 0) maxPts = 1;
          for (int i = 0; i < topUsers.size(); i++) {
              User u = topUsers.get(i);
              int rank = i + 1;
              String rankClass = rank==1?"rank-1":rank==2?"rank-2":rank==3?"rank-3":"rank-other";
              String rankLabel = rank==1?"#1":rank==2?"#2":rank==3?"#3":"#"+rank;
              int barWidth = (u.getRewardPoints() * 100) / maxPts;
      %>
      <div class="lb-row">
        <div class="rank-cell <%= rankClass %>"><%= rankLabel %></div>
        <div class="user-cell">
          <div class="user-avatar"><%= u.getUsername().substring(0,1).toUpperCase() %></div>
          <div class="user-name"><%= u.getUsername() %></div>
        </div>
        <div class="bar-cell">
          <div class="pts-bar"><div class="pts-fill" data-width="<%= barWidth %>"></div></div>
        </div>
        <div class="pts-cell"><%= u.getRewardPoints() %></div>
      </div>
      <% } } %>
    </div>

    <a href="user-dashboard.jsp" class="back-link liquid-glass hover-scale">
      <i data-lucide="arrow-left" style="width: 14px; height: 14px;"></i>
      <span>Back to Feed</span>
    </a>
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

// Animate progress bars
document.querySelectorAll('.pts-fill[data-width]').forEach(el => {
  setTimeout(() => { el.style.width = el.dataset.width + '%'; }, 300);
});

// Connected network particle engine
const canvas = document.getElementById('network-canvas');
const ctx = canvas.getContext('2d');
let particles = [];
const particleCount = 45;
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
    this.radius = Math.random() * 2 + 1.2;
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
    ctx.fillStyle = 'rgba(52, 211, 153, 0.4)';
    ctx.fill();
  }
}

for (let i = 0; i < particleCount; i++) {
  particles.push(new Particle());
}

function animate() {
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
        ctx.lineWidth = 0.8;
        ctx.stroke();
      }
    }
  }
  requestAnimationFrame(animate);
}
animate();
</script>
</body>
</html>
