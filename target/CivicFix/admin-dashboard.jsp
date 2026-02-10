<!DOCTYPE html>
<html>
<head>
    <title>CivicFix - Admin Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">

<div class="card-body">
            <h5>Welcome, <%= request.getAttribute("adminName") %>!</h5>
            
            <table class="table table-hover mt-4">
                <thead class="table-dark">
                    <tr>
                        <th>ID</th>
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
                        <td>#<%= c.getId() %></td>
                        <td><span class="badge bg-secondary"><%= c.getCategory() %></span></td>
                        <td><%= c.getTitle() %></td>
                        <td>
                            <% if(c.getSeverityScore() > 80) { %>
                                <span class="text-danger fw-bold"><%= c.getSeverityScore() %> (CRITICAL)</span>
                            <% } else { %>
                                <span class="text-dark"><%= c.getSeverityScore() %></span>
                            <% } %>
                        </td>
                        <td>
                             <a href="admin?action=resolve&id=<%= c.getId() %>" class="btn btn-sm btn-success">
                                ✅ Resolve
                             </a>
                            </td>
                    </tr>
                    <%      } 
                        } 
                    %>
                </tbody>
            </table>
        </div>

</body>
</html>