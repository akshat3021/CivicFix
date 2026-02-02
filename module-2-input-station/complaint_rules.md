# Complaint Input Rules – Module 2 (Input Station)

This document defines the rules for accepting complaints into the CivicFix system.
Only complaints that follow these rules are allowed to enter the system.

---

## 1. Title
- Mandatory field
- Cannot be empty or blank
- Maximum length: 100 characters

Example:
"Broken streetlight near main gate"

---

## 2. Description
- Mandatory field
- Minimum length: 20 characters
- Should clearly explain the issue

Example:
"The streetlight near the main gate has not been working for the past two weeks."

---

## 3. Category
- Mandatory field
- User must choose ONE of the following categories:

  - Road
  - Electricity
  - Water
  - Garbage
  - Public Safety
  - Other

- Free text category input is not allowed

---

## 4. Image
- Optional field
- Allowed image formats:
  - JPG
  - PNG
- Maximum allowed file size: 2MB
- If the image is invalid, the complaint must still be accepted without the image

---

## 5. Location
- Optional field
- If provided, it must contain:
  - Latitude
  - Longitude
- Location data will be used for heatmap visualization
