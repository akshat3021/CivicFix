package com.civicfix.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {
    
    // Database Credentials (WE WILL CHANGE THESE LATER)
    private static final String URL = "jdbc:mysql://localhost:3306/civicfix_db";
    private static final String USERNAME = "root";
    private static final String PASSWORD = "root"; // Or your MySQL password

    // This method gives us a connection to the database
    public static Connection getConnection() {
        Connection connection = null;
        try {
            // 1. Load the MySQL Driver (The bridge)
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // 2. Establish the connection
            connection = DriverManager.getConnection(URL, USERNAME, PASSWORD);
            System.out.println("✅ Database Connected Successfully!");
            
        } catch (ClassNotFoundException e) {
            System.out.println("❌ Error: MySQL Driver not found.");
            e.printStackTrace();
        } catch (SQLException e) {
            System.out.println("❌ Error: Could not connect to Database. Check username/password.");
            e.printStackTrace();
        }
        return connection;
    }
}