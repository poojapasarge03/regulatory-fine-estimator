package com.internship.tool.controller;

import com.internship.tool.dto.EmailNotificationDto;
import com.internship.tool.service.EmailService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/email")
@CrossOrigin(origins = "*")
public class EmailNotificationController {

    @Autowired
    private EmailService emailService;

    @PostMapping("/test")
    public ResponseEntity<?> sendTestEmail(@RequestBody Map<String, String> request) {
        try {
            String recipientEmail = request.get("email");
            emailService.sendSimpleEmail(recipientEmail, "Test Email - Regulatory Fine Estimator",
                    "This is a test email to verify email configuration is working correctly.");
            Map<String, String> response = new HashMap<>();
            response.put("message", "Test email sent successfully to " + recipientEmail);
            response.put("status", "success");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, String> response = new HashMap<>();
            response.put("message", "Error sending test email: " + e.getMessage());
            response.put("status", "error");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    @PostMapping("/send-custom")
    public ResponseEntity<?> sendCustomEmail(@RequestBody EmailNotificationDto emailDto) {
        try {
            if (emailDto.getTo() == null || emailDto.getTo().isEmpty()) {
                Map<String, String> response = new HashMap<>();
                response.put("message", "Recipient email is required");
                response.put("status", "error");
                return ResponseEntity.badRequest().body(response);
            }
            emailService.sendHtmlEmail(emailDto);
            Map<String, String> response = new HashMap<>();
            response.put("message", "Email sent successfully");
            response.put("status", "success");
            response.put("recipient", emailDto.getTo());
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, String> response = new HashMap<>();
            response.put("message", "Error sending email: " + e.getMessage());
            response.put("status", "error");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    @GetMapping("/health")
    public ResponseEntity<?> checkEmailServiceHealth() {
        Map<String, String> response = new HashMap<>();
        response.put("status", "healthy");
        response.put("message", "Email service is running");
        response.put("timestamp", java.time.LocalDateTime.now().toString());
        return ResponseEntity.ok(response);
    }
}
