package com.civicfix.validators;

import javax.naming.NamingException;
import javax.naming.directory.Attributes;
import javax.naming.directory.DirContext;
import javax.naming.directory.InitialDirContext;
import java.util.Hashtable;
import java.util.regex.Pattern;

/**
 * Two-layer email validation:
 *  1. Regex — checks format (user@domain.tld)
 *  2. DNS MX lookup — verifies the domain actually accepts email
 *     (e.g. rejects "user@thisdoesnotexist12345.com")
 *
 * This catches fake domains without needing to send an actual email.
 * For full verification, pair with an OTP sent via JavaMail.
 */
public class EmailValidator {

    // Standard email regex — covers 99.9% of real addresses
    private static final Pattern EMAIL_PATTERN = Pattern.compile(
        "^[a-zA-Z0-9._%+\\-]+@[a-zA-Z0-9.\\-]+\\.[a-zA-Z]{2,}$"
    );

    /**
     * Validates format only. Fast, no network call.
     * Use this for instant client-side-style feedback on the server.
     */
    public static String validateFormat(String email) {
        if (email == null || email.trim().isEmpty())
            return "Email is required.";
        if (email.length() > 254)
            return "Email is too long.";
        if (!EMAIL_PATTERN.matcher(email.trim()).matches())
            return "Invalid email format. Use: name@domain.com";
        return null; // valid
    }

    /**
     * Full validation: format + DNS MX record check.
     * Adds ~200ms latency. Call this during registration.
     * Returns null if valid, or an error message string.
     */
    public static String validateFull(String email) {
        String formatError = validateFormat(email);
        if (formatError != null) return formatError;

        String domain = email.substring(email.indexOf('@') + 1).toLowerCase().trim();

        // Allow common domains without DNS lookup (faster UX)
        if (isKnownGoodDomain(domain)) return null;

        // DNS MX record check for unknown domains
        if (!hasMxRecord(domain)) {
            return "Email domain '" + domain + "' does not appear to be valid. Please use a real email.";
        }
        return null;
    }

    // Known-good domains — skip DNS for these (they always have MX)
    private static boolean isKnownGoodDomain(String domain) {
        return domain.equals("gmail.com") || domain.equals("yahoo.com")
            || domain.equals("outlook.com") || domain.equals("hotmail.com")
            || domain.equals("icloud.com") || domain.equals("protonmail.com")
            || domain.equals("live.com") || domain.equals("rediffmail.com")
            || domain.endsWith(".edu") || domain.endsWith(".ac.in")
            || domain.endsWith(".gov.in");
    }

    // DNS lookup: checks if the domain has an MX (Mail eXchanger) record
    private static boolean hasMxRecord(String domain) {
        try {
            Hashtable<String, String> env = new Hashtable<>();
            env.put("java.naming.factory.initial", "com.sun.jndi.dns.DnsContextFactory");
            env.put("com.sun.jndi.dns.timeout.initial", "2000"); // 2 second timeout
            env.put("com.sun.jndi.dns.timeout.retries", "1");
            DirContext ctx = new InitialDirContext(env);
            Attributes attrs = ctx.getAttributes("dns:/" + domain, new String[]{"MX"});
            return attrs.get("MX") != null;
        } catch (NamingException e) {
            // DNS lookup failed or domain has no MX — treat as invalid
            return false;
        }
    }
}