<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>CivicFix — Authenticate</title>
<link href="https://fonts.googleapis.com/css2?family=Share+Tech+Mono&family=Barlow+Condensed:wght@300;400;600;700&family=Barlow:wght@300;400;500&display=swap" rel="stylesheet">
<style>
*{margin:0;padding:0;box-sizing:border-box;}
:root{
  --bg:#080c10;--surface:#0d1117;--border:#1e2d3d;
  --accent:#00d4ff;--accent2:#00ff88;--danger:#ff3b5c;
  --text:#c9d1d9;--text-dim:#586069;
  --mono:'Share Tech Mono',monospace;
  --head:'Barlow Condensed',sans-serif;
  --body:'Barlow',sans-serif;
}
body{background:var(--bg);color:var(--text);font-family:var(--body);min-height:100vh;display:flex;align-items:center;justify-content:center;}
body::before{content:'';position:fixed;inset:0;background:repeating-linear-gradient(0deg,transparent,transparent 2px,rgba(0,212,255,0.012) 2px,rgba(0,212,255,0.012) 4px);pointer-events:none;z-index:0;}
.watermark{position:fixed;font-family:var(--head);font-size:160px;font-weight:700;color:rgba(0,212,255,0.025);letter-spacing:16px;pointer-events:none;user-select:none;top:50%;left:50%;transform:translate(-50%,-50%);white-space:nowrap;z-index:0;}
.wrap{position:relative;z-index:1;width:100%;max-width:420px;padding:20px;}
.brand{text-align:center;margin-bottom:36px;}
.brand-name{font-family:var(--head);font-size:52px;font-weight:700;color:#fff;letter-spacing:10px;line-height:1;}
.brand-sub{font-family:var(--mono);font-size:10px;color:var(--text-dim);letter-spacing:3px;margin-top:8px;}

/* alert banners */
.alert{font-family:var(--mono);font-size:11px;padding:10px 14px;margin-bottom:18px;border-left:3px solid;letter-spacing:.5px;}
.alert-error{background:rgba(255,59,92,.08);border-color:var(--danger);color:var(--danger);}
.alert-success{background:rgba(0,255,136,.08);border-color:var(--accent2);color:var(--accent2);}

.box{background:var(--surface);border:1px solid var(--border);}
.tabs{display:flex;border-bottom:1px solid var(--border);}
.tab-btn{flex:1;font-family:var(--mono);font-size:11px;letter-spacing:2px;padding:13px;background:none;border:none;color:var(--text-dim);cursor:pointer;border-bottom:2px solid transparent;transition:all .15s;}
.tab-btn.active{color:var(--accent);border-bottom-color:var(--accent);}
.tab-content{padding:28px;display:none;}
.tab-content.active{display:block;}

.form-group{margin-bottom:16px;}
.form-label{display:block;font-family:var(--mono);font-size:9px;color:var(--text-dim);letter-spacing:2px;margin-bottom:7px;}
.form-input,.form-select{width:100%;background:var(--bg);border:1px solid var(--border);color:var(--text);padding:11px 14px;font-family:var(--mono);font-size:13px;outline:none;transition:border .15s;border-radius:0;-webkit-appearance:none;}
.form-input:focus,.form-select:focus{border-color:var(--accent);}
.form-select option{background:var(--bg);}
.submit-btn{width:100%;padding:13px;background:var(--accent);color:var(--bg);font-family:var(--head);font-size:17px;font-weight:700;letter-spacing:4px;border:none;cursor:pointer;margin-top:8px;transition:all .2s;}
.submit-btn:hover{background:#33ddff;box-shadow:0 0 24px rgba(0,212,255,.35);}
.submit-btn.green{background:var(--accent2);color:var(--bg);}
.submit-btn.green:hover{background:#33ffaa;box-shadow:0 0 24px rgba(0,255,136,.35);}

.passkey-group{display:none;}
.footer-text{text-align:center;font-family:var(--mono);font-size:9px;color:var(--text-dim);letter-spacing:1px;margin-top:20px;}
</style>
</head>
<body>
<div class="watermark">CIVICFIX</div>
<div class="wrap">
  <div class="brand">
    <div class="brand-name">CIVICFIX</div>
    <div class="brand-sub">// CITIZEN INFRASTRUCTURE MANAGEMENT SYSTEM</div>
  </div>

  <% if(request.getParameter("error") != null) { %>
    <div class="alert alert-error">⚠ <%= request.getParameter("error") %></div>
  <% } %>
  <% if(request.getParameter("msg") != null) { %>
    <div class="alert alert-success">✓ <%= request.getParameter("msg") %></div>
  <% } %>

  <div class="box">
    <div class="tabs">
      <button class="tab-btn active" onclick="switchTab('login',this)">LOGIN</button>
      <button class="tab-btn" onclick="switchTab('register',this)">REGISTER</button>
    </div>

    <!-- LOGIN -->
    <div id="tab-login" class="tab-content active">
      <form action="auth" method="POST">
        <input type="hidden" name="action" value="login">
        <div class="form-group">
          <label class="form-label">USERNAME</label>
          <input class="form-input" type="text" name="username" placeholder="Enter your username" required>
        </div>
        <div class="form-group">
          <label class="form-label">PASSWORD</label>
          <input class="form-input" type="password" name="password" placeholder="••••••••" required>
        </div>
        <button type="submit" class="submit-btn">AUTHENTICATE ▶</button>
      </form>
    </div>

    <!-- REGISTER -->
    <div id="tab-register" class="tab-content">
      <form action="auth" method="POST">
        <input type="hidden" name="action" value="register">
        <div class="form-group">
          <label class="form-label">USERNAME</label>
          <input class="form-input" type="text" name="username" placeholder="Choose a username" required>
        </div>
        <div class="form-group">
          <label class="form-label">EMAIL</label>
          <input class="form-input" type="email" name="email" placeholder="your@email.com" required>
        </div>
        <div class="form-group">
          <label class="form-label">PASSWORD</label>
          <input class="form-input" type="password" name="password" placeholder="Create a password" required>
        </div>
        <div class="form-group">
          <label class="form-label">ROLE</label>
          <select class="form-select" name="role" onchange="togglePasskey(this.value)">
            <option value="USER">CITIZEN</option>
            <option value="ADMIN">MUNICIPAL ADMIN</option>
          </select>
        </div>
        <div class="form-group passkey-group" id="passkey-group">
          <label class="form-label">ADMIN PASSKEY</label>
          <input class="form-input" type="password" name="admin_passkey" placeholder="Enter admin passkey">
        </div>
        <button type="submit" class="submit-btn green">CREATE ACCOUNT ▶</button>
      </form>
    </div>
  </div>

  <div class="footer-text">SECURE CONNECTION · CIVICFIX v1.0 · MUNICIPAL SYSTEM</div>
</div>

<script>
function switchTab(name, btn) {
  document.querySelectorAll('.tab-content').forEach(t => t.classList.remove('active'));
  document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
  document.getElementById('tab-' + name).classList.add('active');
  btn.classList.add('active');
}
function togglePasskey(role) {
  document.getElementById('passkey-group').style.display = role === 'ADMIN' ? 'block' : 'none';
}
</script>
</body>
</html>
