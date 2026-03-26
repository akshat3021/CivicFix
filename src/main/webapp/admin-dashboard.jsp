<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List, com.civicfix.model.Complaint" %>
<%
    // SECURITY: Block direct access — must come through AdminController
    if (session.getAttribute("adminName") == null) {
        response.sendRedirect("login.jsp?error=Access Denied! Please login as Admin.");
        return;
    }
    String adminName = (String) session.getAttribute("adminName");
    List<Complaint> complaintList = (List<Complaint>) request.getAttribute("complaintList");
    int total = complaintList != null ? complaintList.size() : 0;
    int critical = 0, resolved = 0, open = 0;
    if (complaintList != null) {
        for (Complaint c : complaintList) {
            if ("CLOSED".equals(c.getStatus())) resolved++;
            else { open++;
                if (c.getSeverityScore() > 80) critical++;
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>CivicFix — Command Center</title>
<link href="https://fonts.googleapis.com/css2?family=Share+Tech+Mono&family=Barlow+Condensed:wght@300;400;600;700&family=Barlow:wght@300;400;500&display=swap" rel="stylesheet">
<style>
*{margin:0;padding:0;box-sizing:border-box;}
:root{
  --bg:#080c10;--surface:#0d1117;--surface2:#111820;--border:#1e2d3d;
  --accent:#00d4ff;--accent2:#00ff88;--danger:#ff3b5c;--warn:#ffb800;
  --text:#c9d1d9;--text-dim:#586069;
  --mono:'Share Tech Mono',monospace;
  --head:'Barlow Condensed',sans-serif;
  --body:'Barlow',sans-serif;
}
body{background:var(--bg);color:var(--text);font-family:var(--body);min-height:100vh;overflow-x:hidden;}
body::before{content:'';position:fixed;inset:0;background:repeating-linear-gradient(0deg,transparent,transparent 2px,rgba(0,212,255,0.012) 2px,rgba(0,212,255,0.012) 4px);pointer-events:none;z-index:999;}
@keyframes pulse{0%,100%{opacity:1;transform:scale(1);}50%{opacity:.5;transform:scale(.8);}}

/* TOPBAR */
.topbar{display:flex;align-items:center;justify-content:space-between;padding:0 28px;height:52px;background:var(--surface);border-bottom:1px solid var(--border);position:sticky;top:0;z-index:100;}
.logo{font-family:var(--head);font-size:22px;font-weight:700;letter-spacing:3px;color:#fff;display:flex;align-items:center;gap:10px;}
.logo-dot{width:8px;height:8px;background:var(--accent);border-radius:50%;box-shadow:0 0 8px var(--accent);animation:pulse 2s infinite;}
.topbar-right{display:flex;align-items:center;gap:20px;font-family:var(--mono);font-size:11px;color:var(--text-dim);}
.status-pill{display:flex;align-items:center;gap:6px;padding:4px 10px;border:1px solid var(--accent2);border-radius:2px;color:var(--accent2);font-size:10px;}
.status-dot{width:6px;height:6px;border-radius:50%;background:var(--accent2);animation:pulse 1.5s infinite;}
.admin-badge{padding:4px 12px;background:rgba(0,212,255,.08);border:1px solid rgba(0,212,255,.2);border-radius:2px;color:var(--accent);}
.logout-link{color:var(--danger);text-decoration:none;letter-spacing:1px;transition:opacity .15s;}
.logout-link:hover{opacity:.7;}

/* LAYOUT */
.layout{display:grid;grid-template-columns:220px 1fr;min-height:calc(100vh - 52px);}
.sidebar{background:var(--surface);border-right:1px solid var(--border);padding:24px 0;}
.sidebar-label{font-family:var(--mono);font-size:9px;color:var(--text-dim);letter-spacing:2px;padding:0 20px;margin-bottom:8px;margin-top:24px;}
.sidebar-label:first-child{margin-top:0;}
.nav-item{display:flex;align-items:center;gap:10px;padding:10px 20px;font-size:13px;color:var(--text-dim);cursor:pointer;border-left:2px solid transparent;text-decoration:none;transition:all .15s;}
.nav-item:hover{color:var(--text);background:rgba(255,255,255,.03);}
.nav-item.active{color:var(--accent);border-left-color:var(--accent);background:rgba(0,212,255,.05);}
.nav-count{margin-left:auto;font-family:var(--mono);font-size:10px;padding:2px 6px;background:rgba(255,59,92,.15);color:var(--danger);border-radius:2px;}

/* MAIN */
.main{padding:28px;overflow-y:auto;}
.page-title{font-family:var(--head);font-size:32px;font-weight:700;letter-spacing:2px;color:#fff;line-height:1;}
.page-sub{font-family:var(--mono);font-size:11px;color:var(--text-dim);margin-top:6px;letter-spacing:1px;margin-bottom:28px;}

/* STATS */
.stats{display:grid;grid-template-columns:repeat(4,1fr);gap:14px;margin-bottom:28px;}
.stat-card{background:var(--surface);border:1px solid var(--border);padding:18px 20px;position:relative;overflow:hidden;}
.stat-card::after{content:'';position:absolute;top:0;left:0;right:0;height:2px;}
.stat-card.c1::after{background:var(--accent);}
.stat-card.c2::after{background:var(--danger);}
.stat-card.c3::after{background:var(--warn);}
.stat-card.c4::after{background:var(--accent2);}
.stat-label{font-family:var(--mono);font-size:9px;letter-spacing:2px;color:var(--text-dim);margin-bottom:10px;}
.stat-val{font-family:var(--head);font-size:42px;font-weight:700;color:#fff;line-height:1;}
.stat-card.c2 .stat-val{color:var(--danger);}
.stat-card.c3 .stat-val{color:var(--warn);}
.stat-card.c4 .stat-val{color:var(--accent2);}

/* TABLE */
.table-header{display:flex;align-items:center;justify-content:space-between;margin-bottom:14px;}
.table-title{font-family:var(--head);font-size:16px;font-weight:600;letter-spacing:2px;color:#fff;}
.filter-row{display:flex;gap:6px;}
.filter-btn{font-family:var(--mono);font-size:10px;padding:5px 12px;border:1px solid var(--border);background:transparent;color:var(--text-dim);cursor:pointer;border-radius:2px;transition:all .15s;letter-spacing:1px;}
.filter-btn:hover,.filter-btn.active{border-color:var(--accent);color:var(--accent);background:rgba(0,212,255,.06);}

.ctable{width:100%;border-collapse:collapse;font-size:13px;}
.ctable th{font-family:var(--mono);font-size:9px;letter-spacing:2px;color:var(--text-dim);text-align:left;padding:10px 14px;border-bottom:1px solid var(--border);font-weight:400;}
.ctable td{padding:14px;border-bottom:1px solid rgba(30,45,61,.5);vertical-align:middle;}
.ctable tr:hover td{background:rgba(255,255,255,.02);}
.ctable tr.closed-row{opacity:.45;}

.id-cell{font-family:var(--mono);font-size:11px;color:var(--text-dim);}
.cat-badge{font-family:var(--mono);font-size:9px;padding:3px 8px;border-radius:2px;letter-spacing:1px;border:1px solid;}
.cat-ROADS{color:#ffb800;border-color:rgba(255,184,0,.3);background:rgba(255,184,0,.06);}
.cat-WATER{color:#00d4ff;border-color:rgba(0,212,255,.3);background:rgba(0,212,255,.06);}
.cat-SANITATION{color:#00ff88;border-color:rgba(0,255,136,.3);background:rgba(0,255,136,.06);}
.cat-ELECTRIC{color:#ff7043;border-color:rgba(255,112,67,.3);background:rgba(255,112,67,.06);}
.cat-PUBLIC_SAFETY{color:#e040fb;border-color:rgba(224,64,251,.3);background:rgba(224,64,251,.06);}
.cat-OTHER{color:#90a4ae;border-color:rgba(144,164,174,.3);background:rgba(144,164,174,.06);}

.score-wrap{display:flex;align-items:center;gap:8px;}
.score-num{font-family:var(--mono);min-width:28px;}
.score-critical{color:var(--danger);font-weight:700;}
.score-high{color:var(--warn);}
.score-normal{color:var(--accent2);}
.score-tag{font-family:var(--mono);font-size:9px;letter-spacing:1px;padding:2px 6px;border-radius:2px;}
.tag-critical{color:var(--danger);background:rgba(255,59,92,.1);border:1px solid rgba(255,59,92,.3);}
.bar-bg{width:60px;height:3px;background:var(--border);border-radius:2px;}
.bar-fill{height:100%;border-radius:2px;width:0;}
.bar-danger{background:#ff3b5c;box-shadow:0 0 5px #ff3b5c;}
.bar-warn{background:#ffb800;}
.bar-ok{background:#00ff88;}

.status-open{font-family:var(--mono);font-size:10px;color:var(--warn);display:flex;align-items:center;gap:5px;letter-spacing:1px;}
.status-open::before{content:'';width:5px;height:5px;border-radius:50%;background:var(--warn);display:inline-block;animation:pulse 1.5s infinite;}
.status-closed{font-family:var(--mono);font-size:10px;color:var(--text-dim);display:flex;align-items:center;gap:5px;letter-spacing:1px;}
.status-closed::before{content:'';width:5px;height:5px;border-radius:50%;background:var(--text-dim);display:inline-block;}

.resolve-btn{font-family:var(--mono);font-size:10px;padding:5px 12px;border:1px solid rgba(0,255,136,.4);background:rgba(0,255,136,.06);color:var(--accent2);cursor:pointer;border-radius:2px;letter-spacing:1px;text-decoration:none;transition:all .15s;display:inline-block;}
.resolve-btn:hover{background:rgba(0,255,136,.15);border-color:var(--accent2);}
.resolved-tag{font-family:var(--mono);font-size:10px;color:var(--text-dim);letter-spacing:1px;}

.empty-state{text-align:center;padding:60px;font-family:var(--mono);font-size:13px;color:var(--text-dim);}
</style>
</head>
<body>

<div class="topbar">
  <div class="logo">
    <span class="logo-dot"></span>
    CIVICFIX
    <span style="font-weight:300;color:var(--text-dim);font-size:14px;letter-spacing:1px;">// COMMAND CENTER</span>
  </div>
  <div class="topbar-right">
    <span class="status-pill"><span class="status-dot"></span>SYSTEM ONLINE</span>
    <span class="admin-badge">ADMIN: <%= adminName %></span>
    <a href="auth?action=logout" class="logout-link">[ LOGOUT ]</a>
  </div>
</div>

<div class="layout">
  <div class="sidebar">
    <div class="sidebar-label">NAVIGATION</div>
    <a href="admin" class="nav-item active">
      ▣ All Complaints
      <% if(open > 0) { %><span class="nav-count"><%= open %></span><% } %>
    </a>
    <a href="#" class="nav-item">⚠ Critical Issues</a>
    <a href="#" class="nav-item">✓ Resolved</a>
    <div class="sidebar-label">CATEGORIES</div>
    <a href="#" class="nav-item">ROADS</a>
    <a href="#" class="nav-item">WATER</a>
    <a href="#" class="nav-item">ELECTRIC</a>
    <a href="#" class="nav-item">SANITATION</a>
    <a href="#" class="nav-item">PUBLIC SAFETY</a>
  </div>

  <div class="main">
    <div class="page-title">COMPLAINT MATRIX</div>
    <div class="page-sub">// REAL-TIME CIVIC ISSUE TRACKER — MUNICIPAL OPERATIONS</div>

    <div class="stats">
      <div class="stat-card c1">
        <div class="stat-label">TOTAL REPORTED</div>
        <div class="stat-val"><%= total %></div>
      </div>
      <div class="stat-card c2">
        <div class="stat-label">CRITICAL PRIORITY</div>
        <div class="stat-val"><%= critical %></div>
      </div>
      <div class="stat-card c3">
        <div class="stat-label">PENDING REVIEW</div>
        <div class="stat-val"><%= open %></div>
      </div>
      <div class="stat-card c4">
        <div class="stat-label">RESOLVED</div>
        <div class="stat-val"><%= resolved %></div>
      </div>
    </div>

    <div class="table-header">
      <div class="table-title">LIVE INCIDENT FEED</div>
      <div class="filter-row">
        <button class="filter-btn active">ALL</button>
        <button class="filter-btn">OPEN</button>
        <button class="filter-btn">CRITICAL</button>
        <button class="filter-btn">CLOSED</button>
      </div>
    </div>

    <table class="ctable">
      <thead>
        <tr>
          <th>ID</th>
          <th>CATEGORY</th>
          <th>ISSUE TITLE</th>
          <th>PRIORITY SCORE</th>
          <th>STATUS</th>
          <th>ACTION</th>
        </tr>
      </thead>
      <tbody>
        <% if (complaintList == null || complaintList.isEmpty()) { %>
        <tr><td colspan="6" class="empty-state">// NO COMPLAINTS IN SYSTEM</td></tr>
        <% } else {
            for (Complaint c : complaintList) {
                boolean isClosed = "CLOSED".equals(c.getStatus());
                int score = c.getSeverityScore();
                String scoreClass = score > 80 ? "score-critical" : score > 60 ? "score-high" : "score-normal";
                String barClass  = score > 80 ? "bar-danger"  : score > 60 ? "bar-warn"   : "bar-ok";
        %>
        <tr class="<%= isClosed ? "closed-row" : "" %>">
          <td class="id-cell">#<%= c.getId() %></td>
          <td><span class="cat-badge cat-<%= c.getCategory() %>"><%= c.getCategory() %></span></td>
          <td><%= c.getTitle() %></td>
          <td>
              <div class="score-wrap">
              <span class="score-num <%= scoreClass %>"><%= score %></span>
              <div class="bar-bg"><div class="bar-fill <%= barClass %>" data-width="<%= score %>"></div></div>
              <% if (score > 80) { %><span class="score-tag tag-critical">CRITICAL</span><% } %>
            </div>
          </td>
          <td>
            <% if (isClosed) { %><span class="status-closed">CLOSED<% } else { %><span class="status-open">OPEN<% } %></span>
          </td>
          <td>
            <% if (isClosed) { %>
              <span class="resolved-tag">RESOLVED ✓</span>
            <% } else { %>
              <a href="admin?action=resolve&id=<%= c.getId() %>" class="resolve-btn">RESOLVE</a>
            <% } %>
          </td>
        </tr>
        <% } } %>
      </tbody>
    </table>
  </div>
</div>

<script>
// Apply bar widths from data attribute (avoids JSP expressions inside CSS)
document.querySelectorAll('.bar-fill[data-width]').forEach(el => {
  el.style.width = el.dataset.width + '%';
});
document.querySelectorAll('.filter-btn').forEach(btn => {
  btn.addEventListener('click', function() {
    document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
    this.classList.add('active');
  });
});
</script>
</body>
</html>
