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

        // --- REGISTRATION LOGIC ---
        if ("register".equals(action)) {
            String email = request.getParameter("email");
            if (email == null) {
                response.sendRedirect("login.jsp?error=Email address is required!");
                return;
            }
            String verifiedEmail = (String) request.getSession().getAttribute("verified_email");
            if (verifiedEmail == null || !verifiedEmail.equalsIgnoreCase(email.trim())) {
                response.sendRedirect("login.jsp?error=Please verify your email address via OTP first!");
                return;
            }

            User newUser = new User();
            newUser.setUsername(request.getParameter("username"));
            newUser.setEmail(email.trim());
            newUser.setPassword(request.getParameter("password"));

            // Handle the Role and Admin Passkey
            String requestedRole = request.getParameter("role");
            String passkey = request.getParameter("admin_passkey");

            if ("ADMIN".equals(requestedRole)) {
                // If they want to be an Admin, verify the secret passkey!
                if (!"CIVIC-ADMIN-2026".equals(passkey)) {
                    response.sendRedirect("login.jsp?error=Invalid Admin Passkey! Registration blocked.");
                    return; // Stop execution, don't save to DB
                }
                newUser.setRole("ADMIN");
            } else {
                newUser.setRole("USER");
            }

            boolean success = UserDAO.registerUser(newUser);
            if (success) {
                response.sendRedirect("login.jsp?msg=Account created successfully! You can now login."); 
            } else {
                response.sendRedirect("login.jsp?error=Registration failed. Username or Email already taken.");
            }

        // --- LOGIN LOGIC (DUAL ROLE) ---
        } else if ("login".equals(action)) {
            String user = request.getParameter("username");
            String pass = request.getParameter("password");

            // 1. Check for the Master Admin Login
            if ("_yasharth@2006dhanai".equals(user) && "SDFGDFSGFDSF".equals(pass)) {
                HttpSession oldSession = request.getSession(false);
                if (oldSession != null) {
                    oldSession.invalidate();
                }
                HttpSession session = request.getSession(true);
                session.setAttribute("adminName", "Master Admin");
                session.setAttribute("role", "ADMIN");
                System.out.println("✅ Master Admin Access Granted");
                
                response.sendRedirect("admin"); 
                return; // Stop execution here
            }

            // 2. Check Database for all other registered Citizens and Admins
            User loggedInUser = UserDAO.validateLogin(user, pass);
            
            if (loggedInUser != null) {
                HttpSession oldSession = request.getSession(false);
                if (oldSession != null) {
                    oldSession.invalidate();
                }
                HttpSession session = request.getSession(true);
                session.setAttribute("currentUser", loggedInUser);
                session.setAttribute("role", loggedInUser.getRole());
                
                System.out.println("✅ Login Success: " + loggedInUser.getUsername() + " [" + loggedInUser.getRole() + "]");
                
                // Route them to the correct dashboard based on their role
                if ("ADMIN".equals(loggedInUser.getRole())) {
                    session.setAttribute("adminName", loggedInUser.getUsername());
                    response.sendRedirect("admin"); 
                } else {
                    response.sendRedirect("user-dashboard.jsp"); 
                }
            } else {
                // Login failed
                response.sendRedirect("login.jsp?error=Invalid Username or Password.");
            }
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getParameter("action");

        // --- LOGOUT LOGIC ---
        if ("logout".equals(action)) {
            HttpSession session = request.getSession(false);
            if (session != null) {
                session.invalidate(); // This destroys the user's session
            }
            System.out.println("🚪 Gatekeeper: User logged out.");
            response.sendRedirect("login.jsp?msg=Logged out successfully.");
        } else {
            // If someone tries to access /auth directly, send them to login
            response.sendRedirect("login.jsp");
        }
    }
}