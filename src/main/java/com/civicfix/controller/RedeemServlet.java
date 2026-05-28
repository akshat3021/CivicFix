package com.civicfix.controller;

import com.civicfix.dao.UserDAO;
import com.civicfix.model.User;
import java.io.IOException;
import java.util.UUID;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/RedeemServlet")
public class RedeemServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");
        
        if (currentUser == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("Unauthorized");
            return;
        }
        
        String itemId = request.getParameter("itemId");
        if (itemId == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("Missing itemId");
            return;
        }
        
        int pointsRequired = 0;
        String itemLabel = "";
        String codePrefix = "";
        
        if ("SOLAR_CREDIT".equals(itemId)) {
            pointsRequired = 50;
            itemLabel = "District Solar Utility Credit";
            codePrefix = "SOLAR";
        } else if ("TRANSIT_PASS".equals(itemId)) {
            pointsRequired = 100;
            itemLabel = "Smart-Transit Hyperpass";
            codePrefix = "TRANSIT";
        } else if ("EV_VOUCHER".equals(itemId)) {
            pointsRequired = 150;
            itemLabel = "District EV-Charge Voucher";
            codePrefix = "EVCHARGE";
        } else {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("Invalid itemId");
            return;
        }
        
        // Refresh points from DB to ensure validity
        User dbUser = UserDAO.validateLogin(currentUser.getUsername(), currentUser.getPassword());
        if (dbUser == null || dbUser.getRewardPoints() < pointsRequired) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("Insufficient reward points.");
            return;
        }
        
        // Deduct points
        UserDAO.addRewardPoints(dbUser.getUsername(), -pointsRequired);
        
        // Generate promo code
        String randomCode = UUID.randomUUID().toString().substring(0, 8).toUpperCase();
        String promoCode = "CF-" + codePrefix + "-" + randomCode;
        
        // Update session user points
        currentUser.setRewardPoints(dbUser.getRewardPoints() - pointsRequired);
        session.setAttribute("currentUser", currentUser);
        
        // Push notification
        UserDAO.pushNotification(dbUser.getId(), "Claimed " + itemLabel + "! Promo Code: " + promoCode + " (-" + pointsRequired + " PTS)");
        
        response.setContentType("application/json");
        response.getWriter().write("{\"status\":\"success\", \"userPoints\":" + currentUser.getRewardPoints() + ", \"promoCode\":\"" + promoCode + "\", \"itemLabel\":\"" + itemLabel + "\"}");
    }
}
