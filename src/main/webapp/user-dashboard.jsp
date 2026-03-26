<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.civicfix.model.User" %>
<%
    // Security layer: Kick them back to login if they aren't signed in
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>CivicFix - Citizen Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">

<div class="container mt-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2>Welcome, <%= currentUser.getUsername() %>! 🏙️</h2>
        <span class="badge bg-warning text-dark fs-6">Reward Points: <%= currentUser.getRewardPoints() %> 🏆</span>
    </div>

    <% if(request.getParameter("error") != null) { %>
        <div class="alert alert-danger"><%= request.getParameter("error") %></div>
    <% } %>
    <% if(request.getParameter("msg") != null) { %>
        <div class="alert alert-success">Complaint submitted successfully! You earned +10 Reward Points!</div>
    <% } %>

    <div class="row">
        <div class="col-md-6">
            <div class="card shadow-sm">
                <div class="card-header bg-primary text-white">Report an Issue</div>
                <div class="card-body">
                    <form action="SubmitComplaintServlet" method="POST" enctype="multipart/form-data">
                        <div class="mb-3">
                            <label>Title</label>
                            <input type="text" name="title" class="form-control" placeholder="E.g., Deep Pothole on Main St" required>
                        </div>
                        <div class="mb-3">
                            <label>Category</label>
                            <select name="category" class="form-select">
                                <option value="ROADS">Roads</option>
                                <option value="ELECTRIC">Electric</option>
                                <option value="SANITATION">Sanitation</option>
                                <option value="WATER">Water</option>
                                <option value="PUBLIC_SAFETY">Public Safety</option>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label>Description (Min 20 chars)</label>
                            <textarea name="description" class="form-control" rows="3" required></textarea>
                        </div>
                        <div class="mb-3">
                            <label>Evidence (Photo - Max 2MB)</label>
                            <input type="file" name="image" class="form-control" accept="image/png, image/jpeg" required>
                        </div>
                        <button type="submit" class="btn btn-primary w-100">Submit to City</button>
                    </form>
                </div>
            </div>
        </div>

        <div class="col-md-6">
            <div class="card shadow-sm">
                <div class="card-header bg-success text-white">Your Civic Impact</div>
                <div class="card-body">
                    <p>Every time you report a valid issue to the city, the Gatekeeper system awards you points.</p>
                    <ul>
                        <li><strong>Report an Issue:</strong> +10 Points</li>
                        <li><strong>Issue Resolved by Admin:</strong> +50 Points (Coming soon)</li>
                    </ul>
                    <a href="auth?action=logout" class="btn btn-outline-danger mt-3">Logout</a>
                </div>
            </div>
        </div>
    </div>
</div>

</body>
</html>