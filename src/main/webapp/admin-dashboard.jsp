<!DOCTYPE html>
<html>
<head>
    <title>CivicFix - Admin Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">

<div class="container mt-5">
    <div class="card shadow">
        <div class="card-header bg-primary text-white">
            <h3>👮‍♂️ Authority Dashboard</h3>
        </div>
        <div class="card-body">
            <h5>Welcome, <%= request.getAttribute("adminName") %>!</h5>
            <p class="lead">You have <strong class="text-danger"><%= request.getAttribute("pendingIssues") %></strong> critical issues to review today.</p>
            
            <hr>
            <button class="btn btn-warning">View Heatmap</button>
            <button class="btn btn-success">Resolve Tickets</button>
        </div>
    </div>
</div>

</body>
</html>