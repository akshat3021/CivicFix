package com.civicfix.controller;

import com.civicfix.AppConfig;
import com.civicfix.service.OtpService;
import com.civicfix.validators.EmailValidator;

import java.io.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/otp")
public class OtpServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        String action = request.getParameter("action");
        String email  = request.getParameter("email");

        if ("send".equals(action)) {
            // Validate format first
            String err = EmailValidator.validateFormat(email);
            if (err != null) {
                out.write("{\"ok\":false,\"msg\":\"" + err + "\"}");
                return;
            }

            String otp = OtpService.generateAndSend(email.trim().toLowerCase());
            if (otp != null) {
                // In production: OTP goes to email only — never expose it in response
                // In dev mode (no mail creds): show it on screen so you can test
                if (AppConfig.IS_PRODUCTION) {
                    out.write("{\"ok\":true,\"msg\":\"OTP sent to your email inbox.\"}");
                } else {
                    // Dev mode: show OTP in response so registration can be tested locally
                    out.write("{\"ok\":true,\"dev\":true,\"otp\":\"" + otp + "\",\"msg\":\"Dev mode: OTP shown below\"}");
                }
            } else {
                out.write("{\"ok\":false,\"msg\":\"Failed to generate OTP. Try again.\"}");
            }

        } else if ("verify".equals(action)) {
            String otp = request.getParameter("otp");
            boolean valid = OtpService.verifyOtp(email, otp);
            if (valid) {
                request.getSession().setAttribute("verified_email", email.trim().toLowerCase());
                out.write("{\"ok\":true,\"msg\":\"Email verified successfully!\"}");
            } else {
                out.write("{\"ok\":false,\"msg\":\"Incorrect or expired OTP. Please try again.\"}");
            }
        }
    }
}