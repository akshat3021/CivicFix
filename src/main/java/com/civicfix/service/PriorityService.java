package com.civicfix.service;

import com.civicfix.model.Complaint;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

public class PriorityService {

    /**
     * The Algorithm: Score = (Votes * 2) + Danger Level. 
     * Reopen Logic: Triples the score if the issue was rejected by user.
     */
    public void calculateScore(Complaint complaint) {
        double score = (complaint.getVotes() * 2) + complaint.getDangerLevel();
        
        if (complaint.isReopened()) {
            score *= 3; 
        }
        
        complaint.setPriorityScore(score);
    }

    /**
     * Ranking Engine: Sorts complaints from highest to lowest priority.
     */
    public List<Complaint> getRankedComplaints(List<Complaint> allComplaints) {
        // First, ensure all scores are up to date
        allComplaints.forEach(this::calculateScore);

        // Return sorted list (Highest Score First)
        return allComplaints.stream()
            .sorted(Comparator.comparingDouble(Complaint::getPriorityScore).reversed())
            .collect(Collectors.toList());
    }
}