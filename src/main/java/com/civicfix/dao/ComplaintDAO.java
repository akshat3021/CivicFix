package com.civicfix.dao;

import com.civicfix.model.Complaint;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ComplaintDAO {
    
    // 1. Get ALL Complaints
    public static List<Complaint> getAllComplaints() {
        List<Complaint> list = new ArrayList<>();
        
        try (Connection conn = DBConnection.getConnection()) {
            String sql = "SELECT * FROM complaints ORDER BY status DESC, severity_score DESC";
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Complaint c = new Complaint();
                c.setId(rs.getInt("id"));
                c.setTitle(rs.getString("title"));
                c.setDescription(rs.getString("description"));
                c.setCategory(rs.getString("category"));
                c.setSeverityScore(rs.getInt("severity_score"));
                c.setStatus(rs.getString("status"));
                c.setImagePath(rs.getString("image_path"));
                c.setUserId(rs.getInt("user_id"));
                c.setDispatchStatus(rs.getString("dispatch_status"));
                c.setDispatchLog(rs.getString("dispatch_log"));
                c.setBountyPool(rs.getInt("bounty_pool"));
                
                list.add(c);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 2. Delete a Complaint (Old Way)
    public static void deleteComplaint(int id) {
        try (Connection conn = DBConnection.getConnection()) {
            String sql = "DELETE FROM complaints WHERE id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // 3. Update Status (The Missing Tool!)
    public static void updateStatus(int id, String newStatus) {
        try (Connection conn = DBConnection.getConnection()) {
            String sql = "UPDATE complaints SET status = ? WHERE id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, newStatus);
            ps.setInt(2, id);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // 3b. Update Severity and Status together
    public static void updateSeverityAndStatus(int id, int severity, String status) {
        try (Connection conn = DBConnection.getConnection()) {
            String sql = "UPDATE complaints SET severity_score = ?, status = ? WHERE id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, severity);
            ps.setString(2, status);
            ps.setInt(3, id);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // 4. Save a new complaint from the user
    public static boolean insertComplaint(Complaint c) {
        boolean isSuccess = false;
        try (Connection conn = DBConnection.getConnection()) {
            // Added image_path and user_id to the SQL
            String sql = "INSERT INTO complaints (title, description, category, severity_score, status, image_path, user_id) VALUES (?, ?, ?, ?, 'OPEN', ?, ?)";
            PreparedStatement ps = conn.prepareStatement(sql);
            
            ps.setString(1, c.getTitle());
            ps.setString(2, c.getDescription());
            ps.setString(3, c.getCategory());
            ps.setInt(4, c.getSeverityScore() > 0 ? c.getSeverityScore() : 50); 
            ps.setString(5, c.getImagePath()); // Save the image path!
            ps.setInt(6, c.getUserId()); // Save the reporting user's ID
            
            int rows = ps.executeUpdate();
            if (rows > 0) isSuccess = true;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return isSuccess;
    }

    // 5. Get the owner ID of a complaint
    public static int getComplaintOwnerId(int complaintId) {
        try (Connection conn = DBConnection.getConnection()) {
            String sql = "SELECT user_id FROM complaints WHERE id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, complaintId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("user_id");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // 6. Get a single complaint by ID
    public static Complaint getComplaintById(int id) {
        try (Connection conn = DBConnection.getConnection()) {
            String sql = "SELECT * FROM complaints WHERE id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Complaint c = new Complaint();
                c.setId(rs.getInt("id"));
                c.setTitle(rs.getString("title"));
                c.setDescription(rs.getString("description"));
                c.setCategory(rs.getString("category"));
                c.setSeverityScore(rs.getInt("severity_score"));
                c.setStatus(rs.getString("status"));
                c.setImagePath(rs.getString("image_path"));
                c.setUserId(rs.getInt("user_id"));
                c.setDispatchStatus(rs.getString("dispatch_status"));
                c.setDispatchLog(rs.getString("dispatch_log"));
                c.setBountyPool(rs.getInt("bounty_pool"));
                return c;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // 7. Update Dispatch Status and Log
    public static void updateDispatch(int id, String status, String log) {
        try (Connection conn = DBConnection.getConnection()) {
            String sql = "UPDATE complaints SET dispatch_status = ?, dispatch_log = ? WHERE id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, status);
            ps.setString(2, log);
            ps.setInt(3, id);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // 8. Add Bounty points to incident
    public static void addBounty(int id, int bountyPoints) {
        try (Connection conn = DBConnection.getConnection()) {
            String sql = "UPDATE complaints SET bounty_pool = bounty_pool + ? WHERE id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, bountyPoints);
            ps.setInt(2, id);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}