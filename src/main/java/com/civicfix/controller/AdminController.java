package com.civicfix.controller;

import com.civicfix.dao.ComplaintDAO;
import com.civicfix.model.Complaint;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession; // Added this import

@WebServlet("/admin")
public class AdminController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {

        // 1. SECURITY CHECK & GET DYNAMIC NAME
        HttpSession session = request.getSession(false);
        String currentAdminName = "Admin"; // Fallback name
        
        // Check if the user is actually logged in and is an Admin
        if (session != null && session.getAttribute("adminName") != null) {
            currentAdminName = (String) session.getAttribute("adminName");
        } else {
            // Kick them back to the login page if they try to bypass the Gatekeeper!
            response.sendRedirect("login.jsp?error=Access Denied! Please login as Admin.");
            return;
        }

        // 2. AKSHAT'S RESOLVE LOGIC
        String action = request.getParameter("action");
        String idParam = request.getParameter("id");

        if ("resolve".equals(action) && idParam != null) {
            int idToResolve = Integer.parseInt(idParam);
            
            System.out.println(">>> CLICKED RESOLVE ON ID: " + idToResolve); // DEBUG PRINT
            
            ComplaintDAO.updateStatus(idToResolve, "CLOSED");
            
            response.sendRedirect("admin");
            return;
        }

        // 3. LOAD DATA AND SEND TO JSP
        List<Complaint> realList = ComplaintDAO.getAllComplaints();
        request.setAttribute("complaintList", realList);
        
        // FIX: Now we pass the REAL logged-in admin's name!
        request.setAttribute("adminName", currentAdminName); 
        
        request.getRequestDispatcher("/admin-dashboard.jsp").forward(request, response);
    }
}