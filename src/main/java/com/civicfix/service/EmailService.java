package com.civicfix.service;

import com.civicfix.AppConfig;
import javax.mail.*;
import javax.mail.internet.*;
import java.util.Properties;

/**
 * Sends real emails via Gmail SMTP.
 *
 * SETUP (one-time):
 *  1. Go to myaccount.google.com → Security → 2-Step Verification → ON
 *  2. Then: myaccount.google.com → Security → App passwords
 *  3. Create app password for "Mail" → copy the 16-character code
 *  4. Set env var MAIL_USER=yourapp@gmail.com  MAIL_PASS=xxxx-xxxx-xxxx-xxxx
 *
 * On local dev (no env vars set), emails are skipped and OTP is logged to console.
 */
public class EmailService {

    public static boolean sendOtpEmail(String toEmail, String otp) {
        // Dev mode: just print to console, don't crash
        if (AppConfig.MAIL_USER.isBlank() || AppConfig.MAIL_PASS.isBlank()) {
            System.out.println("📧 [DEV MODE] OTP for " + toEmail + " → " + otp);
            return true; // pretend success so flow continues
        }

        try {
            Properties props = new Properties();
            props.put("mail.smtp.host",            "smtp.gmail.com");
            props.put("mail.smtp.port",            "587");
            props.put("mail.smtp.auth",            "true");
            props.put("mail.smtp.starttls.enable", "true");
            props.put("mail.smtp.ssl.trust",       "smtp.gmail.com");

            Session session = Session.getInstance(props, new Authenticator() {
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(AppConfig.MAIL_USER, AppConfig.MAIL_PASS);
                }
            });

            Message msg = new MimeMessage(session);
            msg.setFrom(new InternetAddress(AppConfig.MAIL_FROM));
            msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            msg.setSubject("CivicFix — Your verification code");
            msg.setContent(buildEmailHtml(otp), "text/html; charset=UTF-8");

            Transport.send(msg);
            System.out.println("✅ OTP email sent to " + toEmail);
            return true;

        } catch (Exception e) {
            System.err.println("❌ Email send failed: " + e.getMessage());
            return false;
        }
    }

    private static String buildEmailHtml(String otp) {
        return "<!DOCTYPE html><html><body style='margin:0;padding:0;background:#080c10;font-family:Arial,sans-serif;'>" +
               "<div style='max-width:480px;margin:40px auto;background:#0d1117;border:1px solid #1e2d3d;border-radius:12px;overflow:hidden;'>" +
               "<div style='background:#0a1628;padding:28px 32px;border-bottom:1px solid #1e2d3d;'>" +
               "<span style='font-size:24px;font-weight:700;letter-spacing:4px;color:#fff;'>CIVICFIX</span>" +
               "<p style='color:#586069;font-size:11px;letter-spacing:2px;margin:6px 0 0;'>CITIZEN INFRASTRUCTURE SYSTEM</p></div>" +
               "<div style='padding:32px;'>" +
               "<p style='color:#c9d1d9;font-size:15px;margin-bottom:20px;'>Your email verification code is:</p>" +
               "<div style='background:#0a1628;border:1px solid #1e2d3d;border-radius:8px;padding:20px;text-align:center;margin-bottom:24px;'>" +
               "<span style='font-family:monospace;font-size:40px;font-weight:700;letter-spacing:12px;color:#00d4ff;'>" + otp + "</span></div>" +
               "<p style='color:#586069;font-size:12px;'>This code expires in <strong style='color:#ffb800;'>10 minutes</strong>. " +
               "If you did not request this, you can safely ignore this email.</p></div>" +
               "<div style='padding:16px 32px;border-top:1px solid #1e2d3d;'>" +
               "<p style='color:#3d5a7a;font-size:11px;margin:0;'>CivicFix — Municipal Infrastructure Management &nbsp;|&nbsp; Do not reply to this email</p>" +
               "</div></div></body></html>";
    }
}