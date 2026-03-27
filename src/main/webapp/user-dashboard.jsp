<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.civicfix.model.User" %>
<%@ page import="java.util.List, com.civicfix.dao.ComplaintDAO, com.civicfix.model.Complaint" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) { response.sendRedirect("login.jsp"); return; }
    String safeError = request.getParameter("error") != null
        ? request.getParameter("error").replaceAll("<[^>]*>","") : null;
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>CivicFix — Citizen Portal</title>
<link href="https://fonts.googleapis.com/css2?family=Share+Tech+Mono&family=Barlow+Condensed:wght@300;400;600;700&family=Barlow:wght@300;400;500&display=swap" rel="stylesheet">
<style>
*{margin:0;padding:0;box-sizing:border-box;}
:root{
  --bg:#080c10;--surface:#0d1117;--border:#1e2d3d;
  --accent:#00d4ff;--accent2:#00ff88;--danger:#ff3b5c;--warn:#ffb800;
  --text:#c9d1d9;--text-dim:#586069;
  --mono:'Share Tech Mono',monospace;
  --head:'Barlow Condensed',sans-serif;
  --body:'Barlow',sans-serif;
}
body{background:var(--bg);color:var(--text);font-family:var(--body);min-height:100vh;}
body::before{content:'';position:fixed;inset:0;background:repeating-linear-gradient(0deg,transparent,transparent 2px,rgba(0,212,255,0.012) 2px,rgba(0,212,255,0.012) 4px);pointer-events:none;z-index:999;}
@keyframes pulse{0%,100%{opacity:1;transform:scale(1);}50%{opacity:.5;transform:scale(.8);}}

.topbar{display:flex;align-items:center;justify-content:space-between;padding:0 28px;height:52px;background:var(--surface);border-bottom:1px solid var(--border);position:sticky;top:0;z-index:100;}
.logo{font-family:var(--head);font-size:22px;font-weight:700;letter-spacing:3px;color:#fff;display:flex;align-items:center;gap:10px;}
.logo-dot{width:8px;height:8px;background:var(--accent);border-radius:50%;box-shadow:0 0 8px var(--accent);animation:pulse 2s infinite;}
.topbar-right{display:flex;align-items:center;gap:20px;font-family:var(--mono);font-size:11px;color:var(--text-dim);}
.user-badge{padding:4px 12px;background:rgba(0,255,136,.08);border:1px solid rgba(0,255,136,.2);border-radius:2px;color:var(--accent2);}
.logout-link{color:var(--danger);text-decoration:none;letter-spacing:1px;}
.logout-link:hover{opacity:.7;}

.main{padding:28px;max-width:1100px;margin:0 auto;}
.page-title{font-family:var(--head);font-size:32px;font-weight:700;letter-spacing:2px;color:#fff;line-height:1;}
.page-sub{font-family:var(--mono);font-size:11px;color:var(--text-dim);margin-top:6px;letter-spacing:1px;margin-bottom:28px;}

.alert{font-family:var(--mono);font-size:11px;padding:12px 16px;margin-bottom:20px;border-left:3px solid;letter-spacing:.5px;}
.alert-error{background:rgba(255,59,92,.08);border-color:var(--danger);color:var(--danger);}
.alert-success{background:rgba(0,255,136,.08);border-color:var(--accent2);color:var(--accent2);}

.grid{display:grid;grid-template-columns:1fr 340px;gap:20px;align-items:start;}
.card{background:var(--surface);border:1px solid var(--border);padding:26px;}
.card-title{font-family:var(--head);font-size:14px;font-weight:600;letter-spacing:2px;color:var(--accent);margin-bottom:22px;display:flex;align-items:center;gap:8px;}
.card-title::before{content:'//';font-family:var(--mono);color:var(--text-dim);font-size:12px;}
.card-accent2 .card-title{color:var(--accent2);}
.card-accent2{border-color:rgba(0,255,136,.15);}

.form-group{margin-bottom:18px;}
.form-label{display:block;font-family:var(--mono);font-size:9px;color:var(--text-dim);letter-spacing:2px;margin-bottom:7px;}
.form-input,.form-select{width:100%;background:var(--bg);border:1px solid var(--border);color:var(--text);padding:11px 14px;font-family:var(--mono);font-size:13px;outline:none;transition:border .15s;border-radius:0;-webkit-appearance:none;}
.form-input:focus,.form-select:focus{border-color:var(--accent);}
textarea.form-input{resize:vertical;min-height:90px;}
.form-select option{background:var(--bg);}
.submit-btn{width:100%;padding:13px;background:var(--accent);color:var(--bg);font-family:var(--head);font-size:17px;font-weight:700;letter-spacing:4px;border:none;cursor:pointer;margin-top:4px;transition:all .2s;}
.submit-btn:hover{background:#33ddff;box-shadow:0 0 24px rgba(0,212,255,.3);}

.points-display{text-align:center;padding:20px 0 16px;}
.points-val{font-family:var(--head);font-size:60px;font-weight:700;color:var(--accent2);line-height:1;}
.points-label{font-family:var(--mono);font-size:9px;color:var(--text-dim);letter-spacing:3px;margin-top:6px;}

.reward-row{display:flex;justify-content:space-between;align-items:center;padding:11px 0;border-bottom:1px solid rgba(30,45,61,.5);font-size:12px;}
.reward-row:last-child{border:none;}
.reward-pts{font-family:var(--mono);font-size:12px;color:var(--accent2);}
.reward-pts.dim{color:var(--text-dim);}

.info-row{display:flex;justify-content:space-between;padding:9px 0;border-bottom:1px solid rgba(30,45,61,.4);font-family:var(--mono);font-size:11px;}
.info-row:last-child{border:none;}
.info-key{color:var(--text-dim);}
.info-val{color:var(--text);}

/* NEW CUSTOM FEED & MODAL CSS */
.feed-grid { display:grid; grid-template-columns: repeat(auto-fill, minmax(320px, 1fr)); gap:20px; margin-top: 20px;}
.feed-card { background:rgba(255,255,255,0.02); border:1px solid var(--border); padding:20px; display:flex; flex-direction:column; justify-content:space-between;}
.feed-card-header { display:flex; justify-content:space-between; align-items:flex-start; margin-bottom: 12px;}
.feed-title { font-family:var(--head); font-size:20px; color:#fff; letter-spacing:1px; line-height:1.2;}
.feed-score { font-family:var(--mono); font-size:14px; color:var(--danger); font-weight:bold;}
.feed-btn-row { display:flex; gap:10px; margin-top:16px;}
.feed-btn { flex:1; padding:8px; background:none; border:1px solid; font-family:var(--mono); font-size:11px; letter-spacing:1px; cursor:pointer; text-align:center;}
.btn-preview { border-color:var(--accent); color:var(--accent); }
.btn-preview:hover { background:rgba(0,212,255,0.1); }
.btn-upvote { border-color:var(--accent2); color:var(--accent2); background:rgba(0,255,136,0.05);}
.btn-upvote:hover { background:rgba(0,255,136,0.2); }

.modal-overlay { display:none; position:fixed; inset:0; background:rgba(0,0,0,0.8); z-index:2000; justify-content:center; align-items:center; backdrop-filter:blur(4px); }
.modal-overlay.active { display:flex; }
.modal-box { background:#0d1117; border:1px solid var(--accent); width:100%; max-width:600px; padding:24px; position:relative; max-height:90vh; overflow-y:auto; box-shadow: 0 0 20px rgba(0,212,255,0.1); }
.close-btn { position:absolute; top:16px; right:20px; color:var(--danger); cursor:pointer; font-family:var(--mono); font-size:16px; background:none; border:none; }
.modal-desc { font-family:var(--mono); font-size:13px; color:var(--text); line-height:1.6; background:#111820; padding:16px; border:1px solid var(--border); margin:20px 0; }
.modal-img { max-width:100%; border:1px solid var(--border); border-radius:2px; margin-top:10px; }
</style>
</head>
<body>
<div class="topbar">
  <div class="logo"><span class="logo-dot"></span>CIVICFIX <span style="font-weight:300;color:var(--text-dim);font-size:14px;letter-spacing:1px;">// CITIZEN PORTAL</span></div>
  <div class="topbar-right">
    <span class="user-badge">CITIZEN: <%= currentUser.getUsername() %></span>
    <a href="auth?action=logout" class="logout-link">[ LOGOUT ]</a>
  </div>
</div>

<div class="main">
  <div class="page-title">REPORT AN INCIDENT</div>
  <div class="page-sub">// SUBMIT CIVIC ISSUES DIRECTLY TO MUNICIPAL AUTHORITIES</div>

  <% if (safeError != null) { %>
    <div class="alert alert-error">⚠ <%= safeError %></div>
  <% } %>
  <% if ("success".equals(request.getParameter("msg"))) { %>
    <div class="alert alert-success">✓ COMPLAINT SUBMITTED SUCCESSFULLY — YOU EARNED +10 REWARD POINTS!</div>
  <% } %>

  <div class="grid">
    <div class="card">
      <div class="card-title">NEW COMPLAINT</div>
      <form action="SubmitComplaintServlet" method="POST" enctype="multipart/form-data">
        <div class="form-group">
          <label class="form-label">ISSUE TITLE</label>
          <input class="form-input" type="text" name="title" placeholder="E.g., Deep pothole on Main Street" required>
        </div>
        <div class="form-group">
          <label class="form-label">CATEGORY</label>
          <select class="form-select" name="category">
            <option value="ROADS">ROADS</option>
            <option value="WATER">WATER</option>
            <option value="ELECTRIC">ELECTRIC</option>
            <option value="SANITATION">SANITATION</option>
            <option value="PUBLIC_SAFETY">PUBLIC SAFETY</option>
            <option value="OTHER">OTHER</option>
          </select>
        </div>
        <div class="form-group">
          <label class="form-label">DESCRIPTION (MIN 20 CHARS)</label>
          <textarea class="form-input" name="description" placeholder="Describe the issue in detail..." required></textarea>
        </div>
        <div class="form-group">
          <label class="form-label">EVIDENCE PHOTO (MAX 2MB — JPG/PNG)</label>
          <input class="form-input" type="file" name="image" accept="image/png,image/jpeg" style="padding:8px 14px;color:var(--text-dim);">
        </div>
        <button type="submit" class="submit-btn">TRANSMIT TO CITY ▶</button>
      </form>
    </div>

    <div style="display:flex;flex-direction:column;gap:16px;">
      <div class="card card-accent2">
        <div class="card-title">CIVIC SCORE</div>
        <div class="points-display">
          <div class="points-val"><%= currentUser.getRewardPoints() %></div>
          <div class="points-label">REWARD POINTS</div>
        </div>
      </div>
      <div class="card">
        <div class="card-title">EARN POINTS</div>
        <div class="reward-row"><span>Report a valid issue</span><span class="reward-pts">+10 PTS</span></div>
        <div class="reward-row"><span>Issue resolved by admin</span><span class="reward-pts dim">+50 PTS (soon)</span></div>
        <div class="reward-row"><span>Report verified critical</span><span class="reward-pts dim">+25 PTS (soon)</span></div>
      </div>
      <div class="card">
        <div class="card-title">ACCOUNT INFO</div>
        <div class="info-row"><span class="info-key">USERNAME</span><span class="info-val"><%= currentUser.getUsername() %></span></div>
        <div class="info-row"><span class="info-key">EMAIL</span><span class="info-val"><%= currentUser.getEmail() %></span></div>
        <div class="info-row"><span class="info-key">ROLE</span><span class="info-val" style="color:var(--accent2);">CITIZEN</span></div>
      </div>
    </div>
  </div>

  <div class="page-title" style="margin-top: 50px;">COMMUNITY FEED</div>
  <div class="page-sub">// VOTE TO PRIORITIZE ACTIVE ISSUES IN YOUR AREA</div>

  <div class="feed-grid">
    <%
        List<Complaint> activeComplaints = ComplaintDAO.getAllComplaints();
        if(activeComplaints != null && !activeComplaints.isEmpty()) {
            for(Complaint c : activeComplaints) {
                if("OPEN".equals(c.getStatus())) {
    %>
        <div class="feed-card">
            <div>
                <div class="feed-card-header">
                    <div class="feed-title"><%= c.getTitle() %></div>
                    <div class="feed-score">🔥 <%= c.getSeverityScore() %></div>
                </div>
                <div style="font-family:var(--mono); font-size:10px; color:var(--text-dim);">CATEGORY: <%= c.getCategory() %></div>
            </div>
            
            <div class="feed-btn-row">
                <button type="button" class="feed-btn btn-preview" onclick="openModal('user_modal_<%= c.getId() %>')">[ PREVIEW ]</button>
                
                <form action="VoteServlet" method="POST" style="flex:1;">
                    <input type="hidden" name="complaintId" value="<%= c.getId() %>">
                    <button type="submit" class="feed-btn btn-upvote" style="width:100%;">[ + UPVOTE ]</button>
                </form>
            </div>
        </div>

        <div id="user_modal_<%= c.getId() %>" class="modal-overlay">
          <div class="modal-box">
            <button class="close-btn" onclick="closeModal('user_modal_<%= c.getId() %>')">[ X ]</button>
            <div style="font-family:var(--head); font-size:24px; color:#fff; margin-bottom:10px;"><%= c.getTitle() %></div>
            <div style="font-family:var(--mono); font-size:12px; color:var(--accent);"><%= c.getCategory() %></div>
            
            <div class="modal-desc"><%= c.getDescription() %></div>
            
            <div style="font-family:var(--mono); font-size:10px; color:var(--text-dim); margin-bottom:6px;">// ATTACHED EVIDENCE</div>
            <% if (c.getImagePath() != null && !c.getImagePath().isEmpty()) { %>
                <img src="<%= c.getImagePath() %>" class="modal-img">
            <% } else { %>
                <div style="font-family:var(--mono); font-size:12px; color:var(--danger);">[ NO VISUAL EVIDENCE PROVIDED ]</div>
            <% } %>
          </div>
        </div>
    <% 
                }
            }
        }
    %>
  </div>

</div>

<script>
// CUSTOM JS FOR MODALS
function openModal(id) {
    document.getElementById(id).classList.add('active');
}
function closeModal(id) {
    document.getElementById(id).classList.remove('active');
}
</script>
</body>
</html>