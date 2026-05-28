package com.civicfix.controller;

import com.civicfix.dao.ComplaintDAO;
import com.civicfix.dao.UserDAO;
import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/update-complaint")
public class UpdateComplaintServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        HttpSession session = request.getSession(false);
        if (session == null || !"ADMIN".equals(session.getAttribute("role"))) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            out.write("{\"ok\":false,\"msg\":\"Forbidden: Admin access required.\"}");
            return;
        }

        String idParam = request.getParameter("id");
        String severityParam = request.getParameter("severity");
        String status = request.getParameter("status");

        if (idParam == null || severityParam == null || status == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.write("{\"ok\":false,\"msg\":\"Bad Request: Missing parameters.\"}");
            return;
        }

        try {
            int id = Integer.parseInt(idParam);
            int severity = Integer.parseInt(severityParam);
            
            // Validate status value
            if (!"OPEN".equals(status) && !"IN_PROGRESS".equals(status) && !"CLOSED".equals(status)) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.write("{\"ok\":false,\"msg\":\"Invalid status value.\"}");
                return;
            }

            // Update DB
            ComplaintDAO.updateSeverityAndStatus(id, severity, status);
            
            // Push Notification to Citizen
            int ownerId = ComplaintDAO.getComplaintOwnerId(id);
            if (ownerId > 0) {
                String notificationMsg = "Your complaint #" + id + " has been updated. Status: " 
                        + status.replace("_", " ") + ", Severity Score: " + severity + ".";
                UserDAO.pushNotification(ownerId, notificationMsg);
            }

            out.write("{\"ok\":true,\"msg\":\"Complaint updated successfully.\"}");
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.write("{\"ok\":false,\"msg\":\"Invalid parameter format.\"}");
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.write("{\"ok\":false,\"msg\":\"Database error.\"}");
            e.printStackTrace();
        }
    }
}
