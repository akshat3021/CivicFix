package com.civicfix.controller;

import com.civicfix.dao.ComplaintDAO;
import com.civicfix.dao.UserDAO;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

/**
 * Handles admin setting status to IN_PROGRESS.
 * AdminController already handles CLOSED (resolve).
 * This gives the middle "We've seen it, work has started" state.
 */
@WebServlet("/status")
public class StatusUpdateServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || !"ADMIN".equals(session.getAttribute("role"))) {
            response.sendRedirect("login.jsp"); return;
        }

        String idParam    = request.getParameter("id");
        String newStatus  = request.getParameter("s");  // IN_PROGRESS or OPEN
        String adminName  = (String) session.getAttribute("adminName");

        if (idParam == null || newStatus == null) {
            response.sendRedirect("admin"); return;
        }

        // Only allow safe status values
        if (!newStatus.equals("IN_PROGRESS") && !newStatus.equals("OPEN")) {
            response.sendRedirect("admin"); return;
        }

        int id = Integer.parseInt(idParam);
        ComplaintDAO.updateStatus(id, newStatus);

        // Notify the citizen
        int ownerId = ComplaintDAO.getComplaintOwnerId(id);
        if (ownerId > 0 && "IN_PROGRESS".equals(newStatus)) {
            UserDAO.pushNotification(ownerId,
                "Your complaint #" + id + " is now IN PROGRESS — municipal team is working on it!");
        }

        System.out.println("✅ Status of #" + id + " → " + newStatus + " by " + adminName);
        response.sendRedirect("admin");
    }
}