<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>CivicFix - Admin Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { background-color: #f8f9fa; }
        .dashboard-container { max-width: 1200px; margin: 30px auto; background: white; padding: 20px; border-radius: 10px; box-shadow: 0 4px 8px rgba(0,0,0,0.1); }
        .status-open { color: #dc3545; font-weight: bold; }
        .status-closed { color: #198754; font-weight: bold; }
    </style>
</head>
<body>

    <div class="container dashboard-container">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2>🏙️ CivicFix Admin Panel</h2>
            <h5 class="text-secondary">User: <%= request.getAttribute("adminName") %></h5>
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
                <%@ page import="java.util.List, com.civicfix.model.Complaint" %>
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

                    <td>
                        <% if(c.getSeverityScore() > 80) { %>
                            <span class="text-danger fw-bold">🔥 <%= c.getSeverityScore() %> (CRITICAL)</span>
                        <% } else { %>
                            <span class="text-dark"><%= c.getSeverityScore() %></span>
                        <% } %>
                    </td>

                    <td>
                        <% if (!"CLOSED".equals(c.getStatus())) { %>
                            <a href="admin?action=resolve&id=<%= c.getId() %>" class="btn btn-sm btn-outline-success">
                                ✅ Mark Resolved
                            </a>
                        <% } else { %>
                            <button class="btn btn-sm btn-light text-muted" disabled>
                                ✔️ Done
                            </button>
                        <% } %>
                    </td>
                </tr>
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

</body>
</html>