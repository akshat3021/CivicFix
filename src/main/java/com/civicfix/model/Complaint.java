package com.civicfix.model;

import java.time.LocalDateTime;

public class Complaint {
    private int id;
    private String title;
    private String description;
    private String category; 
    private int severityScore; 
    private String status; 
    
    // Constructor
    public Complaint(int id, String title, String category, int score) {
        this.id = id;
        this.title = title;
        this.category = category;
        this.severityScore = score;
        this.status = "OPEN";
    }

    // Getters (Right-click > Source Action > Generate Getters if you want, or just copy these)
    public int getId() { return id; }
    public String getTitle() { return title; }
    public String getCategory() { return category; }
    public int getSeverityScore() { return severityScore; }
    public String getStatus() { return status; }
}