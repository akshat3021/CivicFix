package com.civicfix;

import com.civicfix.model.Complaint;
import com.civicfix.service.PriorityService;
import com.civicfix.service.VotingEngine;
import java.util.ArrayList;
import java.util.List;

public class Main {
    public static void main(String[] args) {
        // 1. Initialize your Module 3 components
        PriorityService brain = new PriorityService();
        VotingEngine votingEngine = new VotingEngine();
        List<Complaint> allComplaints = new ArrayList<>();

        // 2. Create some "Dummy" Complaints
        // Case A: A simple pothole (Danger Level 4)
        Complaint pothole = new Complaint();
        pothole.setId(1);
        pothole.setTitle("Pothole on Main St");
        pothole.setDangerLevel(4);
        
        // Case B: A dangerous live wire (Danger Level 10)
        Complaint liveWire = new Complaint();
        liveWire.setId(2);
        liveWire.setTitle("Live Wire Sparking");
        liveWire.setDangerLevel(10);

        allComplaints.add(pothole);
        allComplaints.add(liveWire);

        // 3. Simulate Voting (Module 3 Logic)
        System.out.println("--- Simulating Votes ---");
        votingEngine.castVote("User_Alpha", pothole);
        votingEngine.castVote("User_Beta", pothole); // Pothole now has 2 votes
        
        // Simulate a Reopen (The x3 Multiplier)
        liveWire.setReopened(true); 

        // 4. Get the Ranked List for Module 4 (Admin)
        List<Complaint> rankedList = brain.getRankedComplaints(allComplaints);

        // 5. Print Results to Console
        System.out.println("\n--- FINAL ADMIN RANKING ---");
        for (Complaint c : rankedList) {
            System.out.println("Title: " + c.getTitle() + 
                               " | Score: " + c.getPriorityScore() + 
                               " | Votes: " + c.getVotes());
        }
    }
}