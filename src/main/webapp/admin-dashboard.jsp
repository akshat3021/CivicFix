<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.civicfix.model.Complaint" %>
<!DOCTYPE html>
<html>
<head>
    <title>CivicFix - Admin Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { background-color: #f8f9fa; }
        .dashboard-container { max-width: 1200px; margin: 30px auto; background: white; padding: 20px; border-radius: 10px; box-shadow: 0 4px 8px rgba(0,0,0,0.1); }
    </style>
</head>
<body>

    <div class="container dashboard-container">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2>🏙️ CivicFix Admin Panel</h2>
            <div class="text-end">
                <h5 class="text-secondary mb-2">User: <%= request.getAttribute("adminName") %></h5>
                <a href="auth?action=logout" class="btn btn-sm btn-outline-danger">🚪 Logout</a>
            </div>
        </div>

        <hr>

        <table class="table table-hover align-middle">
            <thead class="table-dark">
                <tr>
                    <th>ID</th>
                    <th>Status</th>
                    <th>Category</th>
                    <th>Issue Title</th>
                    <th>Priority Score</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody>
                <% 
                    List<Complaint> list = (List<Complaint>) request.getAttribute("complaintList");
                    if(list != null) {
                        for(Complaint c : list) {
                %>
                <tr>
                    <td><strong>#<%= c.getId() %></strong></td>
                    <td>
                        <% if ("CLOSED".equals(c.getStatus())) { %>
                            <span class="badge bg-success">CLOSED</span>
                        <% } else { %>
                            <span class="badge bg-danger">OPEN</span>
                        <% } %>
                    </td>
                    <td><span class="badge bg-secondary"><%= c.getCategory() %></span></td>
                    <td><%= c.getTitle() %></td>
                    <td><span class="text-danger fw-bold">🔥 <%= c.getSeverityScore() %></span></td>
                    <td>
                        <button type="button" class="btn btn-sm btn-info text-white" data-bs-toggle="modal" data-bs-target="#modal<%= c.getId() %>">
                            👁️ View
                        </button>
                        
                        <% if (!"CLOSED".equals(c.getStatus())) { %>
                            <a href="admin?action=resolve&id=<%= c.getId() %>" class="btn btn-sm btn-outline-success">
                                ✅ Resolve
                            </a>
                        <% } %>

                        <a href="admin?action=delete&id=<%= c.getId() %>" class="btn btn-sm btn-danger" onclick="return confirm('Are you sure you want to permanently delete this complaint? This cannot be undone.');">
                            🗑️ Delete
                        </a>
                    </td>
                </tr>

                <div class="modal fade" id="modal<%= c.getId() %>" tabindex="-1">
                  <div class="modal-dialog">
                    <div class="modal-content">
                      <div class="modal-header bg-dark text-white">
                        <h5 class="modal-title">Issue #<%= c.getId() %>: <%= c.getTitle() %></h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                      </div>
                      <div class="modal-body">
                        <p><strong>Category:</strong> <%= c.getCategory() %></p>
                        <p><strong>Description:</strong></p>
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
                <%      } 
                    } 
                %>
            </tbody>
        </table>
        
        <% if(list == null || list.isEmpty()) { %>
            <div class="alert alert-info text-center">
                No complaints found in the database. Good job! 🎉
            </div>
        <% } %>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>