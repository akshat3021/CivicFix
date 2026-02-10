package com.civicfix.model;

import java.sql.Timestamp;

public class Complaint {
    private int id;
    private String title;
    private String description;
    private String category;
    private int severityScore;
    private String status;
    private Timestamp createdAt;

    // 1. EMPTY CONSTRUCTOR (Crucial for the DAO error)
    public Complaint() {
    }

    // 2. FULL CONSTRUCTOR
    public Complaint(int id, String title, String category, int severityScore) {
        this.id = id;
        this.title = title;
        this.category = category;
        this.severityScore = severityScore;
        this.status = "OPEN";
    }

    // 3. GETTERS AND SETTERS (Crucial for the "cannot find symbol" errors)
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public int getSeverityScore() { return severityScore; }
    public void setSeverityScore(int severityScore) { this.severityScore = severityScore; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}