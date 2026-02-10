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
            String sql = "SELECT * FROM complaints ORDER BY created_at DESC";
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
                // c.setCreatedAt(rs.getTimestamp("created_at")); // Optional
                
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
}