package com.civicfix.dao;

import com.civicfix.model.User;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class UserDAO {

    // 1. Register a new citizen
    public static boolean registerUser(User user) {
        boolean isSuccess = false;
        try (Connection conn = DBConnection.getConnection()) {
            String sql = "INSERT INTO users (username, password, email, reward_points) VALUES (?, ?, ?, ?)";
            PreparedStatement ps = conn.prepareStatement(sql);
            
            ps.setString(1, user.getUsername());
            ps.setString(2, user.getPassword()); // In a real app, we would hash this!
            ps.setString(3, user.getEmail());
            ps.setInt(4, 0); // New users start with 0 reward points
            
            int rowsAffected = ps.executeUpdate();
            if (rowsAffected > 0) {
                isSuccess = true;
                System.out.println("✅ Gatekeeper: New user registered -> " + user.getUsername());
            }
        } catch (Exception e) {
            System.out.println("❌ Gatekeeper Error: Registration failed.");
            e.printStackTrace();
        }
        return isSuccess;
    }

    // 2. Validate Login (Identity Check)
    public static User validateLogin(String username, String password) {
        User user = null;
        try (Connection conn = DBConnection.getConnection()) {
            String sql = "SELECT * FROM users WHERE username = ? AND password = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, username);
            ps.setString(2, password);
            
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                user = new User();
                user.setId(rs.getInt("id"));
                user.setUsername(rs.getString("username"));
                user.setEmail(rs.getString("email"));
                user.setRewardPoints(rs.getInt("reward_points"));
                System.out.println("✅ Gatekeeper: Access Granted for -> " + username);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return user;
    }
}