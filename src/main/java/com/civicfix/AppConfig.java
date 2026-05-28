package com.civicfix;

/**
 * Central config. On local dev, uses SQLite defaults.
 * On live server (Railway/Render), set these environment variables:
 *
 *   DB_URL      = jdbc:postgresql://host:5432/civicfix
 *   DB_USER     = your_pg_user
 *   DB_PASS     = your_pg_password
 *   MAIL_USER   = yourapp@gmail.com
 *   MAIL_PASS   = your_gmail_app_password   (16-char App Password, NOT your real password)
 *   APP_ENV     = production
 */
public class AppConfig {

    // ── Database ──────────────────────────────────────────────────────────
    public static final String DB_URL  = getEnv("DB_URL",  "jdbc:sqlite:civicfix.db");
    public static final String DB_USER = getEnv("DB_USER", "");
    public static final String DB_PASS = getEnv("DB_PASS", "");

    // ── Email (Gmail SMTP) ────────────────────────────────────────────────
    public static final String MAIL_USER = getEnv("MAIL_USER", "");
    public static final String MAIL_PASS = getEnv("MAIL_PASS", "");
    public static final String MAIL_FROM = getEnv("MAIL_FROM", "CivicFix <no-reply@civicfix.in>");

    // ── App ───────────────────────────────────────────────────────────────
    public static final boolean IS_PRODUCTION = "production".equals(getEnv("APP_ENV", "dev"));
    public static final String  ADMIN_PASSKEY = getEnv("ADMIN_PASSKEY", "CIVIC-ADMIN-2026");

    private static String getEnv(String key, String fallback) {
        String val = System.getenv(key);
        return (val != null && !val.isBlank()) ? val : fallback;
    }
}