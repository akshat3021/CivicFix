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

@WebServlet("/admin")
public class AdminController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        List<Complaint> realList = ComplaintDAO.getAllComplaints();
        
        request.setAttribute("complaintList", realList);
        request.setAttribute("adminName", "Akshat Aswal");
        
        request.getRequestDispatcher("/admin-dashboard.jsp").forward(request, response);
    }
}