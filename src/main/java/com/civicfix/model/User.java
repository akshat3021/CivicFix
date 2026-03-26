package com.civicfix.model;

public class User {
    private int id;
    private String username;
    private String password;
    private String email;
    private int rewardPoints;
    private String role; // new for admin.

    public User() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public int getRewardPoints() { return rewardPoints; }
    public void setRewardPoints(int rewardPoints) { this.rewardPoints = rewardPoints; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
}