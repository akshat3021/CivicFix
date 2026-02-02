# Complaint Data Format – Module 2

This document explains each field in the complaint object.

- complaint_id  
  Unique ID for each complaint (generated automatically).

- user_id  
  ID of the user who submitted the complaint (from Module 1).

- title  
  Short heading describing the issue.

- description  
  Detailed explanation of the complaint.

- category  
  Type of issue (Road, Water, Electricity, etc.).

- image_base64  
  Complaint image converted into Base64 format.
  Null if no image is provided.

- location  
  Latitude and longitude of the issue.
  Null if location is not provided.

- danger_score  
  Priority score returned from Module 3.

- status  
  Current state of the complaint.
  Default value is OPEN.

- created_at  
  Date and time when complaint was submitted.
