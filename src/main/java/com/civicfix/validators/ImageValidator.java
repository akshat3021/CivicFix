package com.civicfix.validators;
    
public class ImageValidator {

    public static boolean isValid(long sizeInBytes, String contentType) {
        long maxSize = 2 * 1024 * 1024; // 2MB

        if (sizeInBytes > maxSize) {
            return false;
        }

        if (!contentType.equals("image/jpeg") && !contentType.equals("image/png")) {
            return false;
        }

        return true;
    }
}

