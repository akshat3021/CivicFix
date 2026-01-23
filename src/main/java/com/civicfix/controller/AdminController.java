package com.civicfix.controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/admin")
public class AdminController extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. (Later) We will fetch data from Mohit's Module 3 here
        // String topComplaint = PriorityService.getTopComplaint();
        
        // 2. For now, let's just send some dummy data to the page
        request.setAttribute("adminName", "Akshat Aswal");
        request.setAttribute("pendingIssues", 5);
        
        // 3. Send the user to the Dashboard HTML page
        request.getRequestDispatcher("/admin-dashboard.jsp").forward(request, response);
    }
}