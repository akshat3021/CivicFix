package com.civicfix.service;

import com.civicfix.dao.DBConnection;
import java.sql.*;
import java.util.Random;

public class OtpService {

    public static String generateAndSend(String email) {
        String otp = String.format("%06d", new Random().nextInt(999999));
        try (Connection conn = DBConnection.getConnection()) {
            conn.createStatement().execute(
                "CREATE TABLE IF NOT EXISTS pending_otps (" +
                "  email TEXT PRIMARY KEY, otp TEXT NOT NULL, expires_at TIMESTAMP NOT NULL)");

            PreparedStatement ps = conn.prepareStatement(
                "INSERT OR REPLACE INTO pending_otps (email, otp, expires_at) " +
                "VALUES (?, ?, datetime('now', '+10 minutes'))");
            // PostgreSQL version
            if (AppConfig.isPostgres()) {
                ps = conn.prepareStatement(
                    "INSERT INTO pending_otps (email, otp, expires_at) " +
                    "VALUES (?, ?, NOW() + INTERVAL '10 minutes') " +
                    "ON CONFLICT (email) DO UPDATE SET otp=EXCLUDED.otp, expires_at=EXCLUDED.expires_at");
            }
            ps.setString(1, email.toLowerCase().trim());
            ps.setString(2, otp);
            ps.executeUpdate();

            // Send via real email (or log to console in dev)
            EmailService.sendOtpEmail(email, otp);
            return otp;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    public static boolean verifyOtp(String email, String otp) {
        try (Connection conn = DBConnection.getConnection()) {
            PreparedStatement ps = conn.prepareStatement(
                "SELECT otp FROM pending_otps WHERE email=? AND expires_at > CURRENT_TIMESTAMP");
            ps.setString(1, email.toLowerCase().trim());
            ResultSet rs = ps.executeQuery();
            if (rs.next() && otp.trim().equals(rs.getString("otp"))) {
                conn.prepareStatement("DELETE FROM pending_otps WHERE email='" +
                    email.toLowerCase().trim() + "'").executeUpdate();
                return true;
            }
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    // Helper — check if using postgres (for SQL dialect differences)
    public static class AppConfig {
        public static boolean isPostgres() {
            return com.civicfix.AppConfig.DB_URL.startsWith("jdbc:postgresql");
        }
    }
}