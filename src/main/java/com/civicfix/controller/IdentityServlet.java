package com.civicfix.controller;

import com.civicfix.dao.UserDAO;
import com.civicfix.model.User;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/auth")
public class IdentityServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getParameter("action");

        if ("register".equals(action)) {
            User newUser = new User();
            newUser.setUsername(request.getParameter("username"));
            newUser.setEmail(request.getParameter("email"));
            newUser.setPassword(request.getParameter("password"));

            boolean success = UserDAO.registerUser(newUser);
            if (success) {
                // Redirect to login page with a success parameter
                response.sendRedirect("login.jsp?msg=registered"); 
            } else {
                // Redirect back to login page with an error parameter
                response.sendRedirect("login.jsp?error=failed");
            }

        } else if ("login".equals(action)) {
            String user = request.getParameter("username");
            String pass = request.getParameter("password");

            User loggedInUser = UserDAO.validateLogin(user, pass);
            
            if (loggedInUser != null) {
                HttpSession session = request.getSession();
                session.setAttribute("currentUser", loggedInUser);
                // Redirect to Akshat's Admin Dashboard or a User Dashboard
                response.sendRedirect("admin"); 
            } else {
                response.sendRedirect("login.jsp?error=invalid");
            }
        }
    }
}