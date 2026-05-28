package com.civicfix.controller;

import com.civicfix.dao.ComplaintDAO;
import com.civicfix.dao.UserDAO;
import com.civicfix.model.Complaint;
import com.civicfix.model.User;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/BountyServlet")
public class BountyServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");
        
        if (currentUser == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("Unauthorized");
            return;
        }
        
        String idParam = request.getParameter("complaintId");
        if (idParam == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("Missing complaintId");
            return;
        }
        
        int complaintId = Integer.parseInt(idParam);
        
        // Refresh user points from DB to ensure validity
        User dbUser = UserDAO.validateLogin(currentUser.getUsername(), currentUser.getPassword());
        if (dbUser == null || dbUser.getRewardPoints() < 10) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("Insufficient points (10 PTS required)");
            return;
        }
        
        Complaint c = ComplaintDAO.getComplaintById(complaintId);
        if (c == null) {
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            response.getWriter().write("Incident not found");
            return;
        }
        
        // Deduct 10 points from citizen
        UserDAO.addRewardPoints(dbUser.getUsername(), -10);
        
        // Add 10 points to complaint bounty pool
        int oldBounty = c.getBountyPool();
        int newBounty = oldBounty + 10;
        ComplaintDAO.addBounty(complaintId, 10);
        
        // If bounty pool reaches or exceeds 50, and it hasn't received the severity bonus yet
        if (newBounty >= 50 && oldBounty < 50) {
            int newSeverity = Math.min(c.getSeverityScore() + 25, 100);
            ComplaintDAO.updateSeverityAndStatus(complaintId, newSeverity, c.getStatus());
            UserDAO.pushNotification(c.getUserId(), "🔥 Incident #" + complaintId + " has escalated to a COMMUNITY BOUNTY! Severity increased by 25.");
        }
        
        // Update session user points
        currentUser.setRewardPoints(dbUser.getRewardPoints() - 10);
        session.setAttribute("currentUser", currentUser);
        
        UserDAO.pushNotification(dbUser.getId(), "Backed Incident #" + complaintId + " with 10 PTS. Total Bounty: " + newBounty + " PTS.");
        
        response.setContentType("application/json");
        response.getWriter().write("{\"status\":\"success\", \"newBounty\":" + newBounty + ", \"userPoints\":" + currentUser.getRewardPoints() + "}");
    }
}
