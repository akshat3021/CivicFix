<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List, com.civicfix.model.Complaint" %>
<%
    if (!"ADMIN".equals(session.getAttribute("role"))) {
        response.sendRedirect("login.jsp?error=Access Denied! Please login as Admin.");
        return;
    }
    String adminName = (String) session.getAttribute("adminName");
    List<Complaint> complaintList = (List<Complaint>) request.getAttribute("complaintList");
    if (complaintList == null) {
        complaintList = com.civicfix.dao.ComplaintDAO.getAllComplaints();
    }
    int total = complaintList != null ? complaintList.size() : 0;
    int critical = 0, resolved = 0, open = 0;
    
    // Category counters
    int roads = 0, water = 0, electric = 0, sanitation = 0, safety = 0, other = 0;
    
    if (complaintList != null) {
        for (Complaint c : complaintList) {
            if ("CLOSED".equals(c.getStatus())) {
                resolved++;
            } else { 
                open++;
                if (c.getSeverityScore() > 80) critical++;
            }
            
            String cat = c.getCategory();
            if ("ROADS".equals(cat)) roads++;
            else if ("WATER".equals(cat)) water++;
            else if ("ELECTRIC".equals(cat)) electric++;
            else if ("SANITATION".equals(cat)) sanitation++;
            else if ("PUBLIC_SAFETY".equals(cat)) safety++;
            else other++;
        }
    }
    
    int resolutionRate = total > 0 ? (resolved * 100) / total : 0;
    int maxCatCount = Math.max(roads, Math.max(water, Math.max(electric, Math.max(sanitation, Math.max(safety, other)))));
    if (maxCatCount <= 0) maxCatCount = 1;
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>CivicFix — Admin Matrix Hub</title>
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

/* Connected node canvas animation */
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

/* Liquid Glass panels */
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
  background: linear-gradient(180deg, rgba(255, 255, 255, 0.06) 0%, transparent 50%, rgba(255, 255, 255, 0.02) 100%);
  -webkit-mask: linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0);
  -webkit-mask-composite: xor;
  mask-composite: exclude;
  pointer-events: none;
}

.liquid-glass-strong {
  background: rgba(17, 24, 39, 0.75);
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

/* Structure */
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
  background: linear-gradient(135deg, var(--danger) 0%, var(--primary) 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 0 12px rgba(244, 63, 94, 0.3);
}
.logo-text {
  font-family: 'Space Grotesk', sans-serif;
  font-size: 22px;
  font-weight: 800;
  letter-spacing: -1.5px;
}
.logo-text span {
  background: linear-gradient(135deg, var(--danger) 30%, #fff 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}
.topbar-right {
  display: flex;
  align-items: center;
  gap: 20px;
}
.status-pill {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 6px 14px;
  border-radius: 20px;
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 0.05em;
  color: var(--accent);
}
.status-dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: currentColor;
  animation: pulse 1.5s infinite;
}
@keyframes pulse {
  0% { transform: scale(0.9); opacity: 0.7; }
  50% { transform: scale(1.3); opacity: 1; }
  100% { transform: scale(0.9); opacity: 0.7; }
}
.admin-badge {
  font-size: 12.5px;
  font-weight: 600;
  padding: 6px 16px;
  border-radius: 20px;
  color: var(--danger);
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
}

/* Two-column layout */
.layout {
  flex: 1;
  display: grid;
  grid-template-columns: 280px 1fr;
  gap: 20px;
  padding: 20px 16px 16px;
  height: calc(100vh - 88px);
  overflow: hidden;
}

@media (max-width: 1024px) {
  .layout {
    grid-template-columns: 1fr;
  }
  .sidebar-panel {
    display: none;
  }
}

/* Sidebar panel */
.sidebar-panel {
  border-radius: 24px;
  padding: 24px 0;
  display: flex;
  flex-direction: column;
}
.sidebar-label {
  font-size: 10px;
  font-weight: 700;
  text-transform: uppercase;
  color: var(--text-dim);
  letter-spacing: 0.15em;
  padding: 0 24px;
  margin-bottom: 8px;
  margin-top: 24px;
}
.sidebar-label:first-child {
  margin-top: 0;
}
.nav-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 24px;
  font-size: 13.5px;
  color: var(--text-muted);
  text-decoration: none;
  transition: all 0.2s ease;
  border-left: 3px solid transparent;
  position: relative;
}
.nav-item:hover {
  color: #fff;
  background: rgba(255, 255, 255, 0.02);
}
.nav-item.active {
  color: var(--danger);
  background: rgba(255, 255, 255, 0.01);
  border-left-color: var(--danger);
  font-weight: 600;
}
.nav-count {
  margin-left: auto;
  font-size: 10px;
  font-weight: 700;
  padding: 2px 8px;
  background: rgba(244, 63, 94, 0.15);
  color: var(--danger);
  border-radius: 12px;
}

/* Main workspace */
.main-workspace {
  height: 100%;
  display: flex;
  flex-direction: column;
  gap: 20px;
  overflow-y: auto;
  padding-right: 4px;
}
.main-workspace::-webkit-scrollbar {
  width: 4px;
}
.main-workspace::-webkit-scrollbar-thumb {
  background: rgba(255,255,255,0.08);
  border-radius: 2px;
}

.welcome-header {
  margin-bottom: 8px;
}
.page-title {
  font-family: 'Space Grotesk', sans-serif;
  font-size: 38px;
  font-weight: 700;
  letter-spacing: -1.5px;
}
.page-title span {
  background: linear-gradient(135deg, var(--danger) 30%, #fff 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}
.page-sub {
  font-size: 13.5px;
  color: var(--text-muted);
}

/* Staggered entrance delays */
.dashboard-content-wrap {
  opacity: 0;
  transform: translateY(15px);
}
.sidebar-panel { animation: slideIn 0.8s cubic-bezier(0.16, 1, 0.3, 1) both; animation-delay: 0.1s; }
.main-workspace { animation: slideIn 0.8s cubic-bezier(0.16, 1, 0.3, 1) both; animation-delay: 0.2s; }

@keyframes slideIn {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}

/* Analytics columns */
.top-analytics-layout {
  display: grid;
  grid-template-columns: 1fr 340px;
  gap: 20px;
  flex-shrink: 0;
}
@media (max-width: 1200px) {
  .top-analytics-layout {
    grid-template-columns: 1fr;
  }
}

/* Spatial grid heatmap */
.city-grid-card {
  height: 335px;
  border-radius: 24px;
  padding: 20px;
  display: flex;
  flex-direction: column;
  transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
}
.city-grid-card:hover {
  border-color: rgba(244,63,94,0.3);
  box-shadow: 0 15px 35px rgba(244, 63, 94, 0.15);
}
.grid-map-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}
.grid-map-title {
  font-family: 'Space Grotesk', sans-serif;
  font-size: 13px;
  font-weight: 700;
  text-transform: uppercase;
  color: var(--text-muted);
  letter-spacing: 0.5px;
  display: flex;
  align-items: center;
  gap: 8px;
}
.map-canvas-container {
  flex: 1;
  background: rgba(5, 8, 20, 0.4);
  border: 1px solid rgba(255, 255, 255, 0.04);
  border-radius: 16px;
  position: relative;
  overflow: hidden;
}
.svg-city-grid {
  width: 100%;
  height: 100%;
  stroke: rgba(244, 63, 94, 0.06);
  stroke-width: 1.5;
  fill: none;
}
.map-road {
  stroke: rgba(244, 63, 94, 0.08);
  stroke-width: 2.5;
}

/* Radar Sweep overlay */
.radar-sweep-line {
  position: absolute;
  inset: 0;
  background: linear-gradient(90deg, rgba(244, 63, 94, 0.03) 0%, rgba(244, 63, 94, 0) 50%);
  width: 200%;
  transform: translateX(-100%);
  animation: radarSweep 8s linear infinite;
  pointer-events: none;
}
@keyframes radarSweep {
  from { transform: translateX(-100%); }
  to { transform: translateX(100%); }
}

.map-pin {
  cursor: pointer;
  position: absolute;
}
.pin-core {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  position: absolute;
  transform: translate(-50%, -50%);
}
.pin-ring {
  width: 20px;
  height: 20px;
  border-radius: 50%;
  border: 1.5px solid;
  position: absolute;
  transform: translate(-50%, -50%);
  animation: mapPulse 2s infinite ease-out;
  opacity: 0;
}
@keyframes mapPulse {
  0% { transform: translate(-50%, -50%) scale(0.5); opacity: 1; }
  100% { transform: translate(-50%, -50%) scale(1.6); opacity: 0; }
}
.pin-danger .pin-core { background: var(--danger); box-shadow: 0 0 8px var(--danger); }
.pin-danger .pin-ring { border-color: var(--danger); }

.pin-bounty .pin-core { background: var(--magenta); box-shadow: 0 0 8px var(--magenta); }
.pin-bounty .pin-ring { border-color: var(--magenta); }

.pin-warn .pin-core { background: var(--warn); box-shadow: 0 0 8px var(--warn); }
.pin-warn .pin-ring { border-color: var(--warn); }

.pin-ok .pin-core { background: var(--accent); box-shadow: 0 0 8px var(--accent); }
.pin-ok .pin-ring { border-color: var(--accent); }

.pin-closed .pin-core { background: var(--secondary); opacity: 0.6; }
.pin-closed .pin-ring { display: none; }

/* Category Chart Card */
.analytics-card {
  height: 280px;
  border-radius: 24px;
  padding: 20px;
  display: flex;
  flex-direction: column;
  transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
}
.analytics-card:hover {
  border-color: rgba(244,63,94,0.3);
  box-shadow: 0 15px 35px rgba(244, 63, 94, 0.15);
}
.analytics-title {
  font-family: 'Space Grotesk', sans-serif;
  font-size: 13px;
  font-weight: 700;
  text-transform: uppercase;
  color: var(--text-muted);
  margin-bottom: 16px;
  display: flex;
  align-items: center;
  gap: 8px;
}

.bar-chart-container {
  display: flex;
  flex-direction: column;
  gap: 12px;
  flex: 1;
  justify-content: center;
}
.chart-bar-row {
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 11px;
}
.chart-lbl {
  width: 90px;
  color: var(--text-muted);
  font-weight: 500;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.chart-track {
  flex: 1;
  height: 6px;
  background: rgba(255, 255, 255, 0.05);
  border-radius: 4px;
  overflow: hidden;
}
.chart-fill {
  height: 100%;
  background: linear-gradient(90deg, var(--danger) 0%, var(--primary) 100%);
  border-radius: 4px;
  width: 0;
  transition: width 1s cubic-bezier(0.16, 1, 0.3, 1);
}
.chart-val-num {
  width: 20px;
  text-align: right;
  font-weight: 700;
  color: #fff;
}

/* KPI stats cards hover effect */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 16px;
  flex-shrink: 0;
}
@media (max-width: 768px) {
  .stats-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}
.stat-card {
  border-radius: 20px;
  padding: 16px 20px;
  transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
}
.stat-card:hover {
  transform: translateY(-4px);
  border-color: var(--danger);
  box-shadow: 0 12px 25px rgba(244, 63, 94, 0.15);
}
.stat-lbl {
  font-size: 10px;
  font-weight: 700;
  text-transform: uppercase;
  color: var(--text-dim);
  letter-spacing: 0.1em;
  margin-bottom: 6px;
}
.stat-val {
  font-family: 'Space Grotesk', sans-serif;
  font-size: 32px;
  font-weight: 700;
  color: #fff;
}
.stat-card.c2 .stat-val { color: var(--danger); }
.stat-card.c3 .stat-val { color: var(--warn); }
.stat-card.c4 .stat-val { color: var(--secondary); }

/* Table Section Controls */
.table-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 20px;
  margin-top: 10px;
  flex-shrink: 0;
}
@media (max-width: 768px) {
  .table-header {
    flex-direction: column;
    align-items: flex-start;
  }
}
.table-title {
  font-family: 'Space Grotesk', sans-serif;
  font-size: 18px;
  font-weight: 600;
}
.controls-right {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 12px;
}
.search-input {
  background: rgba(255, 255, 255, 0.02);
  border: 1px solid rgba(255, 255, 255, 0.05);
  color: #fff;
  padding: 8px 16px;
  font-family: inherit;
  font-size: 13px;
  border-radius: 20px;
  outline: none;
  min-width: 160px;
  transition: all 0.2s;
}
.search-input:focus {
  border-color: var(--danger);
  background: rgba(255, 255, 255, 0.04);
}
.sort-select {
  background: rgba(255, 255, 255, 0.02);
  border: 1px solid rgba(255, 255, 255, 0.05);
  color: #fff;
  padding: 8px 14px;
  font-family: inherit;
  font-size: 13px;
  border-radius: 20px;
  outline: none;
  cursor: pointer;
}
.sort-select option {
  background: #0b0f19;
}
.filter-pill-row {
  display: flex;
  gap: 4px;
}
.filter-pill {
  font-size: 10.5px;
  font-weight: 700;
  padding: 6px 12px;
  border-radius: 20px;
  background: transparent;
  border: none;
  color: var(--text-muted);
  cursor: pointer;
  transition: all 0.2s;
}
.filter-pill:hover {
  color: #fff;
}
.filter-pill.active {
  background: rgba(244, 63, 94, 0.15);
  color: var(--danger);
  border: 1px solid rgba(244, 63, 94, 0.25);
}

/* Custom Table cards */
.complaints-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
  padding-bottom: 32px;
  flex-shrink: 0;
}
.complaint-row-card {
  border-radius: 20px;
  padding: 16px 24px;
  display: grid;
  grid-template-columns: 80px 130px 1fr 130px 120px 180px;
  align-items: center;
  gap: 16px;
  cursor: pointer;
  transition: transform 0.25s cubic-bezier(0.16, 1, 0.3, 1), background 0.25s, border-color 0.2s;
}
.complaint-row-card:hover {
  transform: translateY(-4px);
  background: rgba(255, 255, 255, 0.02);
  border-color: var(--danger);
  box-shadow: 0 12px 25px rgba(244, 63, 94, 0.15);
}
.critical-alert-card {
  border-color: rgba(244, 63, 94, 0.3);
  box-shadow: 0 0 15px rgba(244, 63, 94, 0.15);
  animation: borderGlow 2s infinite alternate;
}
@keyframes borderGlow {
  0% { border-color: rgba(244, 63, 94, 0.25); }
  100% { border-color: rgba(244, 63, 94, 0.55); box-shadow: 0 0 20px rgba(244, 63, 94, 0.25); }
}

.bounty-critical-glow {
  border-color: var(--magenta) !important;
  box-shadow: 0 0 15px rgba(255, 0, 127, 0.15);
  animation: bountyPulse 2s infinite alternate;
}
@keyframes bountyPulse {
  0% { border-color: rgba(255, 0, 127, 0.25); }
  100% { border-color: rgba(255, 0, 127, 0.55); box-shadow: 0 0 20px rgba(255, 0, 127, 0.25); }
}

.id-cell {
  font-family: monospace;
  font-size: 12px;
  color: var(--text-dim);
}
.cat-badge-wrap {
  display: flex;
}
.title-cell {
  font-weight: 600;
  color: #fff;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

/* Severity score display */
.severity-panel {
  display: flex;
  align-items: center;
  gap: 10px;
}
.severity-val {
  font-weight: 700;
  font-size: 13.5px;
  font-family: 'Space Grotesk', sans-serif;
}
.score-critical { color: var(--danger); }
.score-high { color: var(--warn); }
.score-normal { color: var(--accent); }

.bar-track {
  width: 50px;
  height: 4px;
  background: rgba(255, 255, 255, 0.08);
  border-radius: 10px;
  overflow: hidden;
}
.bar-fill {
  height: 100%;
  border-radius: 10px;
  width: 0;
  transition: width 1s cubic-bezier(0.16, 1, 0.3, 1);
}
.fill-danger { background: var(--danger); }
.fill-warn { background: var(--warn); }
.fill-ok { background: var(--accent); }

.status-pill-tbl {
  font-size: 10px;
  font-weight: 700;
  display: inline-flex;
  align-items: center;
  gap: 6px;
  text-transform: uppercase;
}
.status-OPEN { color: var(--warn); }
.status-IN_PROGRESS { color: #a5b4fc; }
.status-CLOSED { color: var(--secondary); }
.status-dot-circle {
  width: 5px;
  height: 5px;
  border-radius: 50%;
  background: currentColor;
}

.actions-cell {
  display: flex;
  gap: 6px;
  justify-content: flex-end;
}
.btn-action-custom {
  font-size: 11px;
  font-weight: 700;
  padding: 6px 12px;
  border-radius: 10px;
  text-decoration: none;
  cursor: pointer;
  transition: all 0.2s;
}
.btn-progress { background: rgba(99, 102, 241, 0.1); color: #a5b4fc; border: 1px solid rgba(99,102,241,0.15); }
.btn-progress:hover { background: var(--primary); color: #fff; }
.btn-resolve { background: rgba(16, 185, 129, 0.1); color: #34d399; border: 1px solid rgba(16,185,129,0.15); }
.btn-resolve:hover { background: var(--secondary); color: #0b1220; }
.btn-delete { background: rgba(244, 63, 94, 0.1); color: #fda4af; border: 1px solid rgba(244,63,94,0.15); }
.btn-delete:hover { background: var(--danger); color: #fff; }
.resolved-tag {
  font-size: 11.5px;
  font-weight: 600;
  color: var(--secondary);
}

/* Slide Drawer details view */
.details-drawer {
  position: fixed;
  inset: 0;
  background: rgba(2, 6, 17, 0.5);
  backdrop-filter: blur(8px);
  -webkit-backdrop-filter: blur(8px);
  z-index: 200;
  display: none;
  justify-content: flex-end;
}
.drawer-inner {
  width: 100%;
  max-width: 480px;
  height: 100%;
  padding: 40px;
  display: flex;
  flex-direction: column;
  gap: 24px;
  box-shadow: -10px 0 35px rgba(0, 0, 0, 0.4);
  transform: translateX(100%);
  transition: transform 0.4s cubic-bezier(0.16, 1, 0.3, 1);
  overflow-y: auto;
}
.details-drawer.open .drawer-inner {
  transform: translateX(0);
}
.drawer-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-bottom: 1px solid rgba(255, 255, 255, 0.05);
  padding-bottom: 16px;
}
.drawer-title {
  font-family: 'Space Grotesk', sans-serif;
  font-size: 20px;
  font-weight: 700;
  color: #fff;
}
.close-drawer-btn {
  background: none;
  border: none;
  color: var(--text-muted);
  font-size: 28px;
  cursor: pointer;
}
.drawer-body {
  display: flex;
  flex-direction: column;
  gap: 20px;
}
.drawer-meta-item {
  display: flex;
  justify-content: space-between;
  font-size: 13.5px;
  padding: 8px 0;
  border-bottom: 1px dashed rgba(255, 255, 255, 0.03);
}
.drawer-lbl { color: var(--text-dim); }
.drawer-val { color: #fff; font-weight: 600; }
.drawer-section-lbl {
  font-size: 10px;
  font-weight: 700;
  text-transform: uppercase;
  color: var(--text-dim);
  letter-spacing: 0.1em;
  margin-bottom: 6px;
}
.drawer-desc-block {
  background: rgba(255, 255, 255, 0.01);
  padding: 16px;
  border-radius: 16px;
  font-size: 13.5px;
  line-height: 1.6;
  color: var(--text-muted);
  border: 1px solid rgba(255,255,255,0.03);
}
.drawer-img-container {
  border-radius: 16px;
  overflow: hidden;
  border: 1px solid rgba(255, 255, 255, 0.05);
  background: #000;
}
.drawer-evidence-img {
  width: 100%;
  max-height: 240px;
  object-fit: contain;
  display: block;
}
.drawer-track-link {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  width: 100%;
  padding: 12px;
  background: var(--danger);
  color: #fff;
  border-radius: 12px;
  font-family: 'Space Grotesk', sans-serif;
  font-weight: 700;
  text-decoration: none;
  font-size: 13px;
  margin-top: 10px;
  box-shadow: 0 4px 15px rgba(244, 63, 94, 0.2);
}
.drawer-track-link:hover {
  background: #f45b74;
}
</style>
</head>
<body>

<!-- CINEMATIC STARTUP BOOT SCREEN OVERLAY -->
<div id="boot-overlay" style="position: fixed; inset: 0; background: #060a08; z-index: 99999; display: flex; flex-direction: column; align-items: center; justify-content: center; opacity: 1; transition: opacity 0.8s ease;">
  <canvas id="boot-canvas" style="position: absolute; inset: 0; width: 100%; height: 100%; pointer-events: none;"></canvas>
  <div style="position: relative; z-index: 10; display: flex; flex-direction: column; align-items: center; gap: 24px; max-width: 440px; width: 100%; padding: 24px;">
    <div id="boot-logo-container" style="position: relative; display: flex; align-items: center; justify-content: center; height: 110px; width: 100%;">
      <div id="boot-logo-ring" style="position: absolute; width: 90px; height: 90px; border: 2px dashed rgba(244, 63, 94, 0.4); border-radius: 50%; animation: rotateRing 20s linear infinite;"></div>
      <div id="boot-logo" style="font-family: 'Space Grotesk', sans-serif; font-size: 38px; font-weight: 800; letter-spacing: -2px; color: #fff; text-shadow: 0 0 20px rgba(244, 63, 94, 0.5);">CIVIC<span style="color:var(--danger);">FIX</span></div>
    </div>
    <div id="boot-terminal" style="font-family: 'Fira Code', monospace; font-size: 11.5px; color: var(--danger); background: rgba(5, 8, 20, 0.7); border: 1px solid rgba(255, 255, 255, 0.05); padding: 18px; border-radius: 14px; width: 100%; min-height: 160px; line-height: 1.6; box-shadow: 0 10px 30px rgba(0,0,0,0.5);">
      <div id="boot-log-lines"></div>
    </div>
    <div id="boot-progress" style="width: 100%; height: 2px; background: rgba(255, 255, 255, 0.05); border-radius: 1px; overflow: hidden; margin-top: 8px;">
      <div id="boot-progress-bar" style="width: 0%; height: 100%; background: linear-gradient(90deg, var(--danger) 0%, var(--primary) 100%); transition: width 4.3s linear; box-shadow: 0 0 10px rgba(244,63,94,0.35);"></div>
    </div>
  </div>
</div>

<!-- Animated connected nodes canvas background -->
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
      <div class="status-pill liquid-glass">
        <span class="status-dot"></span>
        <span>Operational grid live</span>
      </div>
      <div class="admin-badge liquid-glass">Admin: <%= adminName %></div>
      <a href="auth?action=logout" class="logout-btn hover-scale">Logout</a>
    </div>
  </div>

  <!-- Layout panels -->
  <div class="layout dashboard-content-wrap" id="dashboard-layout-wrap">
    <!-- Sidebar -->
    <div class="sidebar-panel liquid-glass-strong">
      <div class="sidebar-label">Navigation Matrix</div>
      <a href="#" class="nav-item active" id="nav-all" onclick="setFilter('ALL', this)">
        <i data-lucide="menu" style="width: 16px; height: 16px;"></i>
        <span>All Complaints</span>
        <% if(open > 0) { %><span class="nav-count"><%= open %></span><% } %>
      </a>
      <a href="#" class="nav-item" onclick="setFilter('CRITICAL', this)">
        <i data-lucide="alert-triangle" style="width: 16px; height: 16px;"></i>
        <span>Critical Priority</span>
      </a>
      <a href="#" class="nav-item" onclick="setFilter('IN_PROGRESS', this)">
        <i data-lucide="wrench" style="width: 16px; height: 16px;"></i>
        <span>In Progress</span>
      </a>
      <a href="#" class="nav-item" onclick="setFilter('CLOSED', this)">
        <i data-lucide="check-circle" style="width: 16px; height: 16px;"></i>
        <span>Resolved</span>
      </a>
      
      <div class="sidebar-label">Categories Filter</div>
      <a href="#" class="nav-item" onclick="setCategoryFilter('ROADS', this)">🛣 Roads</a>
      <a href="#" class="nav-item" onclick="setCategoryFilter('WATER', this)">💧 Water</a>
      <a href="#" class="nav-item" onclick="setCategoryFilter('ELECTRIC', this)">🔌 Electricity</a>
      <a href="#" class="nav-item" onclick="setCategoryFilter('SANITATION', this)">🧹 Sanitation</a>
      <a href="#" class="nav-item" onclick="setCategoryFilter('PUBLIC_SAFETY', this)">🚨 Public Safety</a>
    </div>

    <!-- Main Section -->
    <div class="main-workspace">
      <div class="welcome-header">
        <h1 class="page-title">City <span>Command Center</span></h1>
        <p class="page-sub">Operational dashboard for infrastructure severity scoring and tracking.</p>
      </div>

      <!-- Live Spatial Heatmap & Animated Charts -->
      <div class="top-analytics-layout">
        <!-- Live City Map Grid Heatmap -->
        <div class="city-grid-card liquid-glass-strong">
          <div class="grid-map-header">
            <div class="grid-map-title">
              <i data-lucide="map" style="width:14px; height:14px; color:var(--danger);"></i>
              <span>Spatial Grid Heatmap</span>
            </div>
            
            <!-- Map Filters Controls -->
            <div style="display:flex; gap:6px; align-items:center;">
              <select class="sort-select" id="map-filter-cat" onchange="applyMapFilters()" style="padding: 2px 8px; font-size:10px; border-radius:12px; height:24px; font-weight:600;">
                <option value="ALL">All Categories</option>
                <option value="ROADS">Roads</option>
                <option value="WATER">Water</option>
                <option value="ELECTRIC">Electricity</option>
                <option value="SANITATION">Sanitation</option>
                <option value="PUBLIC_SAFETY">Safety</option>
              </select>
              <select class="sort-select" id="map-filter-sev" onchange="applyMapFilters()" style="padding: 2px 8px; font-size:10px; border-radius:12px; height:24px; font-weight:600;">
                <option value="ALL">All Severity</option>
                <option value="CRITICAL">Critical (>80)</option>
                <option value="HIGH">High (>50)</option>
                <option value="ROUTINE">Routine (<=50)</option>
              </select>
              <div style="font-size:9.5px; color:var(--text-dim); font-weight:700; text-transform:uppercase; margin-left:6px; letter-spacing:0.5px;">Map HUD</div>
            </div>
          </div>
          
          <div class="map-canvas-container" style="flex:1;">
            <div class="radar-sweep-line"></div>
            <svg class="svg-city-grid" viewBox="0 0 400 200">
              <path class="map-road" d="M 0 35 L 400 35" />
              <path class="map-road" d="M 0 100 L 400 100" />
              <path class="map-road" d="M 0 165 L 400 165" />
              <path class="map-road" d="M 80 0 L 80 200" />
              <path class="map-road" d="M 200 0 L 200 200" />
              <path class="map-road" d="M 310 0 L 310 200" />
              
              <rect x="15" y="45" width="50" height="45" rx="3" fill="rgba(255,255,255,0.01)" stroke="rgba(255,255,255,0.02)" />
              <rect x="95" y="45" width="90" height="45" rx="3" fill="rgba(255,255,255,0.01)" stroke="rgba(255,255,255,0.02)" />
              <rect x="215" y="45" width="80" height="45" rx="3" fill="rgba(255,255,255,0.01)" stroke="rgba(255,255,255,0.02)" />
              <rect x="15" y="110" width="50" height="45" rx="3" fill="rgba(255,255,255,0.01)" stroke="rgba(255,255,255,0.02)" />
              <rect x="95" y="110" width="90" height="45" rx="3" fill="rgba(255,255,255,0.01)" stroke="rgba(255,255,255,0.02)" />
              <rect x="215" y="110" width="80" height="45" rx="3" fill="rgba(255,255,255,0.01)" stroke="rgba(255,255,255,0.02)" />
            </svg>
            
            <% 
              if (complaintList != null) {
                  for (Complaint c : complaintList) {
                      int xCoord = (c.getId() * 67) % 320 + 40;
                      int yCoord = (c.getId() * 41) % 140 + 30;
                      
                      String pinClass = "pin-ok";
                      if ("CLOSED".equals(c.getStatus())) {
                          pinClass = "pin-closed";
                      } else if (c.getBountyPool() >= 50) {
                          pinClass = "pin-bounty";
                      } else if (c.getSeverityScore() > 80) {
                          pinClass = "pin-danger";
                      } else if (c.getSeverityScore() > 50) {
                          pinClass = "pin-warn";
                      }
            %>
              <div class="map-pin <%= pinClass %>" 
                   id="map-pin-<%= c.getId() %>"
                   data-id="<%= c.getId() %>"
                   data-category="<%= c.getCategory() %>"
                   data-severity="<%= c.getSeverityScore() %>"
                   data-status="<%= c.getStatus() %>"
                   data-bounty="<%= c.getBountyPool() %>"
                   data-dispatch-status="<%= c.getDispatchStatus() != null ? c.getDispatchStatus() : "IDLE" %>"
                   data-dispatch-log="<%= c.getDispatchLog() != null ? c.getDispatchLog().replace("\"", "&quot;") : "[]" %>"
                   style="left: <%= xCoord %>px; top: <%= yCoord %>px;"
                   title="<%= c.getTitle() %> (Severity: <%= c.getSeverityScore() %>)"
                   onclick="showDrawer(<%= c.getId() %>, '<%= c.getTitle().replace("'", "\\'") %>', '<%= c.getCategory() %>', '<%= c.getStatus() %>', <%= c.getSeverityScore() %>, '<%= c.getDescription().replace("'", "\\'").replace("\n", "\\n").replace("\r", "") %>', '<%= c.getImagePath() != null ? c.getImagePath() : "" %>', '<%= c.getDispatchStatus() != null ? c.getDispatchStatus() : "IDLE" %>', '<%= c.getDispatchLog() != null ? c.getDispatchLog().replace("'", "\\'") : "[]" %>', <%= c.getBountyPool() %>)">
                <div class="pin-ring"></div>
                <div class="pin-core"></div>
              </div>
            <% 
                  }
              }
            %>
          </div>
          
          <!-- Spatiotemporal Time-Lapse controls -->
          <div style="display:flex; align-items:center; gap:10px; margin-top:10px; padding: 0 4px;">
            <button type="button" class="upvote-btn hover-scale" id="map-play-btn" style="padding: 4px 10px; font-size:11px; display:flex; align-items:center; gap:4px; height:26px;" onclick="toggleTimeLapse()">
              <i data-lucide="play" style="width:11px; height:11px;" id="play-icon"></i>
              <span id="play-text">Time-Lapse</span>
            </button>
            <input type="range" class="calc-slider" id="map-time-slider" min="0" max="100" value="100" style="flex:1;" oninput="scrubTimeLapse(this.value)">
            <span style="font-family:'Fira Code', monospace; font-size:10.5px; color:var(--text-muted); width:35px; text-align:right;" id="map-time-label">100%</span>
          </div>
        </div>
        
        <!-- Category Statistics -->
        <div class="analytics-card liquid-glass-strong">
          <div class="analytics-title">
            <i data-lucide="bar-chart-3" style="width:14px; height:14px; color:var(--danger);"></i>
            <span>Complaints by Category</span>
          </div>
          
          <div class="bar-chart-container">
            <div class="chart-bar-row">
              <span class="chart-lbl">🛣 Roads</span>
              <div class="chart-track">
                <div class="chart-fill" data-width="<%= (roads * 100) / maxCatCount %>"></div>
              </div>
              <span class="chart-val-num"><%= roads %></span>
            </div>
            
            <div class="chart-bar-row">
              <span class="chart-lbl">💧 Water</span>
              <div class="chart-track">
                <div class="chart-fill" data-width="<%= (water * 100) / maxCatCount %>"></div>
              </div>
              <span class="chart-val-num"><%= water %></span>
            </div>
            
            <div class="chart-bar-row">
              <span class="chart-lbl">🔌 Electric</span>
              <div class="chart-track">
                <div class="chart-fill" data-width="<%= (electric * 100) / maxCatCount %>"></div>
              </div>
              <span class="chart-val-num"><%= electric %></span>
            </div>
            
            <div class="chart-bar-row">
              <span class="chart-lbl">🧹 Sanitation</span>
              <div class="chart-track">
                <div class="chart-fill" data-width="<%= (sanitation * 100) / maxCatCount %>"></div>
              </div>
              <span class="chart-val-num"><%= sanitation %></span>
            </div>
            
            <div class="chart-bar-row">
              <span class="chart-lbl">🚨 Safety</span>
              <div class="chart-track">
                <div class="chart-fill" data-width="<%= (safety * 100) / maxCatCount %>"></div>
              </div>
              <span class="chart-val-num"><%= safety %></span>
            </div>
          </div>
        </div>
      </div>

      <!-- KPI Grid -->
      <div class="stats-grid">
        <div class="stat-card liquid-glass c1">
          <div class="stat-lbl">Incidents Logged</div>
          <div class="stat-val" id="count-logged" data-target="<%= total %>">0</div>
        </div>
        <div class="stat-card liquid-glass c2">
          <div class="stat-lbl">Critical Alert Level</div>
          <div class="stat-val" id="count-critical" data-target="<%= critical %>">0</div>
        </div>
        <div class="stat-card liquid-glass c3">
          <div class="stat-lbl">Pending Review</div>
          <div class="stat-val" id="count-pending" data-target="<%= open %>">0</div>
        </div>
        <div class="stat-card liquid-glass c4">
          <div class="stat-lbl">Resolution Rate</div>
          <div class="stat-val"><span id="count-resolution" data-target="<%= resolutionRate %>">0</span>%</div>
        </div>
      </div>

      <!-- Table Header controls -->
      <div class="table-header">
        <div class="table-title">Operational Incident Registry</div>
        <div class="controls-right">
          <input type="text" class="search-input" id="search-box" placeholder="Search title..." oninput="handleSearch()">
          
          <select class="sort-select" id="sort-selector" onchange="handleSort()">
            <option value="ID_DESC">Latest First</option>
            <option value="SEVERITY_DESC">Severity: High to Low</option>
            <option value="SEVERITY_ASC">Severity: Low to High</option>
          </select>
          
          <div class="filter-pill-row liquid-glass" style="padding: 3px; border-radius: 20px;">
            <button class="filter-pill active" id="btn-ALL" onclick="setFilter('ALL', this)">ALL</button>
            <button class="filter-pill" id="btn-OPEN" onclick="setFilter('OPEN', this)">OPEN</button>
            <button class="filter-pill" id="btn-IN_PROGRESS" onclick="setFilter('IN_PROGRESS', this)">IN PROG</button>
            <button class="filter-pill" id="btn-CLOSED" onclick="setFilter('CLOSED', this)">CLOSED</button>
          </div>
        </div>
      </div>

      <!-- Custom Table cards -->
      <div class="complaints-list" id="complaints-container">
        <% if (complaintList == null || complaintList.isEmpty()) { %>
          <div class="liquid-glass" style="text-align: center; color: var(--text-dim); padding: 48px; border-radius: 20px;">
            // No incidents registered in system
          </div>
        <% } else {
            for (Complaint c : complaintList) {
                boolean isOpen = "OPEN".equals(c.getStatus());
                boolean isProgress = "IN_PROGRESS".equals(c.getStatus());
                boolean isClosed = "CLOSED".equals(c.getStatus());
                
                int score = c.getSeverityScore();
                String scoreClass = score > 80 ? "score-critical" : score > 50 ? "score-high" : "score-normal";
                String barClass  = score > 80 ? "fill-danger"  : score > 50 ? "fill-warn"   : "fill-ok";
                boolean isCritical = score > 80 && !isClosed;
        %>
          <div class="complaint-row-card liquid-glass <%= isCritical ? "critical-alert-card" : "" %> <%= c.getBountyPool() >= 50 ? "bounty-critical-glow" : "" %>" 
               id="row-<%= c.getId() %>" 
               data-id="<%= c.getId() %>"
               data-status="<%= c.getStatus() %>" 
               data-category="<%= c.getCategory() %>"
               data-severity="<%= score %>"
               data-critical="<%= isCritical ? "true" : "false" %>"
               data-dispatch-status="<%= c.getDispatchStatus() != null ? c.getDispatchStatus() : "IDLE" %>"
               data-dispatch-log="<%= c.getDispatchLog() != null ? c.getDispatchLog().replace("\"", "&quot;") : "[]" %>"
               data-bounty-pool="<%= c.getBountyPool() %>"
               onclick="showDrawer(<%= c.getId() %>, '<%= c.getTitle().replace("'", "\\'") %>', '<%= c.getCategory() %>', '<%= c.getStatus() %>', <%= score %>, '<%= c.getDescription().replace("'", "\\'").replace("\n", "\\n").replace("\r", "") %>', '<%= c.getImagePath() != null ? c.getImagePath() : "" %>', '<%= c.getDispatchStatus() != null ? c.getDispatchStatus() : "IDLE" %>', '<%= c.getDispatchLog() != null ? c.getDispatchLog().replace("'", "\\'") : "[]" %>', <%= c.getBountyPool() %>)">
            
            <div class="id-cell">#<%= c.getId() %></div>
            <div class="cat-badge-wrap">
              <span class="cat-tag cat-<%= c.getCategory() %>"><%= c.getCategory() %></span>
            </div>
            <div class="title-cell">
              <% if (isCritical) { %>
                <span style="display:inline-block; width:6px; height:6px; background:var(--danger); border-radius:50%; margin-right:6px; animation: pulse 1s infinite;"></span>
              <% } %>
              <%= c.getTitle() %>
            </div>
            
            <div class="severity-panel">
              <span class="severity-val <%= scoreClass %>"><%= score %></span>
              <div class="bar-track">
                <div class="bar-fill <%= barClass %>" data-width="<%= score %>"></div>
              </div>
            </div>
            
            <div class="status-pill-tbl status-<%= c.getStatus() %>">
              <span class="status-dot-circle"></span>
              <span><%= c.getStatus().replace("_", " ") %></span>
            </div>
            
            <div class="actions-cell" onclick="event.stopPropagation()">
              <% if (isOpen) { %>
                <a href="status?id=<%= c.getId() %>&s=IN_PROGRESS" class="btn-action-custom btn-progress hover-scale">Start Work</a>
                <a href="admin?action=resolve&id=<%= c.getId() %>" class="btn-action-custom btn-resolve hover-scale">Resolve</a>
              <% } else if (isProgress) { %>
                <a href="admin?action=resolve&id=<%= c.getId() %>" class="btn-action-custom btn-resolve hover-scale">Resolve</a>
              <% } else { %>
                <span class="resolved-tag">Resolved ✓</span>
              <% } %>
              <a href="admin?action=delete&id=<%= c.getId() %>" class="btn-action-custom btn-delete hover-scale" onclick="return confirm('Are you sure you want to delete complaint #<%= c.getId() %>?')">Delete</a>
            </div>
          </div>
        <% } } %>
      </div>
    </div>
  </div>
</div>

<!-- SLIDE DRAWER LIGHTBOX -->
<div class="details-drawer" id="details-drawer" onclick="closeDrawer()">
  <div class="drawer-inner liquid-glass-strong" onclick="event.stopPropagation()">
    <div class="drawer-header">
      <h3 class="drawer-title" id="drawer-title-text">Incident Details</h3>
      <button type="button" class="close-drawer-btn" onclick="closeDrawer()">&times;</button>
    </div>
    <div class="drawer-body">
      <div class="drawer-meta-item">
        <span class="drawer-lbl">Incident ID</span>
        <span class="drawer-val" id="drawer-id">#0</span>
      </div>
      <div class="drawer-meta-item">
        <span class="drawer-lbl">Category</span>
        <span class="drawer-val" id="drawer-cat">ROADS</span>
      </div>
      <div class="drawer-meta-item">
        <span class="drawer-lbl">Status</span>
        <span class="drawer-val" id="drawer-status">OPEN</span>
      </div>
      <div class="drawer-meta-item">
        <span class="drawer-lbl">Severity Score</span>
        <span class="drawer-val" id="drawer-score">0</span>
      </div>
      
      <div style="margin-top: 10px;">
        <div class="drawer-section-lbl">Description</div>
        <div class="drawer-desc-block" id="drawer-desc">Description of incident...</div>
      </div>
      
      <div id="drawer-img-container" style="display: none; margin-top: 10px;">
        <div class="drawer-section-lbl">Evidence Photo</div>
        <div class="drawer-img-container">
          <img src="" class="drawer-evidence-img" id="drawer-evidence-photo" alt="evidence preview">
        </div>
      </div>
      
      <!-- Tactical Dispatch Console -->
      <div id="drawer-dispatch-container" style="margin-top: 15px; border-top: 1px dashed rgba(255,255,255,0.06); padding-top: 12px; display:none;">
        <div class="drawer-section-lbl" style="display:flex; align-items:center; gap:6px; color:var(--danger);">
          <i data-lucide="shield-alert" style="width:12px; height:12px;"></i>
          <span>Tactical Asset Dispatch</span>
        </div>
        
        <!-- Selection buttons if IDLE -->
        <div id="dispatch-idle-panel" style="display:none; margin-top:8px;">
          <div style="font-size:10px; color:var(--text-dim); margin-bottom:8px; text-transform:uppercase;">Select asset to deploy:</div>
          <div style="display:flex; flex-direction:column; gap:6px;">
            <button type="button" class="upvote-btn hover-scale" style="justify-content:flex-start; font-size:11px; border-color:rgba(255,255,255,0.06); width:100%; text-align:left; background:rgba(255,255,255,0.01);" onclick="triggerDispatch('DRONE_RECON')">
              <span>🛸 Deploy Autonomous Recon Drone #4</span>
            </button>
            <button type="button" class="upvote-btn hover-scale" style="justify-content:flex-start; font-size:11px; border-color:rgba(255,255,255,0.06); width:100%; text-align:left; background:rgba(255,255,255,0.01);" onclick="triggerDispatch('REPAIR_CREW')">
              <span>🔧 Deploy Rapid Response Repair Crew</span>
            </button>
            <button type="button" class="upvote-btn hover-scale" style="justify-content:flex-start; font-size:11px; border-color:rgba(255,255,255,0.06); width:100%; text-align:left; background:rgba(255,255,255,0.01);" onclick="triggerDispatch('HEAVY_HAZARD')">
              <span>🚒 Deploy Emergency Heavy Hazard Vehicle</span>
            </button>
          </div>
        </div>
        
        <!-- Live Console timeline if ACTIVE -->
        <div id="dispatch-active-panel" style="display:none; margin-top:8px;">
          <div style="font-size:10px; color:var(--text-dim); margin-bottom:6px; text-transform:uppercase;">Live Response Telemetry Feed:</div>
          <div id="dispatch-terminal-console" style="font-family:'Fira Code', monospace; font-size:10px; color:#ff7777; background:rgba(5, 8, 20, 0.85); border:1px solid rgba(244,63,94,0.15); padding:10px; border-radius:10px; min-height:80px; max-height:140px; overflow-y:auto; line-height:1.4;">
            Connecting to deployed asset...
          </div>
        </div>
      </div>
      
      <a href="" id="drawer-details-link" class="drawer-track-link">
        <i data-lucide="eye" style="width:14px; height:14px;"></i>
        <span>Track Status Timeline</span>
      </a>
    </div>
  </div>
</div>

<script>
// Track mouse coordinates for cursor trails
const glow = document.getElementById('mouse-glow');
document.addEventListener('mousemove', (e) => {
  glow.style.opacity = '1';
  glow.style.left = e.clientX + 'px';
  glow.style.top = e.clientY + 'px';
});
document.addEventListener('mouseleave', () => {
  glow.style.opacity = '0';
});

let currentFilter = 'ALL';
let currentCategory = 'ALL';

// Initialize Lucide icons if available
if (typeof lucide !== 'undefined') {
  try {
    lucide.createIcons();
  } catch (e) {
    console.error("Lucide icon generation failed:", e);
  }
}

function handleSearch() {
  filterTable();
}

function setFilter(filterType, btnElement) {
  document.querySelectorAll('.filter-pill').forEach(b => b.classList.remove('active'));
  document.querySelectorAll('.sidebar-panel .nav-item').forEach(b => b.classList.remove('active'));
  
  const targetBtn = document.getElementById('btn-' + filterType);
  if (targetBtn) targetBtn.classList.add('active');
  
  if (btnElement && btnElement.classList.contains('nav-item')) {
    btnElement.classList.add('active');
  } else {
    if (filterType === 'ALL') document.getElementById('nav-all').classList.add('active');
  }
  
  currentFilter = filterType;
  currentCategory = 'ALL';
  filterTable();
}

function setCategoryFilter(categoryType, btnElement) {
  document.querySelectorAll('.sidebar-panel .nav-item').forEach(b => b.classList.remove('active'));
  if (btnElement) btnElement.classList.add('active');
  
  currentCategory = categoryType;
  currentFilter = 'ALL';
  filterTable();
}

function filterTable() {
  const searchQuery = document.getElementById('search-box').value.toLowerCase().trim();
  const rows = document.querySelectorAll('#complaints-container .complaint-row-card');
  
  rows.forEach(row => {
    const title = row.querySelector('.title-cell').textContent.toLowerCase();
    const status = row.getAttribute('data-status');
    const category = row.getAttribute('data-category');
    const isCritical = row.getAttribute('data-critical') === 'true';
    
    let matchSearch = title.includes(searchQuery);
    let matchStatus = false;
    
    if (currentFilter === 'ALL') {
      matchStatus = true;
    } else if (currentFilter === 'CRITICAL') {
      matchStatus = isCritical;
    } else {
      matchStatus = (status === currentFilter);
    }
    
    let matchCategory = (currentCategory === 'ALL' || category === currentCategory);
    
    if (matchSearch && matchStatus && matchCategory) {
      row.style.display = 'grid';
    } else {
      row.style.display = 'none';
    }
  });
}

function handleSort() {
  const sortVal = document.getElementById('sort-selector').value;
  const container = document.getElementById('complaints-container');
  const rows = Array.from(container.getElementsByClassName('complaint-row-card'));
  
  rows.sort((a, b) => {
    const idA = parseInt(a.getAttribute('data-id'));
    const idB = parseInt(b.getAttribute('data-id'));
    const sevA = parseInt(a.getAttribute('data-severity'));
    const sevB = parseInt(b.getAttribute('data-severity'));
    
    if (sortVal === 'ID_DESC') {
      return idB - idA;
    } else if (sortVal === 'SEVERITY_DESC') {
      return sevB - sevA;
    } else if (sortVal === 'SEVERITY_ASC') {
      return sevA - sevB;
    }
    return 0;
  });
  
  rows.forEach(row => container.appendChild(row));
}

let selectedComplaintId = null;
let dispatchPollInterval = null;
let isPlayTimeLapse = false;
let timeLapseInterval = null;

function applyMapFilters() {
  const catFilter = document.getElementById('map-filter-cat').value;
  const sevFilter = document.getElementById('map-filter-sev').value;
  const slider = document.getElementById('map-time-slider');
  
  scrubTimeLapse(slider.value);
}

function toggleTimeLapse() {
  const playBtn = document.getElementById('map-play-btn');
  const playIcon = document.getElementById('play-icon');
  const playText = document.getElementById('play-text');
  const slider = document.getElementById('map-time-slider');
  
  if (isPlayTimeLapse) {
    isPlayTimeLapse = false;
    clearInterval(timeLapseInterval);
    playText.textContent = "Time-Lapse";
    playIcon.setAttribute('data-lucide', 'play');
    if (typeof lucide !== 'undefined') lucide.createIcons();
  } else {
    isPlayTimeLapse = true;
    playText.textContent = "Pause";
    playIcon.setAttribute('data-lucide', 'pause');
    if (typeof lucide !== 'undefined') lucide.createIcons();
    
    if (parseInt(slider.value) >= 100) {
      slider.value = 0;
    }
    
    timeLapseInterval = setInterval(() => {
      let val = parseInt(slider.value);
      val += 4;
      if (val > 100) {
        val = 100;
        isPlayTimeLapse = false;
        clearInterval(timeLapseInterval);
        playText.textContent = "Time-Lapse";
        playIcon.setAttribute('data-lucide', 'play');
        if (typeof lucide !== 'undefined') lucide.createIcons();
      }
      slider.value = val;
      scrubTimeLapse(val);
    }, 150);
  }
}

function scrubTimeLapse(value) {
  document.getElementById('map-time-label').textContent = value + "%";
  const catFilter = document.getElementById('map-filter-cat').value;
  const sevFilter = document.getElementById('map-filter-sev').value;
  
  const pins = Array.from(document.querySelectorAll('.map-canvas-container .map-pin'));
  // Sort pins by ID (chronological)
  pins.sort((a, b) => parseInt(a.getAttribute('data-id')) - parseInt(b.getAttribute('data-id')));
  
  const limitIndex = Math.floor((value / 100) * pins.length);
  
  pins.forEach((pin, index) => {
    const cat = pin.getAttribute('data-category');
    const sev = parseInt(pin.getAttribute('data-severity'));
    
    let matchCat = (catFilter === 'ALL' || cat === catFilter);
    let matchSev = false;
    if (sevFilter === 'ALL') matchSev = true;
    else if (sevFilter === 'CRITICAL') matchSev = (sev > 80);
    else if (sevFilter === 'HIGH') matchSev = (sev > 50);
    else if (sevFilter === 'ROUTINE') matchSev = (sev <= 50);
    
    if (matchCat && matchSev && index < limitIndex) {
      pin.style.display = 'block';
    } else {
      pin.style.display = 'none';
    }
  });
}

function showDrawer(id, title, category, status, score, description, imagePath, dispatchStatus, dispatchLog, bountyPool) {
  selectedComplaintId = id;
  document.getElementById('drawer-id').textContent = '#' + id;
  document.getElementById('drawer-title-text').textContent = title;
  document.getElementById('drawer-cat').textContent = category;
  document.getElementById('drawer-status').textContent = status;
  document.getElementById('drawer-score').textContent = score;
  document.getElementById('drawer-desc').textContent = description;
  document.getElementById('drawer-details-link').href = "complaint-details.jsp?id=" + id;
  
  const imgContainer = document.getElementById('drawer-img-container');
  const imgEl = document.getElementById('drawer-evidence-photo');
  if (imagePath && imagePath.trim() !== '') {
    imgEl.src = imagePath;
    imgContainer.style.display = 'block';
  } else {
    imgContainer.style.display = 'none';
  }
  
  // Tactical Response visualizer elements
  const dispatchContainer = document.getElementById('drawer-dispatch-container');
  const idlePanel = document.getElementById('dispatch-idle-panel');
  const activePanel = document.getElementById('dispatch-active-panel');
  
  clearInterval(dispatchPollInterval);
  
  if (status === 'CLOSED') {
    dispatchContainer.style.display = 'none';
  } else {
    dispatchContainer.style.display = 'block';
    if (dispatchStatus === 'IDLE') {
      idlePanel.style.display = 'block';
      activePanel.style.display = 'none';
    } else {
      idlePanel.style.display = 'none';
      activePanel.style.display = 'block';
      renderConsoleLogs(dispatchLog);
      startDispatchPolling(id);
    }
  }
  
  const drawer = document.getElementById('details-drawer');
  drawer.style.display = 'flex';
  setTimeout(() => {
    drawer.classList.add('open');
  }, 10);
}

function renderConsoleLogs(logsJsonString) {
  const consoleEl = document.getElementById('dispatch-terminal-console');
  if (!consoleEl) return;
  try {
    const logs = typeof logsJsonString === 'string' ? JSON.parse(logsJsonString) : logsJsonString;
    consoleEl.innerHTML = '';
    logs.forEach(l => {
      const line = document.createElement('div');
      line.style.marginBottom = '4px';
      line.innerHTML = `<span style="color:var(--danger); font-weight:600;">[${l.time}]</span> ${l.log}`;
      consoleEl.appendChild(line);
    });
    consoleEl.scrollTop = consoleEl.scrollHeight;
  } catch (e) {
    consoleEl.textContent = "Telemetry feed offline.";
  }
}

function startDispatchPolling(complaintId) {
  clearInterval(dispatchPollInterval);
  dispatchPollInterval = setInterval(() => {
    const xhr = new XMLHttpRequest();
    xhr.open("GET", "DispatchServlet?complaintId=" + complaintId, true);
    xhr.onreadystatechange = function() {
      if (xhr.readyState === 4 && xhr.status === 200) {
        const res = JSON.parse(xhr.responseText);
        renderConsoleLogs(res.log);
        
        if (res.dispatchStatus === 'RESOLVED' || res.dispatchStatus === 'CLOSED') {
          document.getElementById('drawer-status').textContent = 'CLOSED';
          clearInterval(dispatchPollInterval);
          setTimeout(() => {
            location.reload();
          }, 2000);
        }
      }
    };
    xhr.send();
  }, 2000);
}

function triggerDispatch(assetType) {
  if (!selectedComplaintId) return;
  
  const idlePanel = document.getElementById('dispatch-idle-panel');
  const activePanel = document.getElementById('dispatch-active-panel');
  const consoleEl = document.getElementById('dispatch-terminal-console');
  
  idlePanel.style.display = 'none';
  activePanel.style.display = 'block';
  consoleEl.innerHTML = 'Connecting with deployed asset and securing telemetry link...';
  
  const xhr = new XMLHttpRequest();
  xhr.open("POST", "DispatchServlet", true);
  xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
  xhr.onreadystatechange = function() {
    if (xhr.readyState === 4) {
      if (xhr.status === 200) {
        const res = JSON.parse(xhr.responseText);
        renderConsoleLogs(res.log);
        startDispatchPolling(selectedComplaintId);
      } else {
        alert("Dispatch sequence failed: " + xhr.responseText);
        idlePanel.style.display = 'block';
        activePanel.style.display = 'none';
      }
    }
  };
  xhr.send("complaintId=" + selectedComplaintId + "&assetType=" + assetType);
}

function closeDrawer() {
  clearInterval(dispatchPollInterval);
  const drawer = document.getElementById('details-drawer');
  drawer.classList.remove('open');
  setTimeout(() => {
    drawer.style.display = 'none';
  }, 400);
}

// Counters dynamic count-up logic
function initializeCounters(instant) {
  const counters = ['count-logged', 'count-critical', 'count-pending', 'count-resolution'];
  
  counters.forEach(cId => {
    const el = document.getElementById(cId);
    if (el) {
      const target = parseInt(el.dataset.target) || 0;
      if (instant) {
        el.textContent = target;
      } else {
        let current = 0;
        const duration = 1200;
        const steps = 30;
        const stepVal = target / steps;
        const intervalTime = duration / steps;
        const timer = setInterval(() => {
          current += stepVal;
          if (current >= target) {
            el.textContent = target;
            clearInterval(timer);
          } else {
            el.textContent = Math.round(current);
          }
        }, intervalTime);
      }
    }
  });
  
  // Animate grid severity bars
  document.querySelectorAll('.bar-fill[data-width]').forEach(el => {
    setTimeout(() => {
      el.style.width = el.dataset.width + '%';
    }, instant ? 10 : 300);
  });
  
  document.querySelectorAll('.chart-fill[data-width]').forEach(el => {
    setTimeout(() => {
      el.style.width = el.dataset.width + '%';
    }, instant ? 10 : 500);
  });
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
  
  // Terminal booting script logs
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
        const color = currentLogIdx === logs.length - 1 ? 'var(--danger)' : 'var(--secondary)';
        
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
  
  // Progress bar syncer
  setTimeout(() => {
    const progressBar = document.getElementById('boot-progress-bar');
    if (progressBar) progressBar.style.width = '100%';
  }, 100);
  
  setTimeout(addNextLog, 300);
  
  // Transition to dashboard
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

// Background connected nodes canvas simulation
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

// Urban Data StreamStreaks
class EnergyStream {
  constructor() {
    this.x = Math.random() * canvas.width;
    this.y = Math.random() * canvas.height;
    this.length = Math.random() * 60 + 40;
    this.speed = Math.random() * 2 + 1;
    this.angle = Math.random() > 0.5 ? 0 : Math.PI / 4;
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
  
  // Data streams
  streams.forEach(s => {
    s.update();
    s.draw();
  });
  
  // Nodes
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

// Boot canvas particles
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
</script>
</body>
</html>
