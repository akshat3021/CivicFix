<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.civicfix.model.Complaint, com.civicfix.dao.ComplaintDAO, com.civicfix.model.User, com.civicfix.dao.UserDAO" %>
<%
    // Security check: Must be logged in as citizen or admin
    String role = (String) session.getAttribute("role");
    User citizen = (User) session.getAttribute("currentUser");
    String adminName = (String) session.getAttribute("adminName");
    if (role == null) {
        response.sendRedirect("login.jsp?error=Authentication Required!");
        return;
    }
    boolean isAdmin = "ADMIN".equals(role);
    if (!isAdmin && citizen == null) {
        response.sendRedirect("login.jsp?error=Authentication Required!");
        return;
    }

    String idParam = request.getParameter("id");
    if (idParam == null || idParam.trim().isEmpty()) {
        response.sendRedirect("index.jsp");
        return;
    }

    int id = 0;
    try {
        id = Integer.parseInt(idParam);
    } catch (NumberFormatException e) {
        response.sendRedirect("index.jsp");
        return;
    }

    Complaint c = ComplaintDAO.getComplaintById(id);
    if (c == null) {
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>CivicFix — Incident Not Found</title>
    <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@500;700&family=Inter:wght@400;600&display=swap" rel="stylesheet">
    <style>
        body { background: #070d0a; color: #fff; font-family: 'Inter', sans-serif; display: flex; align-items: center; justify-content: center; height: 100vh; margin: 0; }
        .box { background: rgba(13, 20, 16, 0.65); padding: 40px; border-radius: 20px; border: 1px solid rgba(52, 211, 153, 0.15); text-align: center; max-width: 400px; }
        h1 { font-family: 'Space Grotesk', sans-serif; color: #EF4444; margin-bottom: 12px; }
        a { color: #34D399; text-decoration: none; font-weight: 600; display: inline-block; margin-top: 20px; }
    </style>
</head>
<body>
    <div class="box">
        <h1>Incident Not Found</h1>
        <p>The requested complaint ID #<%= id %> does not exist or has been removed from the database.</p>
        <a href="index.jsp">Return to Command Hub</a>
    </div>
</body>
</html>
<%
        return;
    }

    // Determine owner details if possible
    int ownerId = c.getUserId();
    // Default fallback status mapping for tracking
    String status = c.getStatus();
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>CivicFix — Incident Details #<%= c.getId() %></title>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Space+Grotesk:wght@400;500;600;700;800&display=swap" rel="stylesheet">
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

/* Background Node Canvas */
#network-canvas {
  position: fixed;
  inset: 0;
  width: 100%;
  height: 100%;
  z-index: 0;
  pointer-events: none;
}

/* Grid pattern */
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

.page-wrapper {
  position: relative;
  z-index: 10;
  min-height: 100vh;
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
  margin: 16px 24px 0;
  border-radius: 20px;
  background: rgba(17, 24, 39, 0.45);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  border: 1px solid var(--border-color);
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.25);
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
.topbar-right {
  display: flex;
  align-items: center;
  gap: 16px;
}
.role-badge {
  font-size: 12px;
  font-weight: 600;
  padding: 6px 14px;
  border-radius: 12px;
  background: rgba(255,255,255,0.03);
  border: 1px solid var(--border-color);
}
.back-btn {
  text-decoration: none;
  font-size: 13px;
  font-weight: 600;
  color: var(--accent);
  display: flex;
  align-items: center;
  gap: 6px;
}

/* Content Layout Grid */
.container {
  max-width: 1200px;
  width: 100%;
  margin: 32px auto;
  padding: 0 24px;
  display: grid;
  grid-template-columns: 1fr 380px;
  gap: 32px;
}

@media (max-width: 1024px) {
  .container {
    grid-template-columns: 1fr;
  }
}

/* Glassmorphism panels */
.smart-panel {
  background: var(--panel-bg);
  backdrop-filter: blur(24px);
  -webkit-backdrop-filter: blur(24px);
  border: 1px solid var(--border-color);
  border-radius: 28px;
  padding: 32px;
  box-shadow: 0 20px 50px rgba(0, 0, 0, 0.3), inset 0 1px 1px rgba(255, 255, 255, 0.05);
  margin-bottom: 32px;
  position: relative;
  overflow: hidden;
}
.smart-panel::before {
  content: '';
  position: absolute;
  inset: 0;
  border-radius: inherit;
  padding: 1.4px;
  background: linear-gradient(180deg, rgba(52, 211, 153, 0.25) 0%, transparent 50%, rgba(16, 185, 129, 0.15) 100%);
  -webkit-mask: linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0);
  -webkit-mask-composite: xor;
  mask-composite: exclude;
  pointer-events: none;
}

/* Title and Tags */
.details-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 20px;
  margin-bottom: 24px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.05);
  padding-bottom: 20px;
}
.details-title-wrap {
  display: flex;
  flex-direction: column;
  gap: 8px;
}
.details-title {
  font-family: 'Space Grotesk', sans-serif;
  font-size: 30px;
  font-weight: 700;
  line-height: 1.2;
  letter-spacing: -0.8px;
  color: #fff;
}
.meta-row {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  align-items: center;
}
.meta-id {
  font-family: monospace;
  font-size: 13px;
  color: var(--text-dim);
}
.cat-tag {
  font-size: 10px;
  font-weight: 700;
  padding: 4px 12px;
  border-radius: 8px;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}
.cat-ROADS { background: rgba(245, 158, 11, 0.08); color: #fbbf24; border: 1px solid rgba(245,158,11,0.15); }
.cat-WATER { background: rgba(14, 165, 233, 0.08); color: #38bdf8; border: 1px solid rgba(14,165,233,0.15); }
.cat-ELECTRIC { background: rgba(168, 85, 247, 0.08); color: #c084fc; border: 1px solid rgba(168,85,247,0.15); }
.cat-SANITATION { background: rgba(16, 185, 129, 0.08); color: #34d399; border: 1px solid rgba(16,185,129,0.15); }
.cat-PUBLIC_SAFETY { background: rgba(244, 63, 94, 0.08); color: #fb7185; border: 1px solid rgba(244,63,94,0.15); }
.cat-OTHER { background: rgba(100, 116, 139, 0.08); color: #94a3b8; border: 1px solid rgba(100,116,139,0.15); }

/* Status timeline style */
.timeline-title {
  font-family: 'Space Grotesk', sans-serif;
  font-size: 18px;
  font-weight: 600;
  margin-bottom: 24px;
  display: flex;
  align-items: center;
  gap: 8px;
}
.timeline-wrapper {
  position: relative;
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-top: 36px;
  margin-bottom: 20px;
  width: 100%;
}
.timeline-line {
  position: absolute;
  top: 24px;
  left: 30px;
  right: 30px;
  height: 4px;
  background: rgba(255, 255, 255, 0.05);
  z-index: 1;
}
.timeline-line-fill {
  height: 100%;
  background: linear-gradient(90deg, var(--accent) 0%, var(--success) 100%);
  width: 0%;
  transition: width 1.5s cubic-bezier(0.16, 1, 0.3, 1);
  box-shadow: 0 0 10px rgba(52, 211, 153, 0.5);
}
.timeline-node {
  position: relative;
  z-index: 2;
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  flex: 1;
}
.node-circle {
  width: 50px;
  height: 50px;
  border-radius: 50%;
  background: #111827;
  border: 2px solid rgba(255, 255, 255, 0.1);
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s;
  color: var(--text-dim);
}
.node-circle i {
  width: 18px;
  height: 18px;
}
.timeline-node.active .node-circle {
  background: #0B1220;
  border-color: var(--accent);
  color: var(--accent);
  box-shadow: 0 0 20px var(--accent-glow);
}
.timeline-node.completed .node-circle {
  background: var(--success);
  border-color: var(--success);
  color: #0B1220;
  box-shadow: 0 0 15px rgba(16, 185, 129, 0.3);
}
.node-lbl {
  font-size: 12px;
  font-weight: 700;
  margin-top: 14px;
  color: var(--text-muted);
  text-transform: uppercase;
  letter-spacing: 0.5px;
}
.timeline-node.active .node-lbl {
  color: #fff;
}
.timeline-node.completed .node-lbl {
  color: var(--success);
}
.node-time {
  font-size: 10px;
  color: var(--text-dim);
  margin-top: 4px;
}

/* Image preview section */
.details-body {
  display: flex;
  flex-direction: column;
  gap: 24px;
}
.description-text {
  font-size: 15px;
  line-height: 1.6;
  color: var(--text-muted);
  white-space: pre-wrap;
}
.details-image-wrap {
  border-radius: 18px;
  overflow: hidden;
  border: 1px solid rgba(255, 255, 255, 0.05);
  background: #000;
  margin-top: 16px;
  max-width: 100%;
}
.details-image {
  width: 100%;
  max-height: 480px;
  object-fit: contain;
  display: block;
}

/* Severity gauge dial */
.severity-row {
  display: flex;
  align-items: center;
  gap: 16px;
  margin-top: 8px;
}
.severity-value-box {
  background: rgba(255, 255, 255, 0.02);
  border: 1px solid var(--border-color);
  border-radius: 12px;
  padding: 10px 16px;
  display: flex;
  align-items: center;
  gap: 10px;
}
.severity-score-number {
  font-family: 'Space Grotesk', sans-serif;
  font-size: 24px;
  font-weight: 700;
}
.score-indicator-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
}
.critical-pulse {
  animation: severityPulse 1.5s infinite;
}
@keyframes severityPulse {
  0% { transform: scale(0.9); opacity: 0.6; }
  50% { transform: scale(1.3); opacity: 1; box-shadow: 0 0 10px currentColor; }
  100% { transform: scale(0.9); opacity: 0.6; }
}

/* Stats list details */
.stats-list {
  display: flex;
  flex-direction: column;
  gap: 14px;
  margin-top: 24px;
  border-top: 1px dashed rgba(255, 255, 255, 0.06);
  padding-top: 20px;
}
.stat-item-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 13.5px;
}
.stat-lbl-txt {
  color: var(--text-dim);
}
.stat-val-txt {
  color: #fff;
  font-weight: 500;
}

/* Admin control block */
.admin-controls-title {
  font-family: 'Space Grotesk', sans-serif;
  font-size: 16px;
  font-weight: 700;
  color: var(--accent);
  margin-bottom: 18px;
  display: flex;
  align-items: center;
  gap: 8px;
  border-bottom: 1px solid rgba(52, 211, 153, 0.15);
  padding-bottom: 8px;
}
.control-form-group {
  margin-bottom: 18px;
}
.control-form-lbl {
  display: block;
  font-size: 10px;
  font-weight: 700;
  text-transform: uppercase;
  color: var(--text-dim);
  letter-spacing: 0.1em;
  margin-bottom: 8px;
}
.status-btn-row {
  display: flex;
  gap: 8px;
}
.status-toggle-btn {
  flex: 1;
  background: rgba(255, 255, 255, 0.02);
  border: 1px solid var(--border-color);
  color: var(--text-muted);
  padding: 10px;
  border-radius: 12px;
  font-size: 11px;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.2s;
}
.status-toggle-btn:hover {
  background: rgba(255,255,255,0.05);
  color: #fff;
}
.status-toggle-btn.active[data-val="OPEN"] {
  background: rgba(245, 158, 11, 0.12);
  border-color: var(--warn);
  color: var(--warn);
}
.status-toggle-btn.active[data-val="IN_PROGRESS"] {
  background: rgba(99, 102, 241, 0.12);
  border-color: var(--primary);
  color: #a5b4fc;
}
.status-toggle-btn.active[data-val="CLOSED"] {
  background: rgba(16, 185, 129, 0.12);
  border-color: var(--success);
  color: var(--success);
}

/* Slider */
.slider-container {
  display: flex;
  align-items: center;
  gap: 12px;
}
.range-slider {
  flex: 1;
  -webkit-appearance: none;
  background: rgba(255, 255, 255, 0.08);
  height: 6px;
  border-radius: 3px;
  outline: none;
}
.range-slider::-webkit-slider-thumb {
  -webkit-appearance: none;
  width: 16px;
  height: 16px;
  border-radius: 50%;
  background: var(--accent);
  box-shadow: 0 0 10px var(--accent-glow);
  cursor: pointer;
  transition: transform 0.1s;
}
.range-slider::-webkit-slider-thumb:hover {
  transform: scale(1.2);
}
.slider-val-display {
  font-family: 'Space Grotesk', sans-serif;
  font-size: 16px;
  font-weight: 700;
  width: 32px;
  text-align: right;
}

.action-btn-primary {
  width: 100%;
  padding: 12px;
  background: var(--accent);
  color: #070b14;
  border: none;
  font-family: 'Space Grotesk', sans-serif;
  font-size: 13.5px;
  font-weight: 700;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.25s;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  margin-top: 20px;
}
.action-btn-primary:hover:not(:disabled) {
  background: #6ee7b7;
  box-shadow: 0 5px 15px rgba(52, 211, 153, 0.35);
  transform: translateY(-1px);
}
.action-btn-primary:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* Citizen upvote block */
.citizen-action-box {
  background: rgba(16, 185, 129, 0.03);
  border: 1px dashed rgba(16, 185, 129, 0.2);
  border-radius: 20px;
  padding: 20px;
  text-align: center;
}
.upvote-large-btn {
  background: var(--primary);
  color: #fff;
  border: none;
  padding: 12px 24px;
  border-radius: 12px;
  font-family: 'Space Grotesk', sans-serif;
  font-size: 13.5px;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.2s;
  display: inline-flex;
  align-items: center;
  gap: 8px;
  margin-top: 12px;
}
.upvote-large-btn:hover:not(:disabled) {
  background: var(--secondary);
  box-shadow: 0 5px 15px var(--primary-glow);
}
.upvote-large-btn:disabled {
  background: rgba(16, 185, 129, 0.15);
  color: var(--success);
  border: 1px solid rgba(16,185,129,0.3);
  cursor: not-allowed;
}
</style>
</head>
<body>

<canvas id="network-canvas"></canvas>
<div class="blueprint-grid"></div>

<div class="page-wrapper">
  <!-- Topbar Header -->
  <div class="topbar">
    <a href="index.jsp" class="logo-wrap">
      <div class="logo-icon">
        <i data-lucide="sparkles" style="color:#fff;"></i>
      </div>
      <span class="logo-text">CIVIC<span>FIX</span></span>
    </a>
    
    <div class="topbar-right">
      <% if (isAdmin) { %>
        <span class="role-badge" style="color:var(--danger);">Admin Portal</span>
        <a href="admin" class="back-btn"><i data-lucide="arrow-left"></i> <span>Control Matrix</span></a>
      <% } else { %>
        <span class="role-badge" style="color:var(--accent);">Citizen: <%= citizen.getUsername() %></span>
        <a href="user-dashboard.jsp" class="back-btn"><i data-lucide="arrow-left"></i> <span>Dashboard</span></a>
      <% } %>
    </div>
  </div>

  <!-- Content Grid -->
  <div class="container">
    <!-- Left Area: Summary and timeline -->
    <div>
      <div class="smart-panel">
        <div class="details-header">
          <div class="details-title-wrap">
            <h1 class="details-title" id="complaint-title-text"><%= c.getTitle() %></h1>
            <div class="meta-row">
              <span class="meta-id">ID: #<%= c.getId() %></span>
              <span class="cat-tag cat-<%= c.getCategory() %>"><%= c.getCategory() %></span>
              <span class="meta-id">Reported by Citizen ID #<%= c.getUserId() %></span>
            </div>
          </div>
          
          <div class="severity-row">
            <div class="severity-value-box">
              <div class="score-indicator-dot" id="severity-dot"></div>
              <div class="severity-score-number" id="severity-display-score"><%= c.getSeverityScore() %></div>
              <div style="font-size:10px; font-weight:700; color:var(--text-dim); text-transform:uppercase;">Priority</div>
            </div>
          </div>
        </div>

        <div class="details-body">
          <div class="description-text"><%= c.getDescription() %></div>
          
          <% if (c.getImagePath() != null && !c.getImagePath().trim().isEmpty()) { %>
            <div class="details-image-wrap">
              <img src="<%= c.getImagePath() %>" class="details-image" id="complaint-evidence-image" alt="Evidence Photo">
            </div>
          <% } %>
        </div>
      </div>

      <!-- Real-Time Status Progress Timeline -->
      <div class="smart-panel">
        <div class="timeline-title">
          <i data-lucide="clock" style="color:var(--accent); width:18px; height:18px;"></i>
          <span>Real-time Status Telemetry</span>
        </div>
        
        <div class="timeline-wrapper">
          <div class="timeline-line">
            <div class="timeline-line-fill" id="timeline-bar"></div>
          </div>
          
          <!-- Node 1: Reported -->
          <div class="timeline-node" id="node-reported">
            <div class="node-circle"><i data-lucide="file-text"></i></div>
            <div class="node-lbl">Logged</div>
            <div class="node-time">Stage 1</div>
          </div>
          
          <!-- Node 2: Under Review -->
          <div class="timeline-node" id="node-reviewed">
            <div class="node-circle"><i data-lucide="shield-alert"></i></div>
            <div class="node-lbl">Reviewed</div>
            <div class="node-time">Stage 2</div>
          </div>
          
          <!-- Node 3: Dispatched -->
          <div class="timeline-node" id="node-dispatched">
            <div class="node-circle"><i data-lucide="truck"></i></div>
            <div class="node-lbl">Crew Assigned</div>
            <div class="node-time">Stage 3</div>
          </div>
          
          <!-- Node 4: In Progress -->
          <div class="timeline-node" id="node-progress">
            <div class="node-circle"><i data-lucide="wrench"></i></div>
            <div class="node-lbl">In Progress</div>
            <div class="node-time">Stage 4</div>
          </div>
          
          <!-- Node 5: Resolved -->
          <div class="timeline-node" id="node-resolved">
            <div class="node-circle"><i data-lucide="check-circle2"></i></div>
            <div class="node-lbl">Completed</div>
            <div class="node-time">Stage 5</div>
          </div>
        </div>
      </div>
    </div>

    <!-- Right Area: Sidebar stats and settings -->
    <div>
      <div class="smart-panel" style="padding:24px;">
        <div class="admin-controls-title">
          <i data-lucide="bar-chart-2"></i>
          <span>Telemetry Info</span>
        </div>
        
        <div class="stat-item-row" style="margin-top: 8px;">
          <span class="stat-lbl-txt">Active Urgency</span>
          <span class="stat-val-txt" id="sidebar-urgency" style="font-weight:700;">Medium</span>
        </div>
        
        <div class="stats-list">
          <div class="stat-item-row">
            <span class="stat-lbl-txt">Incident Status</span>
            <span class="stat-val-txt" id="sidebar-status" style="text-transform:uppercase; font-weight:700;"><%= c.getStatus() %></span>
          </div>
          <div class="stat-item-row">
            <span class="stat-lbl-txt">Upvote Severity</span>
            <span class="stat-val-txt" id="sidebar-upvotes"><%= c.getSeverityScore() >= 50 ? (c.getSeverityScore() - 50) / 10 : 0 %> Votes</span>
          </div>
          <div class="stat-item-row">
            <span class="stat-lbl-txt">Reporter ID</span>
            <span class="stat-val-txt">#<%= c.getUserId() %></span>
          </div>
          <div class="stat-item-row">
            <span class="stat-lbl-txt">Jurisdiction</span>
            <span class="stat-val-txt">Central District</span>
          </div>
        </div>
      </div>

      <% if (isAdmin) { %>
        <!-- Administrator controls panel -->
        <div class="smart-panel" style="padding:24px;">
          <div class="admin-controls-title">
            <i data-lucide="sliders"></i>
            <span>Admin Control Panel</span>
          </div>
          
          <div class="control-form-group">
            <label class="control-form-lbl">Assign Status State</label>
            <div class="status-btn-row">
              <button type="button" class="status-toggle-btn" data-val="OPEN" onclick="setAdminStatus('OPEN')">OPEN</button>
              <button type="button" class="status-toggle-btn" data-val="IN_PROGRESS" onclick="setAdminStatus('IN_PROGRESS')">IN PROG</button>
              <button type="button" class="status-toggle-btn" data-val="CLOSED" onclick="setAdminStatus('CLOSED')">RESOLVED</button>
            </div>
          </div>
          
          <div class="control-form-group" style="margin-top: 24px;">
            <label class="control-form-lbl">Severity Calibration</label>
            <div class="slider-container">
              <input type="range" class="range-slider" id="admin-severity-slider" min="0" max="100" value="<%= c.getSeverityScore() %>" oninput="updateSliderVal(this.value)">
              <span class="slider-val-display" id="slider-val-num"><%= c.getSeverityScore() %></span>
            </div>
          </div>
          
          <button type="button" class="action-btn-primary" id="admin-save-btn" onclick="saveAdminChanges()">
            <i data-lucide="save" style="width:14px; height:14px;"></i>
            <span>Apply Telemetry</span>
          </button>
        </div>
      <% } else { %>
        <!-- Citizen severity booster panel -->
        <div class="citizen-action-box smart-panel" style="padding:24px;">
          <h3 style="font-family:'Space Grotesk', sans-serif; font-size:15px; margin-bottom:8px;">Escalate Complaint Urgency</h3>
          <p style="font-size:11px; color:var(--text-dim); line-height:1.4;">Has this issue become worse? Upvote to notify dispatcher and request priority escalation.</p>
          
          <% if (!"CLOSED".equals(c.getStatus())) { %>
            <button type="button" class="upvote-large-btn" id="citizen-upvote-btn" onclick="citizenUpvote()">
              <i data-lucide="wand-2" style="width:14px; height:14px;"></i>
              <span>Upvote Severity</span>
            </button>
          <% } else { %>
            <button type="button" class="upvote-large-btn" disabled>
              <i data-lucide="check" style="width:14px; height:14px;"></i>
              <span>Issue Resolved</span>
            </button>
          <% } %>
        </div>
      <% } %>
    </div>
  </div>
</div>

<script>
// Emergency client script error boundary
window.addEventListener('error', function(e) {
  console.error("Global incident details error:", e);
  const errorBox = document.createElement('div');
  errorBox.style.position = 'fixed';
  errorBox.style.bottom = '20px';
  errorBox.style.left = '20px';
  errorBox.style.background = 'rgba(239, 68, 68, 0.95)';
  errorBox.style.border = '1px solid #ef4444';
  errorBox.style.color = '#fff';
  errorBox.style.padding = '16px';
  errorBox.style.borderRadius = '12px';
  errorBox.style.zIndex = '9999';
  errorBox.style.fontFamily = 'monospace';
  errorBox.style.fontSize = '12px';
  errorBox.style.maxWidth = '360px';
  errorBox.style.boxShadow = '0 10px 25px rgba(0,0,0,0.5)';
  errorBox.innerHTML = '<strong>⚠️ Client Script Exception:</strong><br>' + e.message + '<br><span style="opacity:0.8;">at ' + (e.filename ? e.filename.split('/').pop() : 'inline') + ':' + e.lineno + '</span>';
  document.body.appendChild(errorBox);
});

// Initialize Lucide icons if available
if (typeof lucide !== 'undefined') {
  try {
    lucide.createIcons();
  } catch (e) {
    console.error("Lucide icon generation failed:", e);
  }
}

// Store current state variables
let currentStatus = "<%= c.getStatus() %>";
let currentSeverity = <%= c.getSeverityScore() %>;
const complaintId = <%= c.getId() %>;

// Update status progress bar and active classes
function updateTimelineDisplay(statusStr, severityVal) {
  // 1. Reset classes
  document.querySelectorAll('.timeline-node').forEach(n => {
    n.classList.remove('active', 'completed');
  });
  
  const bar = document.getElementById('timeline-bar');
  const nodeReported = document.getElementById('node-reported');
  const nodeReviewed = document.getElementById('node-reviewed');
  const nodeDispatched = document.getElementById('node-dispatched');
  const nodeProgress = document.getElementById('node-progress');
  const nodeResolved = document.getElementById('node-resolved');
  
  // Always completed stage 1
  nodeReported.classList.add('completed');
  
  if (statusStr === 'OPEN') {
    nodeReviewed.classList.add('active');
    bar.style.width = '25%';
  } else if (statusStr === 'IN_PROGRESS') {
    nodeReviewed.classList.add('completed');
    nodeDispatched.classList.add('completed');
    nodeProgress.classList.add('active');
    bar.style.width = '75%';
  } else if (statusStr === 'CLOSED') {
    nodeReviewed.classList.add('completed');
    nodeDispatched.classList.add('completed');
    nodeProgress.classList.add('completed');
    nodeResolved.classList.add('completed');
    bar.style.width = '100%';
  }
  
  // Update status displays
  const statusLabel = document.getElementById('sidebar-status');
  if (statusLabel) {
    statusLabel.textContent = statusStr.replace("_", " ");
    statusLabel.className = "stat-val-txt";
    if (statusStr === 'OPEN') statusLabel.style.color = 'var(--warn)';
    else if (statusStr === 'IN_PROGRESS') statusLabel.style.color = '#a5b4fc';
    else if (statusStr === 'CLOSED') statusLabel.style.color = 'var(--success)';
  }
  
  // Update severity displays
  const scoreDisplay = document.getElementById('severity-display-score');
  const severityDot = document.getElementById('severity-dot');
  const urgencyLabel = document.getElementById('sidebar-urgency');
  
  if (scoreDisplay) scoreDisplay.textContent = severityVal;
  
  if (severityDot) {
    severityDot.className = "score-indicator-dot";
    if (severityVal > 80) {
      severityDot.style.background = 'var(--danger)';
      severityDot.style.boxShadow = '0 0 10px var(--danger)';
      severityDot.classList.add('critical-pulse');
      if (urgencyLabel) { urgencyLabel.textContent = "CRITICAL ALERT"; urgencyLabel.style.color = 'var(--danger)'; }
    } else if (severityVal > 50) {
      severityDot.style.background = 'var(--warn)';
      severityDot.style.boxShadow = '0 0 8px var(--warn)';
      if (urgencyLabel) { urgencyLabel.textContent = "HIGH URGENCY"; urgencyLabel.style.color = 'var(--warn)'; }
    } else {
      severityDot.style.background = 'var(--accent)';
      severityDot.style.boxShadow = '0 0 6px var(--accent)';
      if (urgencyLabel) { urgencyLabel.textContent = "ROUTINE TRACKING"; urgencyLabel.style.color = 'var(--accent)'; }
    }
  }
}

// Initial triggers
window.addEventListener('load', () => {
  try {
    updateTimelineDisplay(currentStatus, currentSeverity);
  } catch (err) {
    console.error("Timeline display error:", err);
  }
  
  try {
    // Highlight correct admin status button if exists
    const activeBtn = document.querySelector('.status-toggle-btn[data-val="' + currentStatus + '"]');
    if (activeBtn) activeBtn.classList.add('active');
  } catch (err) {
    console.error("Admin toggle highlight error:", err);
  }
});

// Admin interactive handles
let selectedAdminStatus = currentStatus;

function setAdminStatus(statusVal) {
  selectedAdminStatus = statusVal;
  document.querySelectorAll('.status-toggle-btn').forEach(btn => {
    btn.classList.remove('active');
  });
  const target = document.querySelector('.status-toggle-btn[data-val="' + statusVal + '"]');
  if (target) target.classList.add('active');
}

function updateSliderVal(val) {
  document.getElementById('slider-val-num').textContent = val;
}

function saveAdminChanges() {
  const saveBtn = document.getElementById('admin-save-btn');
  const severityInput = document.getElementById('admin-severity-slider');
  const severityValue = parseInt(severityInput.value);
  
  saveBtn.disabled = true;
  saveBtn.querySelector('span').textContent = "Updating...";
  
  const xhr = new XMLHttpRequest();
  xhr.open("POST", "update-complaint", true);
  xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
  xhr.onreadystatechange = function() {
    if (xhr.readyState === 4) {
      saveBtn.disabled = false;
      saveBtn.querySelector('span').textContent = "Apply Telemetry";
      
      if (xhr.status === 200) {
        const resp = JSON.parse(xhr.responseText);
        if (resp.ok) {
          currentStatus = selectedAdminStatus;
          currentSeverity = severityValue;
          updateTimelineDisplay(currentStatus, currentSeverity);
          alert("Telemetry metrics saved!");
        } else {
          alert("Error: " + resp.msg);
        }
      } else {
        alert("Server failed to update complaint details.");
      }
    }
  };
  xhr.send("id=" + complaintId + "&status=" + selectedAdminStatus + "&severity=" + severityValue);
}

// Citizen upvote handler
function citizenUpvote() {
  const btn = document.getElementById('citizen-upvote-btn');
  btn.disabled = true;
  btn.querySelector('span').textContent = "Registering...";
  
  const xhr = new XMLHttpRequest();
  xhr.open("POST", "VoteServlet", true);
  xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
  xhr.onreadystatechange = function() {
    if (xhr.readyState === 4) {
      if (xhr.status === 200 || xhr.status === 302) {
        currentSeverity += 10;
        updateTimelineDisplay(currentStatus, currentSeverity);
        btn.querySelector('span').textContent = "Escalated ✓";
        
        const upvotesDisplay = document.getElementById('sidebar-upvotes');
        if (upvotesDisplay) {
          const currentUpvotes = Math.max(0, (currentSeverity - 50) / 10);
          upvotesDisplay.textContent = currentUpvotes + " Votes";
        }
      } else {
        alert("Failed to record escalation upvote. Try again.");
        btn.disabled = false;
        btn.querySelector('span').textContent = "Upvote Severity";
      }
    }
  };
  xhr.send("complaintId=" + complaintId);
}

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
