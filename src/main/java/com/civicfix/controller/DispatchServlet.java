package com.civicfix.controller;

import com.civicfix.dao.ComplaintDAO;
import com.civicfix.dao.UserDAO;
import com.civicfix.model.Complaint;
import com.civicfix.model.User;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/DispatchServlet")
public class DispatchServlet extends HttpServlet {

    private final ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(3);

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");
        
        if (currentUser == null || !"ADMIN".equalsIgnoreCase(currentUser.getRole())) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("Unauthorized: Admin access required.");
            return;
        }
        
        String idParam = request.getParameter("complaintId");
        String assetType = request.getParameter("assetType");
        
        if (idParam == null || assetType == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("Missing parameters.");
            return;
        }
        
        final int complaintId = Integer.parseInt(idParam);
        final String asset = assetType;
        
        Complaint c = ComplaintDAO.getComplaintById(complaintId);
        if (c == null) {
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            response.getWriter().write("Incident not found.");
            return;
        }
        
        // Initialize the dispatch timeline
        SimpleDateFormat df = new SimpleDateFormat("HH:mm:ss");
        String timestamp = df.format(new Date());
        
        String assetLabel = getAssetLabel(asset);
        
        // Initial log
        String initialLog = "[{\"time\":\"" + timestamp + "\", \"log\":\"" + assetLabel + " deployed to Sector grid.\"}]";
        ComplaintDAO.updateDispatch(complaintId, "DISPATCHED", initialLog);
        ComplaintDAO.updateStatus(complaintId, "IN_PROGRESS");
        
        // Schedule status progression in background
        scheduleNextPhase(complaintId, assetLabel, 1, 4000);
        
        response.setContentType("application/json");
        response.getWriter().write("{\"status\":\"success\", \"dispatchStatus\":\"DISPATCHED\", \"log\":" + initialLog + "}");
    }
    
    private void scheduleNextPhase(final int id, final String assetLabel, final int phase, long delayMs) {
        scheduler.schedule(new Runnable() {
            @Override
            public void run() {
                try {
                    Complaint c = ComplaintDAO.getComplaintById(id);
                    if (c == null) return;
                    
                    SimpleDateFormat df = new SimpleDateFormat("HH:mm:ss");
                    String timestamp = df.format(new Date());
                    
                    String oldLog = c.getDispatchLog();
                    if (oldLog == null || oldLog.isEmpty()) {
                        oldLog = "[]";
                    }
                    
                    String newEntry = "";
                    String nextStatus = "";
                    
                    if (phase == 1) {
                        newEntry = "{\"time\":\"" + timestamp + "\", \"log\":\"" + assetLabel + " arrived on scene. Scanning telemetry markers.\"}" ;
                        nextStatus = "ON_SCENE";
                        // Update
                        String updatedLog = oldLog.substring(0, oldLog.length() - 1) + "," + newEntry + "]";
                        ComplaintDAO.updateDispatch(id, nextStatus, updatedLog);
                        
                        // Schedule phase 2
                        scheduleNextPhase(id, assetLabel, 2, 4000);
                    } else if (phase == 2) {
                        newEntry = "{\"time\":\"" + timestamp + "\", \"log\":\"Municipal repairs underway. Calibrating infrastructure grid.\"}" ;
                        nextStatus = "RESOLVING";
                        // Update
                        String updatedLog = oldLog.substring(0, oldLog.length() - 1) + "," + newEntry + "]";
                        ComplaintDAO.updateDispatch(id, nextStatus, updatedLog);
                        
                        // Schedule phase 3
                        scheduleNextPhase(id, assetLabel, 3, 4000);
                    } else if (phase == 3) {
                        newEntry = "{\"time\":\"" + timestamp + "\", \"log\":\"Repairs completed successfully. Asset returning to base.\"}" ;
                        nextStatus = "RESOLVED";
                        // Update
                        String updatedLog = oldLog.substring(0, oldLog.length() - 1) + "," + newEntry + "]";
                        ComplaintDAO.updateDispatch(id, nextStatus, updatedLog);
                        ComplaintDAO.updateStatus(id, "CLOSED");
                        
                        // Award points to user
                        int reporterId = c.getUserId();
                        if (reporterId > 0) {
                            UserDAO.addRewardPointsById(reporterId, 50);
                            UserDAO.pushNotification(reporterId, "🏆 Incident #" + id + " has been resolved by dispatcher. +50 PTS awarded.");
                        }
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }, delayMs, TimeUnit.MILLISECONDS);
    }
    
    private String getAssetLabel(String asset) {
        if ("DRONE_RECON".equals(asset)) return "Autonomous Recon Drone #4";
        if ("REPAIR_CREW".equals(asset)) return "Rapid Response Repair Crew";
        if ("HEAVY_HAZARD".equals(asset)) return "Emergency Heavy Hazard Vehicle";
        return "Municipal Asset";
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String idParam = request.getParameter("complaintId");
        if (idParam == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        int complaintId = Integer.parseInt(idParam);
        Complaint c = ComplaintDAO.getComplaintById(complaintId);
        if (c == null) {
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        
        response.setContentType("application/json");
        response.getWriter().write("{\"status\":\"success\", \"dispatchStatus\":\"" + (c.getDispatchStatus() != null ? c.getDispatchStatus() : "IDLE") + "\", \"log\":" + (c.getDispatchLog() != null ? c.getDispatchLog() : "[]") + "}");
    }

    @Override
    public void destroy() {
        scheduler.shutdown();
        super.destroy();
    }
}
