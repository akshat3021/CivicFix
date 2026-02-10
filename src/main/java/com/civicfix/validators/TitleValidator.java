package com.civicfix.validators;

public class TitleValidator {

    public static String validate(String title) {
        if (title == null || title.trim().isEmpty()) {
            return "Title is required";
        }

        if (title.length() > 100) {
            return "Title cannot exceed 100 characters";
        }

        return null; // means valid
    }
}
