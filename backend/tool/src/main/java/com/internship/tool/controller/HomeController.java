package com.internship.tool.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.view.RedirectView;

import java.util.HashMap;
import java.util.Map;

/**
 * Home Controller - Handles root path requests
 * Provides welcome message and API documentation links
 */
@RestController
public class HomeController {

    /**
     * Root endpoint - Redirects to API documentation
     */
    @GetMapping("/")
    public RedirectView root() {
        return new RedirectView("/swagger-ui.html", true);
    }

    /**
     * Welcome endpoint - Returns API information
     */
    @GetMapping("/api")
    public ResponseEntity<Map<String, Object>> welcome() {
        Map<String, Object> response = new HashMap<>();
        response.put("application", "Regulatory Fine Estimator");
        response.put("version", "1.0.0");
        response.put("status", "UP");
        response.put("documentation", "/swagger-ui.html");
        response.put("health", "/actuator/health");
        response.put("endpoints", new HashMap<String, String>() {{
            put("violations", "/api/violations");
            put("projects", "/api/projects");
            put("email", "/api/email");
            put("auth", "/api/auth");
        }});
        return ResponseEntity.ok(response);
    }

    /**
     * Info endpoint - Returns application information
     */
    @GetMapping("/info")
    public ResponseEntity<Map<String, String>> info() {
        Map<String, String> info = new HashMap<>();
        info.put("name", "Regulatory Fine Estimator");
        info.put("description", "Backend API for regulatory fine estimation system");
        info.put("version", "1.0.0");
        info.put("api_docs", "http://localhost:8080/swagger-ui.html");
        info.put("api_base", "http://localhost:8080/api");
        return ResponseEntity.ok(info);
    }
}
