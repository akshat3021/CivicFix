package com.civicfix.dao;

import com.civicfix.model.User;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class UserDAO {

    // 1. Register a new citizen or admin
    public static boolean registerUser(User user) {
        boolean isSuccess = false;
        try (Connection conn = DBConnection.getConnection()) {
            // Updated SQL to include the 'role' column
            String sql = "INSERT INTO users (username, password, email, reward_points, role) VALUES (?, ?, ?, ?, ?)";
            PreparedStatement ps = conn.prepareStatement(sql);
            
            ps.setString(1, user.getUsername());
            ps.setString(2, user.getPassword()); 
            ps.setString(3, user.getEmail());
            ps.setInt(4, 0); // New users start with 0 reward points
            ps.setString(5, user.getRole()); // Saving the Admin or User role
            
            int rowsAffected = ps.executeUpdate();
            if (rowsAffected > 0) {
                isSuccess = true;
                System.out.println("✅ Gatekeeper: New " + user.getRole() + " registered -> " + user.getUsername());
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
                user.setRole(rs.getString("role")); // Fetching the role from the database
                
                System.out.println("✅ Gatekeeper: Access Granted for -> " + username + " [" + user.getRole() + "]");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return user;
    }

    // 3. Add Reward Points
    public static void addRewardPoints(String username, int pointsToAdd) {
        try (Connection conn = DBConnection.getConnection()) {
            String sql = "UPDATE users SET reward_points = reward_points + ? WHERE username = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, pointsToAdd);
            ps.setString(2, username);
            ps.executeUpdate();
            System.out.println("🏆 Gatekeeper: Added " + pointsToAdd + " points to " + username);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}