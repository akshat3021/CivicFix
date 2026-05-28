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

    // --- NEW HELPER METHOD FOR TOMCAT 7 COMPATIBILITY ---
    private String extractFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        String[] items = contentDisp.split(";");
        for (String s : items) {
            if (s.trim().startsWith("filename")) {
                String clientFileName = s.substring(s.indexOf("=") + 2, s.length() - 1);
                // Handle different browser path formats just in case
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
        String severityParam = request.getParameter("severity_score");
        int severityScore = 50; // default
        if (severityParam != null && !severityParam.isEmpty()) {
            try {
                severityScore = Integer.parseInt(severityParam);
            } catch (NumberFormatException e) {
                // ignore
            }
        }

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

        // 5. Process and Save the Physical Image
        String finalImagePath = null;
        if (imagePart != null && imagePart.getSize() > 0) {
            
            // USE OUR NEW TOMCAT 7 HELPER METHOD HERE:
            String fileName = extractFileName(imagePart);
            
            if (fileName != null && !fileName.isEmpty()) {
                // Create an 'uploads' folder dynamically inside the Tomcat server
                String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads";
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) uploadDir.mkdir();
                
                // Save the file to the folder
                imagePart.write(uploadPath + File.separator + fileName);
                
                // This is what gets saved to MySQL (e.g., "uploads/pothole.png")
                finalImagePath = "uploads/" + fileName; 
            }
        }

        // 6. Save to Database
        Complaint newComplaint = new Complaint();
        newComplaint.setTitle(title);
        newComplaint.setCategory(category);
        newComplaint.setDescription(description);
        newComplaint.setImagePath(finalImagePath);
        newComplaint.setUserId(currentUser.getId()); // Set reporting user's ID
        newComplaint.setSeverityScore(severityScore); // Save severity score submitted by citizen
        
        boolean isSaved = ComplaintDAO.insertComplaint(newComplaint);

        if (isSaved) {
            // 7. Give the user their reward points!
            UserDAO.addRewardPoints(currentUser.getUsername(), 10);
            currentUser.setRewardPoints(currentUser.getRewardPoints() + 10);
            
            response.sendRedirect("user-dashboard.jsp?msg=Complaint submitted successfully!");
        } else {
            response.sendRedirect("user-dashboard.jsp?error=Database Error: Could not save complaint.");
        }
    }
}