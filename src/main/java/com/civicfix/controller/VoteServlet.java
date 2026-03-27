package com.civicfix.controller;

import com.civicfix.dao.ComplaintDAO;
import com.civicfix.model.User;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/VoteServlet")
public class VoteServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. Get the current user trying to vote
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");
        
        if (currentUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String idParam = request.getParameter("complaintId");
        
        if (idParam != null) {
            int complaintId = Integer.parseInt(idParam);
            
            // 2. Ask the DAO to securely process the vote
            boolean voteSuccessful = ComplaintDAO.addVote(currentUser.getUsername(), complaintId);
            
            // 3. Send them back with the correct message
            if (voteSuccessful) {
                response.sendRedirect("user-dashboard.jsp?msg=Upvote recorded successfully!");
            } else {
                response.sendRedirect("user-dashboard.jsp?error=Access Denied: You have already voted on this issue.");
            }
        } else {
            response.sendRedirect("user-dashboard.jsp");
        }
    }
}