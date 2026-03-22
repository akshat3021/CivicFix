package com.civicfix.service;

import com.civicfix.model.Complaint;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

public class VotingEngine {
    // Stores which UserIDs voted for which ComplaintID
    private Map<Integer, Set<String>> voteRecord = new HashMap<>();
    private PriorityService priorityService = new PriorityService();

    public boolean castVote(String userId, Complaint complaint) {
        voteRecord.putIfAbsent(complaint.getId(), new HashSet<>());
        Set<String> usersWhoVoted = voteRecord.get(complaint.getId());

        if (usersWhoVoted.contains(userId)) {
            System.out.println("Duplicate vote blocked for User: " + userId);
            return false; // Vote failed (already voted)
        }

        // 1. Add the user to the voter list
        usersWhoVoted.add(userId);
        
        // 2. Increment the vote count
        complaint.setVotes(complaint.getVotes() + 1);
        
        // 3. THE MISSING PIECE: Trigger the Brain to update the priority score
        priorityService.calculateScore(complaint);
        
        return true; // Vote successful
    }
}