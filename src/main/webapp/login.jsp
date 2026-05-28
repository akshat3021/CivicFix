<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>CivicFix — Secure Portal Access</title>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&family=Space+Grotesk:wght@400;500;600;700;800&family=Fira+Code:wght@400;500&display=swap" rel="stylesheet">
<!-- Lucide Icons CDN -->
<script src="https://unpkg.com/lucide@latest"></script>
<style>
:root {
  --bg-dark: #070d0a;
  --panel-bg: rgba(13, 20, 16, 0.65);
  
  --primary: #10B981;
  --primary-glow: rgba(16, 185, 129, 0.2);
  --accent: #34D399;
  --accent-glow: rgba(52, 211, 153, 0.2);
  --magenta: #FFD700;
  --magenta-glow: rgba(255, 215, 0, 0.15);
  --secondary: #059669;
  
  --glass-bg: rgba(13, 20, 16, 0.45);
  --glass-border: rgba(255, 255, 255, 0.08);
  --text-main: #f3f4f6;
  --text-muted: rgba(255, 255, 255, 0.7);
  --text-dim: rgba(255, 255, 255, 0.45);
  
  --font-sans: 'Plus Jakarta Sans', sans-serif;
  --font-title: 'Space Grotesk', sans-serif;
  --font-mono: 'Fira Code', monospace;
}

* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  background: var(--bg-dark);
  color: var(--text-main);
  font-family: var(--font-sans);
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
  position: relative;
}

/* Background interactive nodes canvas */
#login-canvas {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  z-index: 0;
  pointer-events: none;
}

/* Moving Blueprint Grid Pattern Overlay */
.grid-overlay {
  position: absolute;
  inset: 0;
  background-image: 
    linear-gradient(rgba(52, 211, 153, 0.02) 1px, transparent 1px),
    linear-gradient(90deg, rgba(52, 211, 153, 0.02) 1px, transparent 1px);
  background-size: 60px 60px;
  background-position: center;
  z-index: 1;
  pointer-events: none;
  animation: moveGrid 30s linear infinite;
}
@keyframes moveGrid {
  from { background-position: 0 0; }
  to { background-position: 0 60px; }
}

/* Interactive Cursor Glow */
.cursor-glow {
  position: absolute;
  width: 500px;
  height: 500px;
  border-radius: 50%;
  background: radial-gradient(circle, rgba(52, 211, 153, 0.04) 0%, rgba(16, 185, 129, 0.02) 50%, transparent 100%);
  z-index: 1;
  pointer-events: none;
  transform: translate(-50%, -50%);
  filter: blur(40px);
  transition: left 0.1s cubic-bezier(0.1, 0.8, 0.2, 1), top 0.1s cubic-bezier(0.1, 0.8, 0.2, 1);
}

.wrap {
  position: relative;
  z-index: 20;
  width: 100%;
  max-width: 440px;
  padding: 24px;
}

/* Brand Logo */
.brand {
  text-align: center;
  margin-bottom: 28px;
}
.brand-logo-container {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  position: relative;
  margin-bottom: 12px;
}
.logo-ring {
  width: 48px;
  height: 48px;
  border: 2px dashed rgba(0, 212, 255, 0.4);
  border-radius: 50%;
  animation: rotateRing 20s linear infinite;
  position: absolute;
}
@keyframes rotateRing {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}
.logo-core {
  width: 32px;
  height: 32px;
  background: linear-gradient(135deg, var(--accent) 0%, var(--primary) 100%);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 0 20px rgba(0, 212, 255, 0.4);
  font-family: var(--font-title);
  font-weight: 800;
  font-size: 14px;
  color: #0b1220;
  z-index: 1;
}
.brand-name {
  font-family: var(--font-title);
  font-size: 32px;
  font-weight: 800;
  letter-spacing: -1.5px;
  background: linear-gradient(135deg, #fff 40%, var(--accent) 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}
.brand-sub {
  font-size: 12px;
  color: var(--text-muted);
  font-weight: 500;
  margin-top: 4px;
  letter-spacing: 0.5px;
}

/* Alert styles */
.alert {
  font-size: 12.5px;
  padding: 14px 18px;
  margin-bottom: 20px;
  border-radius: 14px;
  border: 1px solid;
  display: flex;
  align-items: center;
  gap: 10px;
  font-weight: 500;
}
.alert-error {
  background: rgba(244, 63, 94, 0.08);
  border-color: rgba(244, 63, 94, 0.2);
  color: #fda4af;
}
.alert-success {
  background: rgba(16, 185, 129, 0.08);
  border-color: rgba(16, 185, 129, 0.2);
  color: #6ee7b7;
}

/* Box Glassmorphic Card Container with float animation */
.box {
  background: var(--glass-bg);
  border: 1px solid var(--glass-border);
  border-radius: 28px;
  backdrop-filter: blur(24px);
  -webkit-backdrop-filter: blur(24px);
  box-shadow: 0 30px 60px rgba(0, 0, 0, 0.45), inset 0 1px 0 rgba(255, 255, 255, 0.05);
  overflow: hidden;
  animation: floatCard 8s ease-in-out infinite, slideUp 0.8s cubic-bezier(0.16, 1, 0.3, 1) both;
}

@keyframes floatCard {
  0%, 100% { transform: translateY(0px); }
  50% { transform: translateY(-6px); }
}

@keyframes slideUp {
  from { transform: translateY(30px); opacity: 0; }
  to { transform: translateY(0); opacity: 1; }
}

/* Tabs */
.tabs {
  display: flex;
  background: rgba(10, 15, 30, 0.3);
  padding: 8px;
  gap: 6px;
  border-bottom: 1px solid var(--glass-border);
}
.tab-btn {
  flex: 1;
  font-family: var(--font-title);
  font-size: 13px;
  font-weight: 700;
  padding: 12px;
  background: none;
  border: none;
  color: var(--text-muted);
  cursor: pointer;
  border-radius: 18px;
  transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
  letter-spacing: 0.5px;
}
.tab-btn:hover {
  color: #fff;
  background: rgba(255, 255, 255, 0.02);
}
.tab-btn.active {
  color: #fff;
  background: rgba(0, 212, 255, 0.08);
  box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(0, 212, 255, 0.2);
}

.tab-content {
  padding: 36px;
  display: none;
}
.tab-content.active {
  display: block;
}

/* Form Slider Switches */
.role-toggle-wrap {
  display: flex;
  flex-direction: column;
  gap: 8px;
  margin-bottom: 24px;
}
.role-switch-container {
  display: flex;
  background: rgba(10, 15, 30, 0.4);
  border: 1px solid var(--glass-border);
  padding: 5px;
  border-radius: 20px;
  position: relative;
  height: 46px;
  align-items: center;
  cursor: pointer;
}
.role-switch-slider {
  position: absolute;
  width: calc(50% - 5px);
  height: 36px;
  background: var(--primary);
  border-radius: 15px;
  box-shadow: 0 4px 15px rgba(99, 102, 241, 0.35);
  transition: transform 0.4s cubic-bezier(0.16, 1, 0.3, 1);
  z-index: 1;
}
.role-switch-option {
  flex: 1;
  text-align: center;
  font-size: 13px;
  font-weight: 700;
  color: var(--text-muted);
  z-index: 2;
  user-select: none;
  transition: color 0.3s;
}
.role-switch-option.active {
  color: #fff;
}

/* Staggered entry */
.form-group {
  margin-bottom: 20px;
  opacity: 0;
  animation: staggerIn 0.5s cubic-bezier(0.16, 1, 0.3, 1) both;
}
.form-group:nth-child(1) { animation-delay: 0.15s; }
.form-group:nth-child(2) { animation-delay: 0.2s; }
.form-group:nth-child(3) { animation-delay: 0.25s; }
.form-group:nth-child(4) { animation-delay: 0.3s; }
.form-group:nth-child(5) { animation-delay: 0.35s; }

@keyframes staggerIn {
  from { transform: translateY(15px); opacity: 0; }
  to { transform: translateY(0); opacity: 1; }
}

.form-label {
  display: block;
  font-size: 11px;
  font-weight: 700;
  text-transform: uppercase;
  color: var(--text-muted);
  letter-spacing: 1px;
  margin-bottom: 8px;
}

.form-input {
  width: 100%;
  background: rgba(10, 15, 30, 0.4);
  border: 1px solid var(--glass-border);
  color: var(--text-main);
  padding: 14px 18px;
  font-family: var(--font-sans);
  font-size: 14px;
  outline: none;
  border-radius: 14px;
  transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
}
.form-input:focus {
  border-color: var(--accent);
  box-shadow: 0 0 0 4px var(--accent-glow);
  background: rgba(10, 15, 30, 0.6);
}

/* OTP fields */
.email-input-group {
  display: flex;
  gap: 8px;
}
.verify-btn {
  padding: 0 20px;
  background: rgba(0, 212, 255, 0.08);
  border: 1px solid rgba(0, 212, 255, 0.2);
  color: var(--accent);
  border-radius: 14px;
  font-size: 12.5px;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.2s ease;
  white-space: nowrap;
}
.verify-btn:hover:not(:disabled) {
  background: var(--accent);
  color: #0b1220;
  box-shadow: 0 4px 12px var(--accent-glow);
}
.verify-btn:disabled {
  opacity: 0.4;
  cursor: not-allowed;
}

.otp-verify-box {
  margin-top: 12px;
  border-radius: 16px;
  padding: 16px;
  background: rgba(10, 15, 30, 0.35);
  border: 1px dashed var(--glass-border);
  display: none;
}
.otp-verify-title {
  font-size: 12px;
  font-weight: 700;
  color: var(--text-muted);
  margin-bottom: 8px;
  text-transform: uppercase;
}
.otp-verify-row {
  display: flex;
  gap: 8px;
}

/* Admin Passkey Drawer Container */
.passkey-container {
  max-height: 0;
  opacity: 0;
  overflow: hidden;
  transition: max-height 0.4s cubic-bezier(0.16, 1, 0.3, 1), opacity 0.3s ease;
}
.passkey-container.visible {
  max-height: 90px;
  opacity: 1;
}

/* Glowing action buttons */
.submit-btn {
  width: 100%;
  padding: 15px;
  background: linear-gradient(135deg, var(--accent) 0%, var(--primary) 100%);
  color: #0b1220;
  font-family: var(--font-title);
  font-size: 15px;
  font-weight: 800;
  letter-spacing: 0.5px;
  border: none;
  cursor: pointer;
  border-radius: 14px;
  transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  box-shadow: 0 4px 15px var(--accent-glow);
}
.submit-btn:hover:not(:disabled) {
  box-shadow: 0 10px 25px rgba(0, 212, 255, 0.45);
  transform: scale(1.02) translateY(-2px);
}
.submit-btn:disabled {
  background: var(--text-dim);
  box-shadow: none;
  opacity: 0.5;
  cursor: not-allowed;
}
.submit-btn.green {
  background: var(--secondary);
  color: #0b1220;
  box-shadow: 0 4px 15px rgba(16, 185, 129, 0.25);
}
.submit-btn.green:hover:not(:disabled) {
  box-shadow: 0 10px 25px rgba(16, 185, 129, 0.45);
}

/* Loading spinner */
.spinner {
  width: 16px;
  height: 16px;
  border: 2px solid rgba(11, 18, 32, 0.2);
  border-top: 2px solid #0b1220;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
  display: inline-block;
}
@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.dev-helper {
  margin-top: 8px;
  padding: 8px 12px;
  background: rgba(245, 158, 11, 0.08);
  border: 1px solid rgba(245, 158, 11, 0.2);
  color: #fef08a;
  font-family: var(--font-mono);
  font-size: 11px;
  border-radius: 8px;
  display: none;
}

.footer-text {
  text-align: center;
  font-size: 11px;
  color: var(--text-dim);
  margin-top: 24px;
  font-weight: 600;
  letter-spacing: 0.5px;
}
</style>
</head>
<body>

<!-- High performance animated network & sweeps canvas -->
<canvas id="login-canvas"></canvas>
<div class="grid-overlay"></div>
<div class="cursor-glow" id="mouse-glow"></div>

<div class="wrap">
  <div class="brand">
    <div class="brand-logo-container">
      <div class="logo-ring"></div>
      <div class="logo-core">CF</div>
    </div>
    <div class="brand-name">CIVICFIX</div>
    <div class="brand-sub">Bridging Citizens & Municipal Authorities</div>
  </div>

  <% if(request.getParameter("error") != null) { %>
    <div class="alert alert-error">
      <i data-lucide="x-circle" style="width:16px; height:16px;"></i>
      <span><%= request.getParameter("error").replaceAll("<[^>]*>","") %></span>
    </div>
  <% } %>
  <% if(request.getParameter("msg") != null) { %>
    <div class="alert alert-success">
      <i data-lucide="check-circle" style="width:16px; height:16px;"></i>
      <span><%= request.getParameter("msg").replaceAll("<[^>]*>","") %></span>
    </div>
  <% } %>

  <div class="box">
    <div class="tabs">
      <button id="btn-tab-login" class="tab-btn active" onclick="switchTab('login')">SIGN IN</button>
      <button id="btn-tab-register" class="tab-btn" onclick="switchTab('register')">REGISTER</button>
    </div>

    <!-- LOGIN -->
    <div id="tab-login" class="tab-content active">
      <form action="auth" method="POST" onsubmit="showSubmitLoading(this)">
        <input type="hidden" name="action" value="login">
        <div class="form-group">
          <label class="form-label">Username</label>
          <input class="form-input" type="text" name="username" placeholder="Username" required autocomplete="username">
        </div>
        <div class="form-group">
          <label class="form-label">Password</label>
          <input class="form-input" type="password" name="password" placeholder="••••••••" required autocomplete="current-password">
        </div>
        <button type="submit" class="submit-btn" style="margin-top: 12px;">Sign In Securely &nbsp; →</button>
      </form>
    </div>

    <!-- REGISTER -->
    <div id="tab-register" class="tab-content">
      <form action="auth" method="POST" id="register-form" onsubmit="showSubmitLoading(this)">
        <input type="hidden" name="action" value="register">
        <input type="hidden" name="role" id="hidden-role" value="USER">
        
        <!-- Tactical slider switch for user role selection -->
        <div class="role-toggle-wrap">
          <label class="form-label">Choose Portal Role</label>
          <div class="role-switch-container" onclick="toggleRoleSwitch()">
            <div class="role-switch-slider" id="role-slider"></div>
            <div class="role-switch-option active" id="opt-user">CITIZEN</div>
            <div class="role-switch-option" id="opt-admin">ADMIN</div>
          </div>
        </div>

        <div class="form-group">
          <label class="form-label">Username</label>
          <input class="form-input" type="text" name="username" placeholder="Choose a username" required autocomplete="username">
        </div>
        
        <div class="form-group">
          <label class="form-label">Email Address</label>
          <div class="email-input-group">
            <input class="form-input" type="email" id="reg-email" name="email" placeholder="your@email.com" required autocomplete="email">
            <button type="button" class="verify-btn" id="send-otp-btn" onclick="sendOTP()">Send OTP</button>
          </div>
          
          <div class="otp-verify-box" id="otp-verify-box">
            <div class="otp-verify-title">Enter Verification Code</div>
            <div class="otp-verify-row">
              <input class="form-input" type="text" id="reg-otp" placeholder="6-digit code" maxlength="6">
              <button type="button" class="verify-btn" id="verify-otp-btn" onclick="verifyOTP()">Verify Code</button>
            </div>
            <div class="dev-helper" id="otp-dev-helper"></div>
          </div>
        </div>
        
        <div class="form-group">
          <label class="form-label">Password</label>
          <input class="form-input" type="password" name="password" placeholder="Create secure password" required autocomplete="new-password">
        </div>
        
        <!-- Sliding administrative code container -->
        <div class="form-group passkey-container" id="passkey-group">
          <label class="form-label">Admin Secret Passkey</label>
          <input class="form-input" type="password" id="admin-passkey-input" name="admin_passkey" placeholder="Administrative Key">
        </div>
        
        <button type="submit" class="submit-btn green" id="register-submit-btn" style="margin-top: 12px;" disabled>Create Account</button>
      </form>
    </div>
  </div>

  <div class="footer-text">SECURE OPERATIONS &nbsp;•&nbsp; v1.2</div>
</div>

<script>
// Initialize Lucide Icons if available
if (typeof lucide !== 'undefined') {
  try {
    lucide.createIcons();
  } catch (e) {
    console.error("Lucide icon generation failed:", e);
  }
}

// Clear the boot completion token on login screen safely
try {
  sessionStorage.removeItem('civicfix_boot_complete');
} catch (e) {
  console.warn("Could not clear boot completion token:", e);
}

let isEmailVerified = false;
let currentRole = 'USER';

function switchTab(name) {
  document.querySelectorAll('.tab-content').forEach(t => t.classList.remove('active'));
  document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
  document.getElementById('tab-' + name).classList.add('active');
  document.getElementById('btn-tab-' + name).classList.add('active');
}

function toggleRoleSwitch() {
  const hiddenRole = document.getElementById('hidden-role');
  const slider = document.getElementById('role-slider');
  const optUser = document.getElementById('opt-user');
  const optAdmin = document.getElementById('opt-admin');
  const passkeyGroup = document.getElementById('passkey-group');
  const passkeyInput = document.getElementById('admin-passkey-input');
  const submitBtn = document.getElementById('register-submit-btn');

  if (currentRole === 'USER') {
    currentRole = 'ADMIN';
    hiddenRole.value = 'ADMIN';
    slider.style.transform = 'translateX(100%)';
    optUser.classList.remove('active');
    optAdmin.classList.add('active');
    
    passkeyGroup.classList.add('visible');
    passkeyInput.required = true;
    
    submitBtn.disabled = false;
  } else {
    currentRole = 'USER';
    hiddenRole.value = 'USER';
    slider.style.transform = 'translateX(0)';
    optAdmin.classList.remove('active');
    optUser.classList.add('active');
    
    passkeyGroup.classList.remove('visible');
    passkeyInput.required = false;
    
    submitBtn.disabled = !isEmailVerified;
  }
}

function showSubmitLoading(form) {
  const btn = form.querySelector('button[type="submit"]');
  if (btn) {
    btn.style.pointerEvents = 'none';
    btn.innerHTML = `<span class="spinner"></span> Accessing SecNet...`;
  }
}

function sendOTP() {
  const emailInput = document.getElementById('reg-email');
  const sendBtn = document.getElementById('send-otp-btn');
  const verifyBox = document.getElementById('otp-verify-box');
  const devHelper = document.getElementById('otp-dev-helper');
  const email = emailInput.value.trim();
  
  if (!email || !email.includes('@')) {
    alert("Please enter a valid email address first.");
    return;
  }
  
  sendBtn.disabled = true;
  sendBtn.textContent = "Sending...";
  
  const xhr = new XMLHttpRequest();
  xhr.open("POST", "otp", true);
  xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
  xhr.onreadystatechange = function() {
    if (xhr.readyState === 4 && xhr.status === 200) {
      const resp = JSON.parse(xhr.responseText);
      if (resp.ok) {
        verifyBox.style.display = "block";
        if (resp.dev && resp.otp) {
          devHelper.style.display = "block";
          devHelper.textContent = "Code: " + resp.otp + " (dev helper)";
        } else {
          devHelper.style.display = "none";
        }
        
        let cooldown = 60;
        const timer = setInterval(() => {
          cooldown--;
          if (cooldown <= 0) {
            clearInterval(timer);
            sendBtn.disabled = false;
            sendBtn.textContent = "Resend OTP";
          } else {
            sendBtn.textContent = "Wait " + cooldown + "s";
          }
        }, 1000);
      } else {
        alert(resp.msg || "Failed to send OTP.");
        sendBtn.disabled = false;
        sendBtn.textContent = "Send OTP";
      }
    }
  };
  xhr.send("action=send&email=" + encodeURIComponent(email));
}

function verifyOTP() {
  const emailInput = document.getElementById('reg-email');
  const otpInput = document.getElementById('reg-otp');
  const verifyBtn = document.getElementById('verify-otp-btn');
  const submitBtn = document.getElementById('register-submit-btn');
  
  const email = emailInput.value.trim();
  const otp = otpInput.value.trim();
  
  if (!otp || otp.length < 6) {
    alert("Please enter the 6-digit verification code.");
    return;
  }
  
  verifyBtn.disabled = true;
  verifyBtn.textContent = "Verifying...";
  
  const xhr = new XMLHttpRequest();
  xhr.open("POST", "otp", true);
  xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
  xhr.onreadystatechange = function() {
    if (xhr.readyState === 4 && xhr.status === 200) {
      const resp = JSON.parse(xhr.responseText);
      if (resp.ok) {
        isEmailVerified = true;
        otpInput.disabled = true;
        emailInput.readOnly = true;
        document.getElementById('send-otp-btn').disabled = true;
        verifyBtn.textContent = "Verified ✓";
        verifyBtn.style.background = "rgba(16, 185, 129, 0.25)";
        verifyBtn.style.color = "#10b981";
        
        if (currentRole === 'USER') {
          submitBtn.disabled = false;
        }
      } else {
        alert(resp.msg || "Verification failed.");
        verifyBtn.disabled = false;
        verifyBtn.textContent = "Verify Code";
      }
    }
  };
  xhr.send("action=verify&email=" + encodeURIComponent(email) + "&otp=" + encodeURIComponent(otp));
}

// Track mouse position for glow effect
const glow = document.getElementById('mouse-glow');
document.addEventListener('mousemove', (e) => {
  glow.style.left = e.clientX + 'px';
  glow.style.top = e.clientY + 'px';
});

// High performance smart-city neural network canvas
const canvas = document.getElementById('login-canvas');
const ctx = canvas.getContext('2d');
let particles = [];
const particleCount = 45;
const connectionDistance = 110;
let radarAngle = 0;

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
    this.color = Math.random() > 0.4 ? 'rgba(52, 211, 153, 0.4)' : 'rgba(255, 215, 0, 0.3)'; // Mint & Gold
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
  
  // Draw neural connections
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
  
  // Subtle simulated radar sweep
  radarAngle += 0.003;
  const centerX = canvas.width / 2;
  const centerY = canvas.height / 2;
  const radius = Math.max(canvas.width, canvas.height) * 0.8;
  
  ctx.beginPath();
  ctx.moveTo(centerX, centerY);
  ctx.arc(centerX, centerY, radius, radarAngle, radarAngle + 0.15);
  ctx.closePath();
  ctx.fillStyle = 'rgba(0, 212, 255, 0.015)';
  ctx.fill();
  
  requestAnimationFrame(animateParticles);
}
animateParticles();
</script>
</body>
</html>
