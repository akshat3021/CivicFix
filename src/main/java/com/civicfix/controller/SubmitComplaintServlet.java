package com.civicfix.controller;

import com.civicfix.dao.ComplaintDAO;
import com.civicfix.dao.UserDAO;
import com.civicfix.model.Complaint;
import com.civicfix.model.User;
import com.civicfix.validators.ComplaintValidator;
import com.civicfix.validators.ImageValidator;

import java.io.File;
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

    // --- TOMCAT 7 FIX: Extracts the file name safely ---
    private String extractFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        String[] items = contentDisp.split(";");
        for (String s : items) {
            if (s.trim().startsWith("filename")) {
                String clientFileName = s.substring(s.indexOf("=") + 2, s.length() - 1);
                clientFileName = clientFileName.replace("\\", "/");
                int i = clientFileName.lastIndexOf('/');
                return clientFileName.substring(i + 1);
            }
        }
        return null;
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String title = request.getParameter("title");
        String category = request.getParameter("category");
        String description = request.getParameter("description");
        Part imagePart = request.getPart("image");

        // Use Teammate's Validators (if they exist)
        try {
            String validationError = ComplaintValidator.validate(title, description, category);
            if (validationError != null) {
                response.sendRedirect("user-dashboard.jsp?error=" + validationError);
                return;
            }
            if (imagePart != null && imagePart.getSize() > 0) {
                boolean isImageValid = ImageValidator.isValid(imagePart.getSize(), imagePart.getContentType());
                if (!isImageValid) {
                    response.sendRedirect("user-dashboard.jsp?error=Invalid Image Format or Size");
                    return;
                }
            }
        } catch (Exception e) {
            // Failsafe in case validators are missing
        }

        // Process and Save the Physical Image
        String finalImagePath = null;
        if (imagePart != null && imagePart.getSize() > 0) {
            String fileName = extractFileName(imagePart);
            if (fileName != null && !fileName.isEmpty()) {
                String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads";
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) uploadDir.mkdir();
                
                imagePart.write(uploadPath + File.separator + fileName);
                finalImagePath = "uploads/" + fileName; 
            }
        }

        // Save to Database
        Complaint newComplaint = new Complaint();
        newComplaint.setTitle(title);
        newComplaint.setCategory(category);
        newComplaint.setDescription(description);
        
        // ** THE CRITICAL STEP: Giving the image path to the model **
        newComplaint.setImagePath(finalImagePath); 
        
        boolean isSaved = ComplaintDAO.insertComplaint(newComplaint);

        if (isSaved) {
            try {
                UserDAO.addRewardPoints(currentUser.getUsername(), 10);
                currentUser.setRewardPoints(currentUser.getRewardPoints() + 10);
            } catch (Exception e) {}
            response.sendRedirect("user-dashboard.jsp?msg=success");
        } else {
            response.sendRedirect("user-dashboard.jsp?error=Database Error: Could not save complaint.");
        }
    }
}