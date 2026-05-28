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

    // 3b. Add Reward Points by User ID
    public static void addRewardPointsById(int userId, int pointsToAdd) {
        try (Connection conn = DBConnection.getConnection()) {
            String sql = "UPDATE users SET reward_points = reward_points + ? WHERE id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, pointsToAdd);
            ps.setInt(2, userId);
            ps.executeUpdate();
            System.out.println("🏆 Gatekeeper: Added " + pointsToAdd + " points to user ID " + userId);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // 4. Get Leaderboard of users
    public static java.util.List<User> getLeaderboard(int limit) {
        java.util.List<User> list = new java.util.ArrayList<>();
        try (Connection conn = DBConnection.getConnection()) {
            String sql = "SELECT * FROM users WHERE role = 'USER' ORDER BY reward_points DESC LIMIT ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, limit);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                User u = new User();
                u.setId(rs.getInt("id"));
                u.setUsername(rs.getString("username"));
                u.setEmail(rs.getString("email"));
                u.setRewardPoints(rs.getInt("reward_points"));
                u.setRole(rs.getString("role"));
                list.add(u);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 5. Store a notification in database
    public static void pushNotification(int userId, String message) {
        try (Connection conn = DBConnection.getConnection()) {
            String sql = "INSERT INTO notifications (user_id, message) VALUES (?, ?)";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ps.setString(2, message);
            ps.executeUpdate();
            System.out.println("🔔 Notification pushed to user " + userId + ": " + message);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // 6. Get notifications for a user
    public static java.util.List<String> getNotifications(int userId) {
        java.util.List<String> list = new java.util.ArrayList<>();
        try (Connection conn = DBConnection.getConnection()) {
            String sql = "SELECT message FROM notifications WHERE user_id = ? ORDER BY created_at DESC LIMIT 10";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(rs.getString("message"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}