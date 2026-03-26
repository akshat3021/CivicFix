package com.civicfix.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;

public class DBConnection {

    // SQLite: single file stored in the project folder. No server needed!
    private static final String DB_PATH = "civicfix.db";
    private static final String URL = "jdbc:sqlite:" + DB_PATH;

    public static Connection getConnection() {
        Connection connection = null;
        try {
            Class.forName("org.sqlite.JDBC");
            connection = DriverManager.getConnection(URL);
            // Enable foreign keys for SQLite
            try (Statement st = connection.createStatement()) {
                st.execute("PRAGMA foreign_keys = ON");
            }
            System.out.println("✅ SQLite Connected: " + DB_PATH);
        } catch (ClassNotFoundException e) {
            System.out.println("❌ SQLite Driver not found. Add sqlite-jdbc to pom.xml");
            e.printStackTrace();
        } catch (SQLException e) {
            System.out.println("❌ SQLite connection failed.");
            e.printStackTrace();
        }
        return connection;
    }

    /**
     * Call this once on app startup to create tables if they don't exist.
     * Add a ServletContextListener or call from a test class.
     */
    public static void initializeDatabase() {
        String createUsers = """
            CREATE TABLE IF NOT EXISTS users (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                username TEXT NOT NULL UNIQUE,
                password TEXT NOT NULL,
                email TEXT NOT NULL UNIQUE,
                reward_points INTEGER DEFAULT 0,
                role TEXT NOT NULL DEFAULT 'USER'
            )
            """;

        String createComplaints = """
            CREATE TABLE IF NOT EXISTS complaints (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                title TEXT NOT NULL,
                description TEXT,
                category TEXT NOT NULL,
                severity_score INTEGER DEFAULT 50,
                status TEXT NOT NULL DEFAULT 'OPEN',
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP
            )
            """;

        try (Connection conn = getConnection();
             Statement st = conn.createStatement()) {
            st.execute(createUsers);
            st.execute(createComplaints);
            System.out.println("✅ CivicFix tables initialized (SQLite).");
        } catch (SQLException e) {
            System.out.println("❌ Table creation failed.");
            e.printStackTrace();
        }
    }
}