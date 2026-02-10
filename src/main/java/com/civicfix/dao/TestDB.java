package com.civicfix.dao;

import java.sql.Connection;

public class TestDB {
    public static void main(String[] args) {
        System.out.println("Testing Database Connection...");
        
        Connection conn = DBConnection.getConnection();
        
        if(conn != null) {
            System.out.println("SUCCESS! The bridge is open.");
        } else {
            System.out.println("FAILURE! The bridge is broken.");
        }
    }
}