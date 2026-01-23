package com.civicfix.controller;

import com.civicfix.model.Complaint; // Import the file you just made
import java.io.IOException;
import java.util.ArrayList;
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
        
        // 1. Create Fake Data (Mocking the Database)
        List<Complaint> mockList = new ArrayList<>();
        mockList.add(new Complaint(101, "Deep Pothole on Main Road", "ROADS", 85));
        mockList.add(new Complaint(102, "Street Light Broken", "ELECTRIC", 40));
        mockList.add(new Complaint(103, "Garbage Pile in Park", "SANITATION", 65));

        // 2. Send the list to the JSP
        request.setAttribute("complaintList", mockList);
        request.setAttribute("adminName", "Akshat Aswal");

        request.getRequestDispatcher("/admin-dashboard.jsp").forward(request, response);
    }
}