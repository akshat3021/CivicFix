package com.civicfix.dao;

import com.civicfix.model.Complaint;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class ComplaintDAO {
    
    // 1. Insert Complaint (Now includes image_path!)
    public static boolean insertComplaint(Complaint c) {
        boolean isSuccess = false;
        try (Connection conn = DBConnection.getConnection()) {
            // Notice we are asking SQL to save 6 things now, including the image_path
            String sql = "INSERT INTO complaints (title, description, category, severity_score, status, image_path) VALUES (?, ?, ?, ?, 'OPEN', ?)";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, c.getTitle());
            ps.setString(2, c.getDescription());
            ps.setString(3, c.getCategory());
            ps.setInt(4, 50); 
            ps.setString(5, c.getImagePath()); // Save the image path!
            
            int rows = ps.executeUpdate();
            if (rows > 0) isSuccess = true;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return isSuccess;
    }

    // 2. Fetch All Complaints
    public static List<Complaint> getAllComplaints() {
        List<Complaint> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection()) {
            // Smart Sort: OPEN first, then highest severity score!
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
                
                // Fetch the image path out of the database!
                c.setImagePath(rs.getString("image_path"));
                
                list.add(c);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 3. Update Status (Resolve)
    public static void updateStatus(int id, String status) {
        try (Connection conn = DBConnection.getConnection()) {
            String sql = "UPDATE complaints SET status = ? WHERE id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, status);
            ps.setInt(2, id);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    // 4. Delete Complaint
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
    
    // 5. Secure Voting Engine (Prevents double votes)
    public static boolean addVote(String username, int complaintId) {
        try (Connection conn = DBConnection.getConnection()) {
            
            // 1. Try to record the user's vote
            String insertVote = "INSERT INTO user_votes (username, complaint_id) VALUES (?, ?)";
            try (PreparedStatement ps1 = conn.prepareStatement(insertVote)) {
                ps1.setString(1, username);
                ps1.setInt(2, complaintId);
                ps1.executeUpdate(); 
                // If they already voted, this will crash and jump to the catch block!
            }
            
            // 2. If we reach here, the vote was legally recorded. Increase the score!
            String updateScore = "UPDATE complaints SET severity_score = severity_score + 10 WHERE id = ?";
            try (PreparedStatement ps2 = conn.prepareStatement(updateScore)) {
                ps2.setInt(1, complaintId);
                ps2.executeUpdate();
            }
            return true; // Vote successful!
            
        } catch (Exception e) {
            // They already voted, or another error occurred
            System.out.println("🚫 Blocked duplicate vote from " + username + " on Issue #" + complaintId);
            return false; 
        }
    }
}