package com.civicfix.controller;

import com.civicfix.dao.ComplaintDAO;
import com.civicfix.dao.UserDAO;
import com.civicfix.model.Complaint;
import com.civicfix.model.User;
import com.civicfix.validators.ComplaintValidator;
import com.civicfix.validators.ImageValidator;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;

@WebServlet("/SubmitComplaintServlet")
@MultipartConfig(maxFileSize = 1024 * 1024 * 5) // Allows up to 5MB file uploads
public class SubmitComplaintServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. Check if user is logged in
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // 2. Fetch Form Data
        String title = request.getParameter("title");
        String category = request.getParameter("category");
        String description = request.getParameter("description");
        Part imagePart = request.getPart("image");

        // 3. Use Teammate's Validators
        String validationError = ComplaintValidator.validate(title, description, category);
        if (validationError != null) {
            response.sendRedirect("user-dashboard.jsp?error=" + validationError);
            return;
        }

        // 4. Validate Image
        if (imagePart != null && imagePart.getSize() > 0) {
            boolean isImageValid = ImageValidator.isValid(imagePart.getSize(), imagePart.getContentType());
            if (!isImageValid) {
                response.sendRedirect("user-dashboard.jsp?error=Invalid Image Format or Size (Max 2MB)");
                return;
            }
        }

        // 5. Save to Database
        Complaint newComplaint = new Complaint();
        newComplaint.setTitle(title);
        newComplaint.setCategory(category);
        newComplaint.setDescription(description);
        
        boolean isSaved = ComplaintDAO.insertComplaint(newComplaint);

        if (isSaved) {
            // 6. Give the user their reward points!
            UserDAO.addRewardPoints(currentUser.getUsername(), 10);
            
            // Update the session so the UI shows the new points immediately
            currentUser.setRewardPoints(currentUser.getRewardPoints() + 10);
            
            response.sendRedirect("user-dashboard.jsp?msg=success");
        } else {
            response.sendRedirect("user-dashboard.jsp?error=Database Error: Could not save complaint.");
        }
    }
}