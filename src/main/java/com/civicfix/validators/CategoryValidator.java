package com.civicfix.validators;

import java.util.Arrays;
import java.util.List;

public class CategoryValidator {

    private static final List<String> VALID_CATEGORIES = Arrays.asList(
            "ROADS",
            "ELECTRIC",
            "SANITATION",
            "WATER",
            "PUBLIC_SAFETY",
            "OTHER"
    );

    public static String validate(String category) {
        if (category == null) return "Category is required";

        if (!VALID_CATEGORIES.contains(category.toUpperCase().trim())) {
            return "Invalid category selected.";
        }
        return null;
    }
}