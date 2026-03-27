package com.civicfix.model;

public class Complaint {
    
    // --- ALL VARIABLES AT THE TOP ---
    private int id; 
    private String title;
    private String description;
    private String category;
    private int votes;
    private int dangerLevel;
    private int severityScore; 
    private String status;
    private boolean isReopened;
    private double priorityScore;
    private String imagePath; // <-- Added right here with the others!

    // --- ALL GETTERS AND SETTERS BELOW ---
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

    public int getVotes() { return votes; }
    public void setVotes(int votes) { this.votes = votes; }
    
    public int getDangerLevel() { return dangerLevel; }
    public void setDangerLevel(int dangerLevel) { this.dangerLevel = dangerLevel; }
    
    public boolean isReopened() { return isReopened; }
    public void setReopened(boolean reopened) { this.isReopened = reopened; }
    
    public double getPriorityScore() { return priorityScore; }
    public void setPriorityScore(double priorityScore) { this.priorityScore = priorityScore; }
    
    public String getImagePath() { return imagePath; }
    public void setImagePath(String imagePath) { this.imagePath = imagePath; }
}