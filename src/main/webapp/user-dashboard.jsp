<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.civicfix.model.User" %>
<%@ page import="java.util.List" %>
<%@ page import="com.civicfix.dao.ComplaintDAO" %>
<%@ page import="com.civicfix.model.Complaint" %>
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
        <div>
            <span class="badge bg-warning text-dark fs-6 me-3">Reward Points: <%= currentUser.getRewardPoints() %> 🏆</span>
            <a href="auth?action=logout" class="btn btn-outline-danger btn-sm">🚪 Logout</a>
        </div>
    </div>

    <% if(request.getParameter("error") != null) { %>
        <div class="alert alert-danger"><%= request.getParameter("error") %></div>
    <% } %>
    <% if(request.getParameter("msg") != null) { %>
        <div class="alert alert-success"><%= request.getParameter("msg") %></div>
    <% } %>

    <div class="row">
        <div class="col-md-6 mb-4">
            <div class="card shadow-sm">
                <div class="card-header bg-primary text-white">Report an Issue</div>
                <div class="card-body">
                    <form action="SubmitComplaintServlet" method="POST" enctype="multipart/form-data">
                        <div class="mb-3">
                            <label>Title</label>
                            <input type="text" name="title" class="form-control" placeholder="E.g., Deep Pothole on Main St" maxlength="100" required>
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
                            <textarea name="description" class="form-control" rows="3" minlength="20" required></textarea>
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

        <div class="col-md-6 mb-4">
            <div class="card shadow-sm">
                <div class="card-header bg-success text-white">Active Community Issues (Vote to Prioritize!)</div>
                <div class="card-body" style="max-height: 500px; overflow-y: auto;">
                    
                    <%
                        List<Complaint> activeComplaints = ComplaintDAO.getAllComplaints();
                        boolean hasOpenIssues = false;

                        if(activeComplaints != null && !activeComplaints.isEmpty()) {
                            for(Complaint c : activeComplaints) {
                                if("OPEN".equals(c.getStatus())) {
                                    hasOpenIssues = true;
                    %>
                        <div class="border p-3 mb-3 rounded bg-white shadow-sm">
                            <h5 class="text-primary"><%= c.getTitle() %></h5>
                            <span class="badge bg-secondary mb-2"><%= c.getCategory() %></span>
                            
                            <p class="text-muted small">
                                <%= c.getDescription().length() > 60 ? c.getDescription().substring(0, 60) + "..." : c.getDescription() %>
                            </p>
                            
                            <button type="button" class="btn btn-sm btn-info text-white w-100 mb-3" data-bs-toggle="modal" data-bs-target="#userModal<%= c.getId() %>">
                                👁️ Read Full Complaint & View Evidence
                            </button>
                            
                            <div class="d-flex justify-content-between align-items-center mt-2">
                                <span class="text-danger fw-bold">🔥 Priority Score: <%= c.getSeverityScore() %></span>
                                
                                <form action="VoteServlet" method="POST" class="m-0">
                                    <input type="hidden" name="complaintId" value="<%= c.getId() %>">
                                    <button type="submit" class="btn btn-sm btn-outline-success">👍 Upvote</button>
                                </form>
                            </div>
                        </div>

                        <div class="modal fade" id="userModal<%= c.getId() %>" tabindex="-1">
                          <div class="modal-dialog">
                            <div class="modal-content">
                              <div class="modal-header bg-primary text-white">
                                <h5 class="modal-title"><%= c.getTitle() %></h5>
                                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                              </div>
                              <div class="modal-body">
                                <p><strong>Category:</strong> <%= c.getCategory() %></p>
                                <p><strong>Full Description:</strong></p>
                                <div class="p-3 bg-light border rounded mb-3"><%= c.getDescription() %></div>
                                
                                <hr>
                                <p><strong>Attached Evidence:</strong></p>
                                <% if (c.getImagePath() != null && !c.getImagePath().isEmpty()) { %>
                                    <div class="text-center">
                                        <img src="<%= c.getImagePath() %>" class="img-fluid border rounded" alt="Evidence Photo">
                                    </div>
                                <% } else { %>
                                    <p class="text-muted small"><em>No evidence attached.</em></p>
                                <% } %>
                              </div>
                            </div>
                          </div>
                        </div>
                        <% 
                                }
                            }
                        }
                        
                        if(!hasOpenIssues) { 
                    %>
                        <div class="alert alert-light text-center border">
                            No active issues in your city right now! 🏙️
                        </div>
                    <% } %>

                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>