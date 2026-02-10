package com.civicfix.dao;

import com.civicfix.model.Complaint;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ComplaintDAO {
    
    public static List<Complaint> getAllComplaints() {
        List<Complaint> list = new ArrayList<>();
        
        try (Connection conn = DBConnection.getConnection()) {
           
            String sql = "SELECT * FROM complaints";
            
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                int id = rs.getInt("id");
                String title = rs.getString("title");
                String category = rs.getString("category");
                int score = rs.getInt("severity_score");
                
                list.add(new Complaint(id, title, category, score));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}