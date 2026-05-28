package com.civicfix.controller;

import com.civicfix.dao.DBConnection;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/VoteServlet")
public class VoteServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String idParam = request.getParameter("complaintId");
        
        if (idParam != null) {
            int complaintId = Integer.parseInt(idParam);
            
            // Increase the severity_score by 10 for every vote!
            try (Connection conn = DBConnection.getConnection()) {
                String sql = "UPDATE complaints SET severity_score = severity_score + 10 WHERE id = ?";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setInt(1, complaintId);
                ps.executeUpdate();
                
                System.out.println("🗳️ Upvoted Complaint ID: " + complaintId);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        
        // Send them right back to the dashboard to see the updated score
        response.sendRedirect("user-dashboard.jsp");
    }
}