<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List, com.civicfix.model.User, com.civicfix.model.Complaint, com.civicfix.dao.ComplaintDAO, com.civicfix.dao.UserDAO" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    String role = (String) session.getAttribute("role");
    if (currentUser == null) { response.sendRedirect("login.jsp"); return; }
    if ("ADMIN".equals(role)) { response.sendRedirect("admin"); return; }
    if (!"USER".equals(role)) { response.sendRedirect("login.jsp"); return; }
    String safeError = request.getParameter("error") != null
        ? request.getParameter("error").replaceAll("<[^>]*>","") : null;
    String safeMsg = request.getParameter("msg") != null
        ? request.getParameter("msg").replaceAll("<[^>]*>","") : null;
    
    // Load dynamic complaints for the feed
    List<Complaint> feedList = ComplaintDAO.getAllComplaints();
    
    // Load notifications for the logged-in citizen
    List<String> notificationsList = UserDAO.getNotifications(currentUser.getId());

    // Sentinel Level Calculations
    int points = currentUser.getRewardPoints();
    int level = 1;
    String levelTitle = "Novice Sentinel";
    int minPts = 0;
    int maxPts = 50;
    
    if (points > 500) {
        level = 5;
        levelTitle = "Municipal Commandant";
        minPts = 500;
        maxPts = 1000;
    } else if (points > 300) {
        level = 4;
        levelTitle = "Urban Guardian";
        minPts = 300;
        maxPts = 500;
    } else if (points > 150) {
        level = 3;
        levelTitle = "Vanguard Responder";
        minPts = 150;
        maxPts = 300;
    } else if (points > 50) {
        level = 2;
        levelTitle = "District Monitor";
        minPts = 50;
        maxPts = 150;
    }
    
    double progressPct = Math.min(100.0, ((double)(points - minPts) / (maxPts - minPts)) * 100.0);

    // Count user submissions by category for badges
    int roadsCount = 0;
    int waterCount = 0;
    int electricCount = 0;
    int sanitationCount = 0;
    int safetyCount = 0;
    
    if (feedList != null) {
        for (Complaint c : feedList) {
            if (c.getUserId() == currentUser.getId()) {
                String cat = c.getCategory();
                if ("ROADS".equals(cat)) roadsCount++;
                else if ("WATER".equals(cat)) waterCount++;
                else if ("ELECTRIC".equals(cat)) electricCount++;
                else if ("SANITATION".equals(cat)) sanitationCount++;
                else if ("PUBLIC_SAFETY".equals(cat)) safetyCount++;
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>CivicFix — Citizen command hub</title>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Space+Grotesk:wght@500;600;700;800&family=Fira+Code:wght@400;500&display=swap" rel="stylesheet">
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
  overflow: hidden;
  position: relative;
}

/* Background interactive nodes canvas */
#network-canvas {
  position: fixed;
  inset: 0;
  width: 100%;
  height: 100%;
  z-index: 0;
  pointer-events: none;
}

/* Blueprint grid pattern overlay */
.blueprint-grid {
  position: fixed;
  inset: 0;
  background-image: 
    linear-gradient(rgba(52, 211, 153, 0.02) 1px, transparent 1px),
    linear-gradient(90deg, rgba(52, 211, 153, 0.02) 1px, transparent 1px);
  background-size: 60px 60px;
  background-position: center;
  z-index: 1;
  pointer-events: none;
  animation: moveGrid 35s linear infinite;
}
@keyframes moveGrid {
  from { background-position: 0 0; }
  to { background-position: 0 60px; }
}

/* Interactive Cursor Glow */
.cursor-glow {
  position: fixed;
  width: 400px;
  height: 400px;
  border-radius: 50%;
  background: radial-gradient(circle, rgba(52, 211, 153, 0.03) 0%, rgba(16, 185, 129, 0.01) 50%, transparent 100%);
  z-index: 2;
  pointer-events: none;
  transform: translate(-50%, -50%);
  filter: blur(30px);
  opacity: 0;
  transition: opacity 0.3s ease;
}

/* Liquid Glass Cards */
.liquid-glass {
  background: var(--panel-bg);
  backdrop-filter: blur(24px);
  -webkit-backdrop-filter: blur(24px);
  border: 1px solid var(--border-color);
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.2);
  position: relative;
  overflow: hidden;
  transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
}
.liquid-glass::before {
  content: '';
  position: absolute;
  inset: 0;
  border-radius: inherit;
  padding: 1px;
  background: linear-gradient(180deg, rgba(255, 255, 255, 0.08) 0%, transparent 50%, rgba(255, 255, 255, 0.03) 100%);
  -webkit-mask: linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0);
  -webkit-mask-composite: xor;
  mask-composite: exclude;
  pointer-events: none;
}

.liquid-glass-strong {
  background: rgba(17, 24, 39, 0.7);
  backdrop-filter: blur(40px);
  -webkit-backdrop-filter: blur(40px);
  border: 1px solid rgba(255, 255, 255, 0.1);
  box-shadow: 0 15px 45px rgba(0, 0, 0, 0.35);
  position: relative;
  overflow: hidden;
  transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
}
.liquid-glass-strong::before {
  content: '';
  position: absolute;
  inset: 0;
  border-radius: inherit;
  padding: 1.4px;
  background: linear-gradient(180deg, rgba(0, 212, 255, 0.3) 0%, transparent 60%, rgba(99, 102, 241, 0.15) 100%);
  -webkit-mask: linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0);
  -webkit-mask-composite: xor;
  mask-composite: exclude;
  pointer-events: none;
}

/* Page structure */
.page-wrapper {
  position: relative;
  z-index: 10;
  height: 100vh;
  display: flex;
  flex-direction: column;
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
  background: linear-gradient(135deg, var(--accent) 0%, var(--primary) 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 0 12px var(--accent-glow);
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
.topbar-right {
  display: flex;
  align-items: center;
  gap: 20px;
}
.user-badge {
  font-size: 12.5px;
  font-weight: 600;
  padding: 6px 16px;
  border-radius: 20px;
  color: var(--accent);
}
.logout-btn {
  font-size: 12.5px;
  font-weight: 600;
  color: var(--danger);
  text-decoration: none;
  padding: 6px 16px;
  border-radius: 20px;
  background: rgba(244, 63, 94, 0.05);
  border: 1px solid rgba(244, 63, 94, 0.1);
  transition: all 0.2s;
}
.logout-btn:hover {
  background: rgba(244, 63, 94, 0.15);
  box-shadow: 0 0 10px rgba(244, 63, 94, 0.1);
}

/* Layout Grid panels */
.layout {
  flex: 1;
  display: grid;
  grid-template-columns: 390px 1fr 320px;
  gap: 20px;
  padding: 20px 16px 16px;
  height: calc(100vh - 88px);
  overflow: hidden;
}

@media (max-width: 1200px) {
  .layout {
    grid-template-columns: 360px 1fr;
  }
  .sidebar-column {
    display: none;
  }
}

@media (max-width: 768px) {
  .layout {
    grid-template-columns: 1fr;
  }
  .left-column {
    display: none;
  }
}

.column-scroll {
  height: 100%;
  overflow-y: auto;
  padding-right: 4px;
}
.column-scroll::-webkit-scrollbar {
  width: 4px;
}
.column-scroll::-webkit-scrollbar-track {
  background: transparent;
}
.column-scroll::-webkit-scrollbar-thumb {
  background: rgba(255, 255, 255, 0.05);
  border-radius: 2px;
}

/* Staggered load entrances */
.dashboard-content-wrap {
  opacity: 0;
  transform: translateY(15px);
}
.left-column { animation: slideIn 0.8s cubic-bezier(0.16, 1, 0.3, 1) both; animation-delay: 0.1s; }
.feed-column { animation: slideIn 0.8s cubic-bezier(0.16, 1, 0.3, 1) both; animation-delay: 0.2s; }
.sidebar-column { animation: slideIn 0.8s cubic-bezier(0.16, 1, 0.3, 1) both; animation-delay: 0.3s; }

@keyframes slideIn {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}

/* Cards hover float & glow */
.card-panel {
  border-radius: 24px;
  padding: 24px;
  display: flex;
  flex-direction: column;
  flex-shrink: 0;
}
.hover-float:hover {
  transform: translateY(-4px);
  border-color: var(--accent);
  box-shadow: 0 15px 35px rgba(0, 212, 255, 0.15), inset 0 1px 0 rgba(255, 255, 255, 0.1);
}
.hover-float-danger:hover {
  transform: translateY(-4px);
  border-color: var(--danger);
  box-shadow: 0 15px 35px rgba(244, 63, 94, 0.15), inset 0 1px 0 rgba(255, 255, 255, 0.1);
}

.card-title {
  font-family: 'Space Grotesk', sans-serif;
  font-size: 16px;
  font-weight: 600;
  margin-bottom: 20px;
  display: flex;
  align-items: center;
  gap: 10px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.05);
  padding-bottom: 12px;
}

/* Form Styles */
.form-group {
  margin-bottom: 20px;
}
.form-lbl {
  display: block;
  font-size: 10px;
  font-weight: 700;
  text-transform: uppercase;
  color: var(--text-dim);
  letter-spacing: 0.1em;
  margin-bottom: 8px;
}
.form-input {
  width: 100%;
  background: rgba(255, 255, 255, 0.02);
  border: 1px solid rgba(255, 255, 255, 0.05);
  color: #fff;
  padding: 12px 14px;
  font-family: inherit;
  font-size: 13.5px;
  border-radius: 12px;
  outline: none;
  transition: all 0.2s;
}
.form-input:focus {
  border-color: var(--accent);
  background: rgba(255, 255, 255, 0.04);
  box-shadow: 0 0 10px var(--accent-glow);
}
textarea.form-input {
  resize: vertical;
  min-height: 90px;
}

/* Category cards */
.category-cards-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 8px;
}
.cat-card {
  background: rgba(255, 255, 255, 0.02);
  border: 1px solid rgba(255, 255, 255, 0.05);
  border-radius: 12px;
  padding: 10px 4px;
  text-align: center;
  cursor: pointer;
  transition: all 0.2s ease;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 6px;
}
.cat-card:hover {
  background: rgba(255, 255, 255, 0.05);
  border-color: rgba(0, 212, 255, 0.25);
}
.cat-card.active {
  background: rgba(0, 212, 255, 0.08);
  border-color: var(--accent);
  box-shadow: 0 0 12px rgba(0, 212, 255, 0.2);
}
.cat-card-icon {
  font-size: 16px;
}
.cat-card-name {
  font-size: 10px;
  font-weight: 600;
  color: var(--text-muted);
}
.cat-card.active .cat-card-name {
  color: #fff;
}

/* Drag Drop zone */
.drag-drop-zone {
  border: 1.5px dashed rgba(255, 255, 255, 0.08);
  background: rgba(255, 255, 255, 0.01);
  border-radius: 14px;
  padding: 24px;
  text-align: center;
  cursor: pointer;
  position: relative;
  transition: all 0.2s ease;
}
.drag-drop-zone:hover, .drag-drop-zone.dragover {
  border-color: var(--accent);
  background: rgba(0, 212, 255, 0.02);
  box-shadow: 0 0 10px var(--accent-glow);
}
.remove-preview-btn {
  position: absolute;
  top: 10px;
  right: 10px;
  background: var(--danger);
  color: #fff;
  border: none;
  width: 20px;
  height: 20px;
  border-radius: 50%;
  cursor: pointer;
  font-size: 12px;
  line-height: 20px;
  text-align: center;
  padding: 0;
  z-index: 10;
}

/* Location picker card */
.location-picker-card {
  background: rgba(255, 255, 255, 0.02);
  border: 1px solid rgba(255, 255, 255, 0.05);
  border-radius: 12px;
  padding: 12px;
  cursor: pointer;
  transition: all 0.2s;
}
.location-picker-card:hover {
  border-color: var(--accent);
}
.locate-badge {
  font-size: 9px;
  font-weight: 700;
  text-transform: uppercase;
  color: var(--accent);
  background: rgba(0, 212, 255, 0.08);
  padding: 2px 8px;
  border-radius: 6px;
  border: 1px solid rgba(0,212,255,0.15);
}
.mini-map-selector {
  margin-top: 10px;
  background: rgba(5, 8, 20, 0.4);
  border: 1px solid rgba(255, 255, 255, 0.05);
  border-radius: 10px;
  padding: 8px;
}
.mini-map-grid {
  width: 100%;
  height: 100px;
  background: rgba(0,0,0,0.25);
  position: relative;
  border-radius: 6px;
  overflow: hidden;
  cursor: crosshair;
}
.mini-svg {
  width: 100%;
  height: 100%;
}
.mini-map-pin {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: var(--accent);
  box-shadow: 0 0 10px var(--accent);
  position: absolute;
  transform: translate(-50%, -50%);
}

/* Severity calculator */
.severity-calculator-panel {
  background: rgba(255, 255, 255, 0.01);
  border: 1px solid rgba(255, 255, 255, 0.05);
  border-radius: 14px;
  padding: 14px;
}
.slider-row {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 12px;
}
.slider-lbl {
  font-size: 11px;
  color: var(--text-muted);
  width: 90px;
  flex-shrink: 0;
}
.calc-slider {
  flex: 1;
  -webkit-appearance: none;
  background: rgba(255, 255, 255, 0.08);
  height: 4px;
  border-radius: 2px;
  outline: none;
}
.calc-slider::-webkit-slider-thumb {
  -webkit-appearance: none;
  width: 14px;
  height: 14px;
  border-radius: 50%;
  background: var(--accent);
  cursor: pointer;
}
.slider-val {
  font-family: 'Space Grotesk', sans-serif;
  font-size: 12px;
  font-weight: 700;
  width: 20px;
  text-align: right;
}
.calc-result-box {
  border-top: 1px dashed rgba(255, 255, 255, 0.06);
  padding-top: 12px;
  margin-top: 12px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.calc-result-score {
  display: flex;
  align-items: center;
  gap: 8px;
  font-family: 'Space Grotesk', sans-serif;
  font-size: 20px;
  font-weight: 700;
}
.score-class-badge {
  font-size: 9px;
  font-weight: 700;
  text-transform: uppercase;
  padding: 2px 8px;
  border-radius: 6px;
}

.submit-btn {
  width: 100%;
  padding: 14px;
  background: linear-gradient(135deg, var(--accent) 0%, var(--primary) 100%);
  color: #070b14;
  border: none;
  font-family: 'Space Grotesk', sans-serif;
  font-size: 15px;
  font-weight: 800;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.2s ease;
  margin-top: 10px;
  box-shadow: 0 4px 15px var(--accent-glow);
}
.submit-btn:hover {
  background: #33ddff;
  box-shadow: 0 8px 25px rgba(0, 212, 255, 0.4);
  transform: translateY(-1px);
}

/* SVG score circle */
.score-wrapper {
  display: flex;
  justify-content: center;
  margin-bottom: 12px;
}
.score-circle-box {
  position: relative;
  width: 130px;
  height: 130px;
}
.score-svg {
  transform: rotate(-90deg);
  width: 130px;
  height: 130px;
}
.score-track {
  fill: none;
  stroke: rgba(255, 255, 255, 0.03);
  stroke-width: 7;
}
.score-fill {
  fill: none;
  stroke: url(#scoreGradient);
  stroke-width: 7;
  stroke-linecap: round;
  stroke-dasharray: 251.2;
  stroke-dashoffset: 251.2;
  transition: stroke-dashoffset 1.5s cubic-bezier(0.16, 1, 0.3, 1);
}
.score-circle-txt {
  position: absolute;
  inset: 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
}
.score-val-txt {
  font-family: 'Space Grotesk', sans-serif;
  font-size: 30px;
  font-weight: 700;
}
.score-lbl-txt {
  font-size: 9px;
  font-weight: 700;
  text-transform: uppercase;
  color: var(--text-dim);
  letter-spacing: 0.1em;
  margin-top: 4px;
}

/* Alert Boxes */
.alert {
  font-size: 13px;
  padding: 12px 18px;
  border-radius: 12px;
  margin-bottom: 18px;
  display: flex;
  align-items: center;
  gap: 8px;
  font-weight: 500;
}
.alert-error {
  background: rgba(244, 63, 94, 0.08);
  border: 1px solid rgba(244, 63, 94, 0.2);
  color: #fda4af;
}
.alert-success {
  background: rgba(16, 185, 129, 0.08);
  border: 1px solid rgba(16, 185, 129, 0.2);
  color: #6ee7b7;
}

/* Community Feed */
.section-title {
  font-family: 'Space Grotesk', sans-serif;
  font-size: 18px;
  font-weight: 600;
  margin-bottom: 20px;
  display: flex;
  align-items: center;
  gap: 8px;
}
.feed-stream {
  display: flex;
  flex-direction: column;
  gap: 16px;
  padding-bottom: 24px;
}
.feed-card {
  border-radius: 24px;
  padding: 20px;
  display: flex;
  flex-direction: column;
  gap: 14px;
  transition: transform 0.25s cubic-bezier(0.16, 1, 0.3, 1), border-color 0.2s, box-shadow 0.2s;
  cursor: pointer;
}

/* Color Pulse animations */
.pulse-warn-glow {
  animation: pulseWarning 2s infinite;
}
@keyframes pulseWarning {
  0% { box-shadow: 0 0 0 0 rgba(245, 158, 11, 0.25); }
  100% { box-shadow: 0 0 0 10px rgba(245, 158, 11, 0); }
}
.pulse-danger-glow {
  animation: pulseDanger 1.5s infinite;
}
@keyframes pulseDanger {
  0% { box-shadow: 0 0 0 0 rgba(244, 63, 94, 0.35); }
  100% { box-shadow: 0 0 0 12px rgba(244, 63, 94, 0); }
}

.feed-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 12px;
}
.feed-card-title {
  font-family: 'Space Grotesk', sans-serif;
  font-size: 18px;
  font-weight: 700;
  color: #fff;
}
.feed-card-meta {
  font-size: 11px;
  font-weight: 600;
  color: var(--text-dim);
  text-transform: uppercase;
  letter-spacing: 0.05em;
  margin-top: 2px;
}
.badge-row {
  display: flex;
  gap: 8px;
  align-items: center;
}
.cat-tag {
  font-size: 9px;
  font-weight: 700;
  padding: 4px 10px;
  border-radius: 8px;
  letter-spacing: 0.05em;
  text-transform: uppercase;
}
.cat-ROADS { background: rgba(245, 158, 11, 0.08); color: #fbbf24; border: 1px solid rgba(245,158,11,0.12); }
.cat-WATER { background: rgba(14, 165, 233, 0.08); color: #38bdf8; border: 1px solid rgba(14,165,233,0.12); }
.cat-ELECTRIC { background: rgba(168, 85, 247, 0.08); color: #c084fc; border: 1px solid rgba(168,85,247,0.12); }
.cat-SANITATION { background: rgba(16, 185, 129, 0.08); color: #34d399; border: 1px solid rgba(16,185,129,0.12); }
.cat-PUBLIC_SAFETY { background: rgba(244, 63, 94, 0.08); color: #fb7185; border: 1px solid rgba(244,63,94,0.12); }
.cat-OTHER { background: rgba(100, 116, 139, 0.08); color: #94a3b8; border: 1px solid rgba(100,116,139,0.12); }

.status-pill {
  font-size: 10px;
  font-weight: 700;
  display: flex;
  align-items: center;
  gap: 5px;
  padding: 4px 10px;
  border-radius: 20px;
  text-transform: uppercase;
}
.status-OPEN { background: rgba(245, 158, 11, 0.08); color: #fbbf24; border: 1px solid rgba(245,158,11,0.12); }
.status-IN_PROGRESS { background: rgba(99, 102, 241, 0.08); color: #a5b4fc; border: 1px solid rgba(99,102,241,0.12); }
.status-CLOSED { background: rgba(16, 185, 129, 0.08); color: #34d399; border: 1px solid rgba(16,185,129,0.12); }
.status-dot {
  width: 5px;
  height: 5px;
  border-radius: 50%;
  background: currentColor;
}
.status-IN_PROGRESS .status-dot {
  animation: pulseDot 1.5s infinite;
}
@keyframes pulseDot {
  0% { transform: scale(0.9); opacity: 0.7; }
  50% { transform: scale(1.4); opacity: 1; }
  100% { transform: scale(0.9); opacity: 0.7; }
}

.feed-desc {
  font-size: 13.5px;
  color: var(--text-muted);
  line-height: 1.5;
}
.img-wrapper {
  border-radius: 14px;
  overflow: hidden;
  border: 1px solid rgba(255,255,255,0.05);
  background: #000;
}
.evidence-photo {
  width: 100%;
  height: 180px;
  object-fit: cover;
  display: block;
  transition: transform 0.6s ease;
}
.img-wrapper:hover .evidence-photo {
  transform: scale(1.03);
}

.feed-footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
  border-top: 1px solid rgba(255,255,255,0.05);
  padding-top: 12px;
}
.score-badge {
  font-size: 12.5px;
  color: var(--text-muted);
}
.score-badge strong {
  color: #fff;
  font-family: 'Space Grotesk', sans-serif;
  font-weight: 700;
}
.upvote-btn {
  background: rgba(99, 102, 241, 0.1);
  border: 1px solid rgba(99, 102, 241, 0.2);
  color: #a5b4fc;
  padding: 8px 16px;
  border-radius: 10px;
  font-size: 12px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
  display: flex;
  align-items: center;
  gap: 5px;
}
.upvote-btn:hover:not(:disabled) {
  background: var(--primary);
  color: #fff;
}
.upvote-btn:disabled {
  background: rgba(16, 185, 129, 0.1);
  border-color: rgba(16, 185, 129, 0.2);
  color: #34d399;
  cursor: not-allowed;
}

/* Timeline tracking */
.timeline {
  display: flex;
  flex-direction: column;
  gap: 14px;
  position: relative;
  padding-left: 14px;
}
.timeline::before {
  content: '';
  position: absolute;
  left: 4px;
  top: 6px;
  bottom: 6px;
  width: 1px;
  background: rgba(255, 255, 255, 0.08);
}
.timeline-item {
  position: relative;
  font-size: 12.5px;
  line-height: 1.4;
  color: var(--text-muted);
}
.timeline-item::after {
  content: '';
  position: absolute;
  left: -14px;
  top: 5px;
  width: 7px;
  height: 7px;
  border-radius: 50%;
  background: var(--accent);
  box-shadow: 0 0 6px var(--accent);
  border: 1.5px solid var(--bg-dark);
}
.timeline-item:first-child::after {
  background: var(--secondary);
  box-shadow: 0 0 6px var(--secondary);
}

.points-row {
  display: flex;
  justify-content: space-between;
  font-size: 12.5px;
  padding: 8px 0;
  border-bottom: 1px dashed rgba(255,255,255,0.06);
}
.points-row:last-child {
  border: none;
}
.points-val {
  color: var(--secondary);
  font-weight: 600;
}
.info-row {
  display: flex;
  justify-content: space-between;
  padding: 8px 0;
  border-bottom: 1px solid rgba(255,255,255,0.04);
  font-size: 12.5px;
}
.info-row:last-child {
  border: none;
}
.info-key { color: var(--text-dim); }
.info-val { color: #fff; font-weight: 500; }
.lead-link {
  display: block;
  width: 100%;
  text-align: center;
  padding: 10px;
  background: rgba(255, 255, 255, 0.02);
  border: 1px solid rgba(255,255,255,0.05);
  color: var(--accent);
  border-radius: 12px;
  font-size: 12.5px;
  font-weight: 600;
  text-decoration: none;
  transition: all 0.2s;
  margin-top: 12px;
}
.lead-link:hover {
  background: rgba(0, 212, 255, 0.08);
  border-color: var(--accent);
}

/* Badge Icon styles */
.badge-icon {
  width: 38px;
  height: 38px;
  border-radius: 10px;
  background: rgba(255, 255, 255, 0.02);
  border: 1px solid rgba(255, 255, 255, 0.05);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 17px;
  transition: all 0.3s;
  cursor: help;
}
.badge-icon.unlocked {
  background: rgba(0, 212, 255, 0.08);
  border-color: var(--accent);
  box-shadow: 0 0 10px var(--accent-glow);
  filter: drop-shadow(0 0 4px var(--accent-glow));
}
.badge-icon.locked {
  opacity: 0.2;
  filter: grayscale(1);
}

/* Hot Magenta Community Bounty */
.bounty-critical-glow {
  border-color: var(--magenta) !important;
  box-shadow: 0 0 15px rgba(255, 0, 127, 0.15), inset 0 1px 0 rgba(255, 255, 255, 0.1);
  animation: bountyPulse 2s infinite alternate;
}
@keyframes bountyPulse {
  0% { box-shadow: 0 0 8px rgba(255, 0, 127, 0.15); }
  100% { box-shadow: 0 0 18px rgba(255, 0, 127, 0.35); }
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}
</style>
</head>
<body>

<!-- CINEMATIC STARTUP BOOT SCREEN OVERLAY -->
<div id="boot-overlay" style="position: fixed; inset: 0; background: #060a08; z-index: 99999; display: flex; flex-direction: column; align-items: center; justify-content: center; opacity: 1; transition: opacity 0.8s ease;">
  <canvas id="boot-canvas" style="position: absolute; inset: 0; width: 100%; height: 100%; pointer-events: none;"></canvas>
  <div style="position: relative; z-index: 10; display: flex; flex-direction: column; align-items: center; gap: 24px; max-width: 440px; width: 100%; padding: 24px;">
    <div id="boot-logo-container" style="position: relative; display: flex; align-items: center; justify-content: center; height: 110px; width: 100%;">
      <div id="boot-logo-ring" style="position: absolute; width: 90px; height: 90px; border: 2px dashed rgba(0, 212, 255, 0.4); border-radius: 50%; animation: rotateRing 20s linear infinite;"></div>
      <div id="boot-logo" style="font-family: 'Space Grotesk', sans-serif; font-size: 38px; font-weight: 800; letter-spacing: -2px; color: #fff; text-shadow: 0 0 20px rgba(0, 212, 255, 0.5);">CIVIC<span style="color:var(--accent);">FIX</span></div>
    </div>
    <div id="boot-terminal" style="font-family: 'Fira Code', monospace; font-size: 11.5px; color: var(--accent); background: rgba(5, 8, 20, 0.7); border: 1px solid rgba(255, 255, 255, 0.05); padding: 18px; border-radius: 14px; width: 100%; min-height: 160px; line-height: 1.6; box-shadow: 0 10px 30px rgba(0,0,0,0.5);">
      <div id="boot-log-lines"></div>
    </div>
    <div id="boot-progress" style="width: 100%; height: 2px; background: rgba(255, 255, 255, 0.05); border-radius: 1px; overflow: hidden; margin-top: 8px;">
      <div id="boot-progress-bar" style="width: 0%; height: 100%; background: linear-gradient(90deg, var(--accent) 0%, var(--primary) 100%); transition: width 4.3s linear; box-shadow: 0 0 10px var(--accent-glow);"></div>
    </div>
  </div>
</div>

<!-- Smart City neural network background canvas -->
<canvas id="network-canvas"></canvas>
<div class="blueprint-grid"></div>
<div class="cursor-glow" id="mouse-glow"></div>

<div class="page-wrapper">
  <!-- Header row -->
  <div class="topbar liquid-glass-strong">
    <div class="logo-wrap">
      <div class="logo-icon-box">
        <i data-lucide="sparkles" style="color: #fff;"></i>
      </div>
      <span class="logo-text">CIVIC<span>FIX</span></span>
    </div>
    <div class="topbar-right">
      <span class="user-badge liquid-glass">Citizen: <%= currentUser.getUsername() %></span>
      <a href="auth?action=logout" class="logout-btn hover-scale">Logout</a>
    </div>
  </div>

  <!-- Dashboard Content Wrap (Animates after boot) -->
  <div class="layout dashboard-content-wrap" id="dashboard-layout-wrap">
    
    <!-- Left Column: Report Card form -->
    <div class="column-scroll left-column">
      <div class="card-panel liquid-glass-strong hover-float">
        <div class="card-title">
          <i data-lucide="alert-triangle" style="width: 16px; height: 16px; color:var(--accent);"></i>
          <span>File New Telemetry Report</span>
        </div>
        
        <% if (safeError != null) { %>
          <div class="alert alert-error">
            <i data-lucide="x-circle" style="width:16px; height:16px;"></i>
            <span><%= safeError %></span>
          </div>
        <% } %>
        <% if (safeMsg != null) { %>
          <div class="alert alert-success">
            <i data-lucide="check-circle" style="width:16px; height:16px;"></i>
            <span><%= safeMsg %></span>
          </div>
        <% } %>
        
        <form action="SubmitComplaintServlet" method="POST" enctype="multipart/form-data" id="complaint-form">
          <input type="hidden" name="category" id="selected-category" value="ROADS">
          <input type="hidden" name="severity_score" id="severity-score-val" value="50">
          <input type="hidden" id="location-coords" value="">
          
          <div class="form-group">
            <label class="form-lbl">Issue Title</label>
            <input class="form-input" type="text" name="title" placeholder="e.g. Broken water mains flooding street" required>
          </div>
          
          <!-- Category Cards Selection -->
          <div class="form-group">
            <label class="form-lbl">Select Category</label>
            <div class="category-cards-grid">
              <div class="cat-card active" data-val="ROADS" onclick="selectCategory('ROADS')">
                <span class="cat-card-icon">🛣</span>
                <span class="cat-card-name">Roads</span>
              </div>
              <div class="cat-card" data-val="WATER" onclick="selectCategory('WATER')">
                <span class="cat-card-icon">💧</span>
                <span class="cat-card-name">Water</span>
              </div>
              <div class="cat-card" data-val="ELECTRIC" onclick="selectCategory('ELECTRIC')">
                <span class="cat-card-icon">🔌</span>
                <span class="cat-card-name">Electricity</span>
              </div>
              <div class="cat-card" data-val="SANITATION" onclick="selectCategory('SANITATION')">
                <span class="cat-card-icon">🧹</span>
                <span class="cat-card-name">Sanitation</span>
              </div>
              <div class="cat-card" data-val="PUBLIC_SAFETY" onclick="selectCategory('PUBLIC_SAFETY')">
                <span class="cat-card-icon">🚨</span>
                <span class="cat-card-name">Safety</span>
              </div>
              <div class="cat-card" data-val="OTHER" onclick="selectCategory('OTHER')">
                <span class="cat-card-icon">⚙</span>
                <span class="cat-card-name">Other</span>
              </div>
            </div>
          </div>
          
          <div class="form-group">
            <label class="form-lbl">Detailed Description</label>
            <textarea class="form-input" name="description" placeholder="Specify location and damage parameters..." required></textarea>
          </div>
          
          <!-- AI Telemetry HUD -->
          <div class="form-group" id="ai-hud-container" style="display:none;">
            <div class="severity-calculator-panel" style="border-color: rgba(0, 212, 255, 0.2); background: rgba(0, 212, 255, 0.02); position: relative; overflow: hidden;">
              <div class="radar-sweep-line" style="background: linear-gradient(90deg, rgba(0, 212, 255, 0.08) 0%, rgba(0, 212, 255, 0) 50%); animation-duration: 4s;"></div>
              <div style="font-size:9px; font-weight:700; color:var(--accent); text-transform:uppercase; letter-spacing:0.5px; display:flex; align-items:center; gap:6px; margin-bottom:8px;">
                <i data-lucide="cpu" style="width:12px; height:12px; animation: spin 4s linear infinite;"></i>
                <span>AI Telemetry Diagnostics</span>
              </div>
              <div id="ai-diagnostic-status" style="font-family:'Fira Code', monospace; font-size:10.5px; color:var(--text-muted); line-height:1.5; margin-bottom:10px;">
                Analyzing description text...
              </div>
              <div style="display:flex; justify-content:space-between; align-items:center;">
                <div style="font-size:11px; color:var(--text-dim);">Match Confidence: <span id="ai-confidence" style="color:#fff; font-weight:600;">0%</span></div>
                <button type="button" id="accept-ai-btn" class="upvote-btn hover-scale" style="padding: 4px 10px; font-size: 10px; display:none;" onclick="acceptAiTelemetry()">
                  <span>Apply AI Telemetry</span>
                </button>
              </div>
            </div>
          </div>
          
          <!-- Location coordinates simulated selector -->
          <div class="form-group">
            <label class="form-lbl">GPS Telemetry Location</label>
            <div class="location-picker-card" onclick="toggleLocationPicker()">
              <div style="display:flex; justify-content:space-between; align-items:center;">
                <div style="display:flex; align-items:center; gap:8px;">
                  <i data-lucide="map-pin" style="width:14px; height:14px; color:var(--accent);"></i>
                  <span id="coords-text" style="font-size:12px; font-weight:600;">Tap to Pin coordinates</span>
                </div>
                <span class="locate-badge">Simulate GPS</span>
              </div>
              
              <div id="mini-map-selector" class="mini-map-selector" style="display:none;" onclick="event.stopPropagation()">
                <div class="mini-map-grid" id="mini-map-grid" onclick="pickCoordinates(event)">
                  <svg class="mini-svg" viewBox="0 0 300 100">
                    <path d="M 0 25 L 300 25" stroke="rgba(255,255,255,0.05)" stroke-width="1"/>
                    <path d="M 0 50 L 300 50" stroke="rgba(255,255,255,0.05)" stroke-width="1"/>
                    <path d="M 0 75 L 300 75" stroke="rgba(255,255,255,0.05)" stroke-width="1"/>
                    <path d="M 60 0 L 60 100" stroke="rgba(255,255,255,0.05)" stroke-width="1"/>
                    <path d="M 150 0 L 150 100" stroke="rgba(255,255,255,0.05)" stroke-width="1"/>
                    <path d="M 240 0 L 240 100" stroke="rgba(255,255,255,0.05)" stroke-width="1"/>
                  </svg>
                  <div id="mini-map-pin" class="mini-map-pin" style="display:none;"></div>
                </div>
                <div style="font-size: 8px; color:var(--text-dim); text-align:center; margin-top:6px; text-transform:uppercase;">Click Grid to Mark Spot</div>
              </div>
            </div>
          </div>
          
          <!-- Image Drag and Drop Zone -->
          <div class="form-group">
            <label class="form-lbl">Evidence Photo</label>
            <div class="drag-drop-zone" id="drop-zone" ondragover="handleDragOver(event)" ondragleave="handleDragLeave(event)" ondrop="handleDrop(event)" onclick="triggerFileInput()">
              <input class="file-upload-input" type="file" name="image" id="file-input" accept="image/png,image/jpeg" onchange="handleFileSelect(this)" style="display:none;">
              <div class="drop-zone-content" id="drop-content">
                <i data-lucide="upload-cloud" style="width: 24px; height: 24px; color: var(--accent); margin-bottom: 6px;"></i>
                <div style="font-size: 11.5px; font-weight: 600; margin-bottom: 2px;">Drag & Drop Image Here</div>
                <div style="font-size: 9.5px; color: var(--text-dim);">or click to browse</div>
              </div>
              <div class="drop-zone-preview" id="drop-preview" style="display:none; position:relative;">
                <img id="preview-img" src="" style="max-width:100%; height:90px; object-fit:contain; border-radius:8px;">
                <button type="button" class="remove-preview-btn" onclick="clearFileSelection(event)">&times;</button>
                <div id="preview-filename" style="font-size:10px; margin-top:6px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;">filename.png</div>
              </div>
            </div>
          </div>
          
          <!-- Severity Live Score Calculator widget -->
          <div class="form-group">
            <label class="form-lbl">Live Severity Score Calculator</label>
            <div class="severity-calculator-panel">
              <div class="slider-row">
                <span class="slider-lbl">Public Impact</span>
                <input type="range" class="calc-slider" id="impact-slider" min="1" max="10" value="5" oninput="calculateSeverity()">
                <span class="slider-val" id="impact-display">5</span>
              </div>
              <div class="slider-row">
                <span class="slider-lbl">Direct Hazard</span>
                <input type="range" class="calc-slider" id="danger-slider" min="1" max="10" value="5" oninput="calculateSeverity()">
                <span class="slider-val" id="danger-display">5</span>
              </div>
              
              <div class="calc-result-box">
                <div style="font-size:9px; font-weight:700; color:var(--text-dim); text-transform:uppercase; letter-spacing:0.5px;">Calculated Urgency</div>
                <div class="calc-result-score">
                  <span id="calculated-score">50</span>
                  <span class="score-class-badge" id="score-class-badge" style="color:var(--warn); background:rgba(245,158,11,0.08);">Medium</span>
                </div>
              </div>
            </div>
          </div>
          
          <button type="submit" class="submit-btn hover-scale">Submit Telemetry Report &nbsp; →</button>
        </form>
      </div>
    </div>

    <!-- Middle Column: Community Feed stream -->
    <div class="column-scroll feed-column">
      <div class="section-title">
        <i data-lucide="activity" style="width: 18px; height: 18px; color:var(--accent);"></i>
        <span>Live City Operations Feed</span>
      </div>
      <div class="feed-stream">
        <% if (feedList == null || feedList.isEmpty()) { %>
          <div class="liquid-glass" style="text-align: center; color: var(--text-dim); padding: 48px; border-radius: 20px;">
            // No telemetry logs found in municipal network
          </div>
        <% } else {
            for (Complaint c : feedList) {
                // Determine pulse glow based on severity
                String cardPulseClass = "";
                if (!"CLOSED".equals(c.getStatus())) {
                    if (c.getSeverityScore() > 80) cardPulseClass = "pulse-danger-glow hover-float-danger";
                    else if (c.getSeverityScore() > 50) cardPulseClass = "pulse-warn-glow hover-float";
                    else cardPulseClass = "hover-float";
                } else {
                    cardPulseClass = "hover-float";
                }
                if (c.getBountyPool() >= 50) {
                    cardPulseClass += " bounty-critical-glow";
                }
        %>
          <div class="feed-card liquid-glass <%= cardPulseClass %>" onclick="location.href='complaint-details.jsp?id=<%= c.getId() %>'">
            <div class="feed-header">
              <div>
                <div class="feed-card-title"><%= c.getTitle() %></div>
                <div class="feed-card-meta">Incident ID: #<%= c.getId() %></div>
              </div>
              <div class="badge-row">
                <% if (c.getBountyPool() >= 50) { %>
                  <span class="cat-tag" style="background:rgba(255,0,127,0.12); color:#ff3399; border:1px solid rgba(255,0,127,0.25);">Community Bounty</span>
                <% } %>
                <span class="cat-tag cat-<%= c.getCategory() %>"><%= c.getCategory() %></span>
                <span class="status-pill status-<%= c.getStatus() %>">
                  <span class="status-dot"></span>
                  <span><%= c.getStatus().replace("_", " ") %></span>
                </span>
              </div>
            </div>

            <div class="feed-desc"><%= c.getDescription() %></div>

            <% if (c.getImagePath() != null && !c.getImagePath().isEmpty()) { %>
              <div class="img-wrapper">
                <img src="<%= c.getImagePath() %>" class="evidence-photo" alt="Incident Evidence">
              </div>
            <% } %>

            <div class="feed-footer" onclick="event.stopPropagation()">
              <div class="score-badge" style="display:flex; flex-direction:column; gap:2px;">
                <div>Severity Score: <strong id="score-val-<%= c.getId() %>"><%= c.getSeverityScore() %></strong></div>
                <div style="font-size:10.5px; color:var(--text-dim); display:flex; align-items:center; gap:4px;">
                  <i data-lucide="award" style="width:11px; height:11px; color:var(--magenta);"></i>
                  <span>Bounty: <strong id="bounty-val-<%= c.getId() %>" style="color:var(--magenta); font-family:'Space Grotesk', sans-serif;"><%= c.getBountyPool() %> PTS</strong></span>
                </div>
              </div>
              <% if (!"CLOSED".equals(c.getStatus())) { %>
                <div style="display:flex; gap:8px;">
                  <button type="button" class="upvote-btn hover-scale" onclick="upvoteIncident(<%= c.getId() %>, this)">
                    <i data-lucide="wand-2" style="width: 13px; height: 13px;"></i>
                    <span>Upvote</span>
                  </button>
                  <button type="button" class="upvote-btn hover-scale" style="background:rgba(255, 0, 127, 0.08); border-color:rgba(255, 0, 127, 0.15); color:#ff3399;" onclick="backBounty(<%= c.getId() %>, this)">
                    <i data-lucide="coins" style="width: 13px; height: 13px;"></i>
                    <span>Back (+10)</span>
                  </button>
                </div>
              <% } else { %>
                <span style="color: var(--secondary); font-size: 12.5px; font-weight: 600; display: flex; align-items: center; gap: 4px;">
                  Resolved ✓
                </span>
              <% } %>
            </div>
          </div>
        <% } } %>
      </div>
    </div>

    <!-- Right Sidebar Column: Stats and updates -->
    <div class="column-scroll sidebar-column" style="display: flex; flex-direction: column; gap: 15px;">
      
      <!-- Tab Selector -->
      <div class="liquid-glass-strong" style="display:flex; padding:4px; border-radius:14px; border-color:rgba(255,255,255,0.06);">
        <button id="tab-hud-btn" class="filter-pill active" style="flex:1; border-radius:10px; font-size:11px; padding:8px;" onclick="switchSidebarTab('hud')">Sentinel HUD</button>
        <button id="tab-shop-btn" class="filter-pill" style="flex:1; border-radius:10px; font-size:11px; padding:8px;" onclick="switchSidebarTab('shop')">Rewards Shop</button>
      </div>

      <!-- TAB 1: SENTINEL HUD CONTAINER -->
      <div id="sidebar-hud-content" style="display: flex; flex-direction: column; gap: 15px; flex-shrink: 0;">
        <!-- Score Circle -->
        <div class="card-panel liquid-glass-strong hover-float">
          <div class="card-title">Civic Contribution</div>
          <div class="score-wrapper">
            <div class="score-circle-box">
              <svg class="score-svg" viewBox="0 0 100 100">
                <defs>
                  <linearGradient id="scoreGradient" x1="0%" y1="0%" x2="100%" y2="100%">
                    <stop offset="0%" stop-color="#00D4FF" />
                    <stop offset="100%" stop-color="#6366f1" />
                  </linearGradient>
                </defs>
                <circle class="score-track" cx="50" cy="50" r="40"></circle>
                <circle class="score-fill" id="score-circle-fill" cx="50" cy="50" r="40" data-score="<%= currentUser.getRewardPoints() %>"></circle>
              </svg>
              <div class="score-circle-txt">
                <span class="score-val-txt" id="civic-points-val" data-target="<%= currentUser.getRewardPoints() %>">0</span>
                <span class="score-lbl-txt">Points</span>
              </div>
            </div>
          </div>
          
          <!-- Level & XP progress -->
          <div style="margin-top: 10px; border-top: 1px dashed rgba(255,255,255,0.05); padding-top:12px;">
            <div style="display:flex; justify-content:space-between; align-items:center; font-size:11px; margin-bottom:6px;">
              <span style="font-weight:600; color:var(--accent);">Level <%= level %> — <%= levelTitle %></span>
              <span style="color:var(--text-dim);"><%= points %> / <%= maxPts %> PTS</span>
            </div>
            <div style="width:100%; height:5px; background:rgba(255,255,255,0.05); border-radius:3px; overflow:hidden; border:1px solid rgba(255,255,255,0.02);">
              <div style="width:<%= progressPct %>%; height:100%; background:linear-gradient(90deg, var(--accent) 0%, var(--primary) 100%);"></div>
            </div>
          </div>
          
          <!-- Grid Badges -->
          <div style="margin-top: 16px;">
            <div style="font-size:9.5px; font-weight:700; color:var(--text-dim); text-transform:uppercase; letter-spacing:0.8px; margin-bottom:8px;">Tactical Badges</div>
            <div style="display:flex; gap:6px; justify-content:space-between;">
              <div class="badge-icon <%= roadsCount > 0 ? "unlocked" : "locked" %>" title="Road Warrior (Filed roads incident)">🛣</div>
              <div class="badge-icon <%= waterCount > 0 ? "unlocked" : "locked" %>" title="Hydro-Vigilante (Filed water incident)">💧</div>
              <div class="badge-icon <%= electricCount > 0 ? "unlocked" : "locked" %>" title="Grid Restorer (Filed electric incident)">🔌</div>
              <div class="badge-icon <%= sanitationCount > 0 ? "unlocked" : "locked" %>" title="Sanitation Squad (Filed sanitation incident)">🧹</div>
              <div class="badge-icon <%= safetyCount > 0 ? "unlocked" : "locked" %>" title="Vanguard (Filed safety incident)">🚨</div>
            </div>
          </div>

          <a href="leaderboard.jsp" class="lead-link hover-scale" style="margin-top:16px;">View Leaderboard</a>
        </div>

        <!-- Live tracker updates -->
        <div class="card-panel liquid-glass-strong hover-float">
          <div class="card-title">
            <i data-lucide="bell" style="width: 16px; height: 16px; color:var(--accent);"></i>
            <span>Live Tracking</span>
          </div>
          <div class="timeline">
            <% if (notificationsList == null || notificationsList.isEmpty()) { %>
              <div class="empty-notifications" style="font-size:11px; color:var(--text-dim); text-align:center;">No telemetry updates yet.</div>
            <% } else {
                for (String notif : notificationsList) {
            %>
              <div class="timeline-item"><%= notif %></div>
            <% } } %>
          </div>
        </div>

        <!-- Guide perks -->
        <div class="card-panel liquid-glass-strong hover-float">
          <div class="card-title">Reward Metrics</div>
          <div class="points-row"><span>Log verified issue</span><span class="points-val">+10 PTS</span></div>
          <div class="points-row"><span>Closed by dispatcher</span><span class="points-val">+50 PTS</span></div>
          <div class="points-row"><span>Critical fix reward</span><span class="points-val">+25 PTS</span></div>
        </div>

        <!-- Profile details -->
        <div class="card-panel liquid-glass-strong hover-float">
          <div class="card-title">Citizen Profile</div>
          <div class="info-row"><span class="info-key">User ID</span><span class="info-val">#<%= currentUser.getId() %></span></div>
          <div class="info-row"><span class="info-key">Username</span><span class="info-val"><%= currentUser.getUsername() %></span></div>
          <div class="info-row"><span class="info-key">Email</span><span class="info-val"><%= currentUser.getEmail() %></span></div>
        </div>
      </div>

      <!-- TAB 2: REWARDS SHOP CONTAINER -->
      <div id="sidebar-shop-content" style="display: none; flex-direction: column; gap: 15px; flex-shrink: 0;">
        <div class="card-panel liquid-glass-strong hover-float">
          <div class="card-title">
            <i data-lucide="shopping-bag" style="width: 16px; height: 16px; color:var(--magenta);"></i>
            <span>Municipal Perks Store</span>
          </div>
          <div style="font-size:12px; color:var(--text-muted); margin-bottom:16px;">
            Redeem your hard-earned civic contribution points for premium municipal utility tokens.
          </div>
          
          <div style="display:flex; flex-direction:column; gap:12px;">
            <!-- Item 1 -->
            <div class="liquid-glass" style="padding:16px; border-radius:16px; border-color:rgba(255,255,255,0.06);">
              <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:6px;">
                <span style="font-weight:600; font-size:13px; color:#fff;">☀️ Solar Utility Credit</span>
                <span style="font-size:11px; font-weight:700; color:var(--accent);">50 PTS</span>
              </div>
              <div style="font-size:10.5px; color:var(--text-dim); line-height:1.4; margin-bottom:12px;">
                Apply a $15 credit directly to your smart-grid solar electricity bill.
              </div>
              <button type="button" class="upvote-btn hover-scale" style="width:100%; justify-content:center;" onclick="claimReward('SOLAR_CREDIT', this)">
                Claim Voucher
              </button>
            </div>
            
            <!-- Item 2 -->
            <div class="liquid-glass" style="padding:16px; border-radius:16px; border-color:rgba(255,255,255,0.06);">
              <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:6px;">
                <span style="font-weight:600; font-size:13px; color:#fff;">🚇 Transit Hyperpass</span>
                <span style="font-size:11px; font-weight:700; color:var(--accent);">100 PTS</span>
              </div>
              <div style="font-size:10.5px; color:var(--text-dim); line-height:1.4; margin-bottom:12px;">
                Receive a 7-day unlimited pass for the autonomous monorail and hyperloop network.
              </div>
              <button type="button" class="upvote-btn hover-scale" style="width:100%; justify-content:center;" onclick="claimReward('TRANSIT_PASS', this)">
                Claim Voucher
              </button>
            </div>
            
            <!-- Item 3 -->
            <div class="liquid-glass" style="padding:16px; border-radius:16px; border-color:rgba(255,255,255,0.06);">
              <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:6px;">
                <span style="font-weight:600; font-size:13px; color:#fff;">🔋 EV Charging Voucher</span>
                <span style="font-size:11px; font-weight:700; color:var(--accent);">150 PTS</span>
              </div>
              <div style="font-size:10.5px; color:var(--text-dim); line-height:1.4; margin-bottom:12px;">
                Unlock a rapid-charging session (50kWh) at any city smart charging hub.
              </div>
              <button type="button" class="upvote-btn hover-scale" style="width:100%; justify-content:center;" onclick="claimReward('EV_VOUCHER', this)">
                Claim Voucher
              </button>
            </div>
          </div>
        </div>
      </div>
      
    </div>
  </div>
</div>

<script>
function switchSidebarTab(tab) {
  const hudBtn = document.getElementById('tab-hud-btn');
  const shopBtn = document.getElementById('tab-shop-btn');
  const hudContent = document.getElementById('sidebar-hud-content');
  const shopContent = document.getElementById('sidebar-shop-content');
  
  if (tab === 'hud') {
    hudBtn.classList.add('active');
    shopBtn.classList.remove('active');
    hudContent.style.display = 'flex';
    shopContent.style.display = 'none';
  } else {
    hudBtn.classList.remove('active');
    shopBtn.classList.add('active');
    hudContent.style.display = 'none';
    shopContent.style.display = 'flex';
  }
}

function claimReward(itemId, btn) {
  if (btn.disabled) return;
  btn.disabled = true;
  const originalText = btn.innerHTML;
  btn.textContent = "Processing...";
  
  const xhr = new XMLHttpRequest();
  xhr.open("POST", "RedeemServlet", true);
  xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
  xhr.onreadystatechange = function() {
    if (xhr.readyState === 4) {
      if (xhr.status === 200) {
        const res = JSON.parse(xhr.responseText);
        
        // Update user points dials
        const ptsEl = document.getElementById('civic-points-val');
        if (ptsEl) {
          ptsEl.textContent = res.userPoints;
          ptsEl.dataset.target = res.userPoints;
        }
        
        // Redraw dial
        const circle = document.getElementById('score-circle-fill');
        if (circle) {
          circle.dataset.score = res.userPoints;
          const maxPoints = 300;
          const percentage = Math.min(res.userPoints / maxPoints, 1);
          const circumference = 2 * Math.PI * 40;
          const offset = circumference - (percentage * circumference);
          circle.style.strokeDashoffset = offset;
        }
        
        // Show success code
        btn.innerHTML = `<span style="color:var(--secondary);">Claimed!</span>`;
        alert("🎉 Success! Redeem Code: " + res.promoCode + "\nIt has been logged in your notification feed.");
        
        setTimeout(() => {
          location.reload();
        }, 1500);
      } else {
        alert(xhr.responseText || "Redemption failed.");
        btn.disabled = false;
        btn.innerHTML = originalText;
      }
    }
  };
  xhr.send("itemId=" + encodeURIComponent(itemId));
}

function backBounty(complaintId, btn) {
  if (btn.disabled) return;
  btn.disabled = true;
  const originalText = btn.innerHTML;
  btn.textContent = "Backing...";
  
  const xhr = new XMLHttpRequest();
  xhr.open("POST", "BountyServlet", true);
  xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
  xhr.onreadystatechange = function() {
    if (xhr.readyState === 4) {
      if (xhr.status === 200) {
        const res = JSON.parse(xhr.responseText);
        
        // Update user points on HUD
        const ptsEl = document.getElementById('civic-points-val');
        if (ptsEl) {
          ptsEl.textContent = res.userPoints;
          ptsEl.dataset.target = res.userPoints;
        }
        
        // Redraw dial
        const circle = document.getElementById('score-circle-fill');
        if (circle) {
          circle.dataset.score = res.userPoints;
          const maxPoints = 300;
          const percentage = Math.min(res.userPoints / maxPoints, 1);
          const circumference = 2 * Math.PI * 40;
          const offset = circumference - (percentage * circumference);
          circle.style.strokeDashoffset = offset;
        }
        
        // Update Bounty Pool stat on card
        const bountyEl = document.getElementById("bounty-val-" + complaintId);
        if (bountyEl) {
          bountyEl.textContent = res.newBounty + " PTS";
          
          bountyEl.style.transform = 'scale(1.3)';
          bountyEl.style.transition = 'all 0.2s';
          setTimeout(() => {
            bountyEl.style.transform = 'scale(1)';
          }, 300);
        }
        
        btn.innerHTML = `<span>Backed ✓</span>`;
        btn.style.background = "rgba(16, 185, 129, 0.15)";
        btn.style.borderColor = "rgba(16, 185, 129, 0.3)";
        btn.style.color = "#34d399";
        
        if (res.newBounty >= 50) {
          setTimeout(() => { location.reload(); }, 1500);
        }
      } else {
        alert(xhr.responseText || "Failed to back issue.");
        btn.disabled = false;
        btn.innerHTML = originalText;
      }
    }
  };
  xhr.send("complaintId=" + encodeURIComponent(complaintId));
}

// AI Diagnostic rule-based classifier
let predictedCat = "OTHER";
let predictedSeverity = 50;
let confidence = 50;

function runAiClassifier(text) {
  const lower = text.toLowerCase();
  
  let roadScore = 0;
  let waterScore = 0;
  let electricScore = 0;
  let sanitationScore = 0;
  let safetyScore = 0;
  
  const roadKeys = ["road", "pothole", "asphalt", "concrete", "pavement", "crack", "sinkhole", "highway", "driveway", "lane", "street", "caving", "landslide"];
  roadKeys.forEach(k => { if (lower.includes(k)) roadScore += 30; });
  
  const waterKeys = ["water", "leak", "pipe", "burst", "flooding", "flood", "sew", "drain", "drip", "puddle", "overflow"];
  waterKeys.forEach(k => { if (lower.includes(k)) waterScore += 30; });
  
  const electricKeys = ["electrical", "wire", "spark", "power", "blackout", "outage", "transformer", "darkness", "light", "fuse"];
  electricKeys.forEach(k => { if (lower.includes(k)) electricScore += 30; });
  
  const sanitationKeys = ["garbage", "trash", "litter", "waste", "dump", "odor", "smell", "bin", "refuse", "debris", "sweep"];
  sanitationKeys.forEach(k => { if (lower.includes(k)) sanitationScore += 30; });
  
  const safetyKeys = ["danger", "fire", "smoke", "accident", "emergency", "crime", "threat", "hazard", "injury", "crash", "block"];
  safetyKeys.forEach(k => { if (lower.includes(k)) safetyScore += 30; });
  
  const scores = [
    { cat: "ROADS", val: roadScore },
    { cat: "WATER", val: waterScore },
    { cat: "ELECTRIC", val: electricScore },
    { cat: "SANITATION", val: sanitationScore },
    { cat: "PUBLIC_SAFETY", val: safetyScore }
  ];
  
  scores.sort((a,b) => b.val - a.val);
  const best = scores[0];
  
  if (best.val > 0) {
    predictedCat = best.cat;
    confidence = Math.min(95, 40 + (best.val / 2));
  } else {
    predictedCat = "OTHER";
    confidence = 50;
  }
  
  let baseSev = 35;
  const criticalKeys = ["severe", "dangerous", "critical", "emergency", "immediate", "hazard", "sparking", "fire", "flooding", "burst", "sinkhole", "landslide"];
  criticalKeys.forEach(k => { if (lower.includes(k)) baseSev += 20; });
  
  const minorKeys = ["minor", "small", "little", "mild", "cosmetic", "slow"];
  minorKeys.forEach(k => { if (lower.includes(k)) baseSev -= 15; });
  
  predictedSeverity = Math.max(10, Math.min(100, baseSev));
  
  const catLabels = {
    "ROADS": "Roads 🛣",
    "WATER": "Water 💧",
    "ELECTRIC": "Electricity 🔌",
    "SANITATION": "Sanitation 🧹",
    "PUBLIC_SAFETY": "Safety 🚨",
    "OTHER": "Other ⚙"
  };
  
  const statusEl = document.getElementById('ai-diagnostic-status');
  if (statusEl) {
    statusEl.innerHTML = 
      `[AI AUTO-TELEMETRY] Analysis Completed.<br>` +
      `Recommended Category: <span style="color:var(--accent); font-weight:600;">` + catLabels[predictedCat] + `</span><br>` +
      `Recommended Severity Score: <span style="color:var(--magenta); font-weight:600;">` + predictedSeverity + `</span>`;
  }
  
  const confEl = document.getElementById('ai-confidence');
  if (confEl) confEl.textContent = confidence.toFixed(0) + "%";
  
  const btn = document.getElementById('accept-ai-btn');
  if (btn) btn.style.display = 'block';
}

function acceptAiTelemetry() {
  selectCategory(predictedCat);
  const sliderVal = Math.round(predictedSeverity / 10);
  const impactSlider = document.getElementById('impact-slider');
  const dangerSlider = document.getElementById('danger-slider');
  if (impactSlider) impactSlider.value = sliderVal;
  if (dangerSlider) dangerSlider.value = sliderVal;
  calculateSeverity();
  
  const container = document.getElementById('ai-hud-container');
  if (container) {
    container.style.transition = 'all 0.1s';
    container.style.opacity = '0.3';
    setTimeout(() => {
      container.style.opacity = '1';
      const statusEl = document.getElementById('ai-diagnostic-status');
      if (statusEl) statusEl.innerHTML = `<span style="color:var(--secondary);">✔️ Telemetry accepted and applied.</span>`;
      const btn = document.getElementById('accept-ai-btn');
      if (btn) btn.style.display = 'none';
    }, 150);
  }
}

// Track mouse coordinates for premium cursor trail glow
const glow = document.getElementById('mouse-glow');
document.addEventListener('mousemove', (e) => {
  glow.style.opacity = '1';
  glow.style.left = e.clientX + 'px';
  glow.style.top = e.clientY + 'px';
});
document.addEventListener('mouseleave', () => {
  glow.style.opacity = '0';
});

// Category selection helper
function selectCategory(categoryVal) {
  document.getElementById('selected-category').value = categoryVal;
  document.querySelectorAll('.cat-card').forEach(card => {
    card.classList.remove('active');
  });
  const target = document.querySelector('.cat-card[data-val="' + categoryVal + '"]');
  if (target) target.classList.add('active');
}

// Drag & Drop Image Handlers
function triggerFileInput() {
  document.getElementById('file-input').click();
}

function handleDragOver(e) {
  e.preventDefault();
  document.getElementById('drop-zone').classList.add('dragover');
}

function handleDragLeave(e) {
  e.preventDefault();
  document.getElementById('drop-zone').classList.remove('dragover');
}

function handleDrop(e) {
  e.preventDefault();
  const dz = document.getElementById('drop-zone');
  dz.classList.remove('dragover');
  
  if (e.dataTransfer.files && e.dataTransfer.files[0]) {
    const fileInput = document.getElementById('file-input');
    fileInput.files = e.dataTransfer.files;
    handleFileSelect(fileInput);
  }
}

function handleFileSelect(input) {
  const preview = document.getElementById('drop-preview');
  const content = document.getElementById('drop-content');
  const previewImg = document.getElementById('preview-img');
  const filename = document.getElementById('preview-filename');
  
  if (input.files && input.files[0]) {
    const file = input.files[0];
    filename.textContent = file.name;
    
    const reader = new FileReader();
    reader.onload = function(e) {
      previewImg.src = e.target.result;
      content.style.display = 'none';
      preview.style.display = 'block';
    }
    reader.readAsDataURL(file);
  }
}

function clearFileSelection(e) {
  e.stopPropagation();
  const fileInput = document.getElementById('file-input');
  fileInput.value = '';
  document.getElementById('drop-preview').style.display = 'none';
  document.getElementById('drop-content').style.display = 'block';
}

// Location Selector simulated map
function toggleLocationPicker() {
  const picker = document.getElementById('mini-map-selector');
  if (picker.style.display === 'none') {
    picker.style.display = 'block';
  } else {
    picker.style.display = 'none';
  }
}

function pickCoordinates(e) {
  const grid = document.getElementById('mini-map-grid');
  const pin = document.getElementById('mini-map-pin');
  
  const rect = grid.getBoundingClientRect();
  const x = Math.round(e.clientX - rect.left);
  const y = Math.round(e.clientY - rect.top);
  
  pin.style.left = x + 'px';
  pin.style.top = y + 'px';
  pin.style.display = 'block';
  
  document.getElementById('location-coords').value = 'X: ' + x + ', Y: ' + y;
  document.getElementById('coords-text').textContent = 'Pinned: Sector [' + x + ', ' + y + ']';
}

// Severity Live Calculator
function calculateSeverity() {
  const impactVal = parseInt(document.getElementById('impact-slider').value);
  const dangerVal = parseInt(document.getElementById('danger-slider').value);
  
  document.getElementById('impact-display').textContent = impactVal;
  document.getElementById('danger-display').textContent = dangerVal;
  
  const score = Math.round((impactVal * 4) + (dangerVal * 6));
  document.getElementById('calculated-score').textContent = score;
  document.getElementById('severity-score-val').value = score;
  
  const badge = document.getElementById('score-class-badge');
  if (score > 80) {
    badge.textContent = "Critical";
    badge.style.color = "var(--danger)";
    badge.style.background = "rgba(244, 63, 94, 0.08)";
  } else if (score > 50) {
    badge.textContent = "High";
    badge.style.color = "var(--warn)";
    badge.style.background = "rgba(245, 158, 11, 0.08)";
  } else {
    badge.textContent = "Routine";
    badge.style.color = "var(--accent)";
    badge.style.background = "rgba(0, 212, 255, 0.08)";
  }
}

// Upvote AJAX
function upvoteIncident(complaintId, btn) {
  btn.disabled = true;
  btn.querySelector('span').textContent = "Escalating...";
  
  const xhr = new XMLHttpRequest();
  xhr.open("POST", "VoteServlet", true);
  xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
  xhr.onreadystatechange = function() {
    if (xhr.readyState === 4) {
      if (xhr.status === 200 || xhr.status === 302) {
        const scoreEl = document.getElementById("score-val-" + complaintId);
        if (scoreEl) {
          const currentScore = parseInt(scoreEl.textContent);
          scoreEl.textContent = currentScore + 10;
          
          scoreEl.style.transform = 'scale(1.3)';
          scoreEl.style.color = 'var(--accent)';
          scoreEl.style.transition = 'all 0.2s';
          setTimeout(() => {
            scoreEl.style.transform = 'scale(1)';
            scoreEl.style.color = '#fff';
          }, 400);
        }
        btn.querySelector('span').textContent = "Escalated ✓";
        btn.style.background = "rgba(16, 185, 129, 0.15)";
        btn.style.borderColor = "rgba(16, 185, 129, 0.3)";
        btn.style.color = "#34d399";
      } else {
        alert("Failed to submit upvote. Try again.");
        btn.disabled = false;
        btn.querySelector('span').textContent = "Upvote Severity";
      }
    }
  };
  xhr.send("complaintId=" + encodeURIComponent(complaintId));
}

// Stats Counter count-up engine
function initializeCounters(instant) {
  const pointsVal = document.getElementById('civic-points-val');
  if (pointsVal) {
    const target = parseInt(pointsVal.dataset.target) || 0;
    if (instant) {
      pointsVal.textContent = target;
    } else {
      let current = 0;
      const duration = 1200;
      const steps = 30;
      const stepVal = target / steps;
      const intervalTime = duration / steps;
      const timer = setInterval(() => {
        current += stepVal;
        if (current >= target) {
          pointsVal.textContent = target;
          clearInterval(timer);
        } else {
          pointsVal.textContent = Math.round(current);
        }
      }, intervalTime);
    }
  }
  
  // Draw circular points loader dial
  const circle = document.getElementById('score-circle-fill');
  if (circle) {
    const score = parseInt(circle.dataset.score) || 0;
    const maxPoints = 300; // Cap
    const percentage = Math.min(score / maxPoints, 1);
    const circumference = 2 * Math.PI * 40;
    const offset = circumference - (percentage * circumference);
    setTimeout(() => {
      circle.style.strokeDashoffset = offset;
    }, instant ? 10 : 500);
  }
}

// Emergency error catching & diagnostic tool
window.addEventListener('error', function(e) {
  console.error("Global JS Error caught:", e);
  const logLinesContainer = document.getElementById('boot-log-lines');
  if (logLinesContainer) {
    const errorDiv = document.createElement('div');
    errorDiv.style.color = 'var(--danger)';
    errorDiv.style.marginTop = '8px';
    errorDiv.style.fontSize = '11px';
    errorDiv.style.borderTop = '1px dashed rgba(244, 63, 94, 0.2)';
    errorDiv.style.paddingTop = '8px';
    errorDiv.innerHTML = '<strong>⚠️ BOOT ERROR:</strong> ' + e.message + '<br><span style="opacity:0.7;">at ' + e.filename.split('/').pop() + ':' + e.lineno + ':' + e.colno + '</span>';
    logLinesContainer.appendChild(errorDiv);
  }
});

// Safe sessionStorage utility
let isBooted = 'false';
try {
  isBooted = sessionStorage.getItem('civicfix_boot_complete') || 'false';
} catch (e) {
  console.warn("sessionStorage is disabled/blocked by browser policy:", e);
}

const bootOverlay = document.getElementById('boot-overlay');
const layoutWrap = document.getElementById('dashboard-layout-wrap');

// Initialize Lucide icons if available
if (typeof lucide !== 'undefined') {
  try {
    lucide.createIcons();
  } catch (e) {
    console.error("Lucide icon generation failed:", e);
  }
}

// Emergency Fallback: If loader gets stuck for any reason, auto-fade it after 5.5s
setTimeout(() => {
  if (bootOverlay && bootOverlay.style.display !== 'none') {
    console.warn("Emergency bootloader override triggered. Bypassing stuck loading animation.");
    
    const logLinesContainer = document.getElementById('boot-log-lines');
    if (logLinesContainer) {
      const fallbackDiv = document.createElement('div');
      fallbackDiv.style.color = 'var(--warn)';
      fallbackDiv.style.marginTop = '6px';
      fallbackDiv.innerHTML = `<span>⚡</span> Diagnostic Override: Initializing Dashboard...`;
      logLinesContainer.appendChild(fallbackDiv);
    }
    
    setTimeout(() => {
      if (bootOverlay) {
        bootOverlay.style.opacity = '0';
      }
      if (layoutWrap) {
        layoutWrap.style.transition = 'all 1.2s cubic-bezier(0.16, 1, 0.3, 1)';
        layoutWrap.style.opacity = '1';
        layoutWrap.style.transform = 'translateY(0)';
      }
      setTimeout(() => {
        initializeCounters(true);
      }, 300);
      setTimeout(() => {
        if (bootOverlay) bootOverlay.style.display = 'none';
      }, 800);
    }, 1000);
  }
}, 5500);

if (isBooted === 'true') {
  if (bootOverlay) bootOverlay.style.display = 'none';
  if (layoutWrap) {
    layoutWrap.style.opacity = '1';
    layoutWrap.style.transform = 'translateY(0)';
  }
  initializeCounters(true);
} else {
  if (layoutWrap) {
    layoutWrap.style.opacity = '0';
    layoutWrap.style.transform = 'translateY(15px)';
  }
  
  // Typewriter boot terminal sequences
  const logs = [
    "Initializing Civic Infrastructure Network...",
    "Connecting Municipal Systems...",
    "Activating Smart City Grid...",
    "Syncing Incident Database...",
    "Loading Severity Engine...",
    "Real-Time Monitoring Online...",
    "CivicFix System Activated."
  ];
  
  let currentLogIdx = 0;
  const logLinesContainer = document.getElementById('boot-log-lines');
  
  function addNextLog() {
    if (currentLogIdx < logs.length) {
      if (logLinesContainer) {
        const p = document.createElement('div');
        p.style.marginBottom = '6px';
        p.style.opacity = '0';
        p.style.transform = 'translateX(-5px)';
        p.style.transition = 'all 0.3s ease';
        
        const icon = currentLogIdx === logs.length - 1 ? '⚡' : '✓';
        const color = currentLogIdx === logs.length - 1 ? 'var(--accent)' : 'var(--secondary)';
        
        p.innerHTML = '<span style="color:' + color + '; margin-right:8px; font-weight:bold;">' + icon + '</span> ' + logs[currentLogIdx];
        logLinesContainer.appendChild(p);
        
        p.offsetHeight; // Force repaint
        p.style.opacity = '1';
        p.style.transform = 'translateX(0)';
      }
      
      currentLogIdx++;
      setTimeout(addNextLog, 500);
    }
  }
  
  // Progress Bar width sync
  setTimeout(() => {
    const progressBar = document.getElementById('boot-progress-bar');
    if (progressBar) progressBar.style.width = '100%';
  }, 100);
  
  setTimeout(addNextLog, 300);
  
  // Transition to dashboard at 4.5 seconds
  setTimeout(() => {
    if (bootOverlay) bootOverlay.style.opacity = '0';
    
    if (layoutWrap) {
      layoutWrap.style.transition = 'all 1.2s cubic-bezier(0.16, 1, 0.3, 1)';
      layoutWrap.style.opacity = '1';
      layoutWrap.style.transform = 'translateY(0)';
    }
    
    setTimeout(() => {
      initializeCounters(false);
    }, 300);
    
    setTimeout(() => {
      if (bootOverlay) bootOverlay.style.display = 'none';
      try {
        sessionStorage.setItem('civicfix_boot_complete', 'true');
      } catch (e) {
        console.warn("Could not save boot completion token:", e);
      }
    }, 800);
  }, 4400);
}


// Background smart-city connected nodes canvas
const canvas = document.getElementById('network-canvas');
const ctx = canvas.getContext('2d');
let particles = [];
const particleCount = 55;
const connectionDistance = 110;
let gridOffset = 0;

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
    this.vx = (Math.random() - 0.5) * 0.45;
    this.vy = (Math.random() - 0.5) * 0.45;
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

// Data Stream visual effect
class EnergyStream {
  constructor() {
    this.x = Math.random() * canvas.width;
    this.y = Math.random() * canvas.height;
    this.length = Math.random() * 60 + 40;
    this.speed = Math.random() * 2 + 1;
    this.angle = Math.random() > 0.5 ? 0 : Math.PI / 4; // Horizontal or diagonal
  }
  update() {
    this.x += Math.cos(this.angle) * this.speed;
    this.y += Math.sin(this.angle) * this.speed;
    if (this.x > canvas.width + 100 || this.y > canvas.height + 100) {
      this.x = -100;
      this.y = Math.random() * canvas.height;
    }
  }
  draw() {
    ctx.beginPath();
    const grad = ctx.createLinearGradient(this.x, this.y, this.x + Math.cos(this.angle)*this.length, this.y + Math.sin(this.angle)*this.length);
    grad.addColorStop(0, 'rgba(52, 211, 153, 0)');
    grad.addColorStop(0.5, 'rgba(52, 211, 153, 0.15)');
    grad.addColorStop(1, 'rgba(255, 215, 0, 0)');
    ctx.strokeStyle = grad;
    ctx.lineWidth = 1.5;
    ctx.moveTo(this.x, this.y);
    ctx.lineTo(this.x + Math.cos(this.angle)*this.length, this.y + Math.sin(this.angle)*this.length);
    ctx.stroke();
  }
}

let streams = [];
for (let i = 0; i < 8; i++) {
  streams.push(new EnergyStream());
}

function animateParticles() {
  ctx.clearRect(0, 0, canvas.width, canvas.height);
  
  // Draw Energy data streams
  streams.forEach(s => {
    s.update();
    s.draw();
  });
  
  // Draw Neural networks nodes
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
  
  requestAnimationFrame(animateParticles);
}
animateParticles();

// Boot screen canvas loader script
const bootCanvas = document.getElementById('boot-canvas');
if (bootCanvas) {
  const bCtx = bootCanvas.getContext('2d');
  let bootParticles = [];
  
  function resizeBootCanvas() {
    bootCanvas.width = window.innerWidth;
    bootCanvas.height = window.innerHeight;
  }
  window.addEventListener('resize', resizeBootCanvas);
  resizeBootCanvas();
  
  class BootParticle {
    constructor() {
      this.x = Math.random() * bootCanvas.width;
      this.y = Math.random() * bootCanvas.height;
      this.vy = -Math.random() * 0.5 - 0.2;
      this.radius = Math.random() * 1.5 + 0.8;
      this.alpha = Math.random() * 0.5 + 0.2;
    }
    update() {
      this.y += this.vy;
      if (this.y < 0) {
        this.y = bootCanvas.height;
        this.x = Math.random() * bootCanvas.width;
      }
    }
    draw() {
      bCtx.beginPath();
      bCtx.arc(this.x, this.y, this.radius, 0, Math.PI * 2);
      bCtx.fillStyle = 'rgba(52, 211, 153, ' + this.alpha + ')';
      bCtx.fill();
    }
  }
  
  for (let i = 0; i < 30; i++) bootParticles.push(new BootParticle());
  
  function animateBoot() {
    if (bootOverlay.style.display === 'none') return;
    bCtx.clearRect(0, 0, bootCanvas.width, bootCanvas.height);
    bootParticles.forEach(bp => {
      bp.update();
      bp.draw();
    });
    requestAnimationFrame(animateBoot);
  }
  animateBoot();
}

// AI Textarea analysis event registration
document.addEventListener('DOMContentLoaded', () => {
  const textarea = document.querySelector('textarea[name="description"]');
  if (textarea) {
    let aiTimeout = null;
    textarea.addEventListener('input', function(e) {
      clearTimeout(aiTimeout);
      const text = e.target.value.trim();
      if (text.length < 10) {
        document.getElementById('ai-hud-container').style.display = 'none';
        return;
      }
      
      document.getElementById('ai-hud-container').style.display = 'block';
      document.getElementById('ai-diagnostic-status').innerHTML = `<span style="font-family:monospace;">[AI SCANNER] Analyzing telemetry description...</span>`;
      document.getElementById('ai-confidence').textContent = "Scanning...";
      document.getElementById('accept-ai-btn').style.display = 'none';
      
      aiTimeout = setTimeout(() => {
        runAiClassifier(text);
      }, 750);
    });
  }
});
</script>
</body>
</html>
