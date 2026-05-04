package com.internship.tool.service;

import com.internship.tool.entity.RegulatoryViolation;
import com.internship.tool.entity.User;
import com.internship.tool.repository.RegulatoryViolationRepository;
import com.internship.tool.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class ScheduledEmailService {

    @Autowired
    private EmailService emailService;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private RegulatoryViolationRepository violationRepository;



    /**
     * Send daily reminder emails - runs every day at 9:00 AM
     * Cron: 0 9 * * * = 9:00 AM every day
     */
    @Scheduled(cron = "${scheduled.email.daily-reminder-cron:0 0 9 * * ?}")
    public void sendDailyReminders() {
        try {
            List<User> activeUsers = userRepository.findAll();
            for (User user : activeUsers) {
                try {
                    List<RegulatoryViolation> userViolations = violationRepository.findAll().stream()
                            .filter(v -> user.getUsername().equals(v.getCreatedBy()))
                            .collect(Collectors.toList());
                    if (!userViolations.isEmpty()) {
                        emailService.sendDailyReminderEmail(user.getUsername(), user.getUsername() + "@example.com", userViolations.size());
                    }
                } catch (Exception e) {
                    System.err.println("Error sending daily reminder to: " + user.getUsername());
                }
            }
        } catch (Exception e) {
            System.err.println("Error in daily reminder task: " + e.getMessage());
        }
    }

    /**
     * Send deadline alert emails - runs every day at 10:00 AM
     * Checks violations with deadlines within 7 days
     */
    @Scheduled(cron = "${scheduled.email.deadline-alert-cron:0 0 10 * * ?}")
    public void sendDeadlineAlerts() {
        try {
            java.time.LocalDateTime now = java.time.LocalDateTime.now();
            java.time.LocalDateTime sevenDaysLater = now.plusDays(7);
            List<RegulatoryViolation> upcoming = violationRepository.findAll().stream()
                    .filter(v -> v.getDeadline() != null
                            && v.getDeadline().isAfter(now)
                            && v.getDeadline().isBefore(sevenDaysLater)
                            && (v.getEmailSent() == null || !v.getEmailSent())
                            && !"completed".equalsIgnoreCase(v.getStatus()))
                    .collect(Collectors.toList());
            for (RegulatoryViolation v : upcoming) {
                emailService.sendDeadlineAlertEmail(
                        v.getCreatedBy(),
                        v.getCreatedBy() + "@example.com",
                        v.getTitle(),
                        v.getDeadline().toString(),
                        v.getSeverity() != null ? v.getSeverity() : "Medium",
                        v.getEstimatedFine() != null ? "$" + v.getEstimatedFine() : "N/A"
                );
                v.setEmailSent(true);
                violationRepository.save(v);
            }
        } catch (Exception e) {
            System.err.println("Error in deadline alert task: " + e.getMessage());
        }
    }

    /**
     * Send weekly violation report - runs every Monday at 8:00 AM
     * Cron: 0 8 * * 1 = Monday at 8:00 AM
     */
    @Scheduled(cron = "${scheduled.email.weekly-report-cron:0 0 8 ? * MON}")
    public void sendWeeklyReports() {
        try {
            List<User> activeUsers = userRepository.findAll();
            for (User user : activeUsers) {
                try {
                    List<RegulatoryViolation> violations = violationRepository.findAll().stream()
                            .filter(v -> user.getUsername().equals(v.getCreatedBy()))
                            .collect(Collectors.toList());
                    if (!violations.isEmpty()) {
                        String reportData = buildReportData(violations);
                        emailService.sendViolationReportEmail(user.getUsername(), user.getUsername() + "@example.com", reportData);
                    }
                } catch (Exception e) {
                    System.err.println("Error sending weekly report to: " + user.getUsername());
                }
            }
        } catch (Exception e) {
            System.err.println("Error in weekly report task: " + e.getMessage());
        }
    }

    /**
     * Send critical violation alerts - runs every 2 hours
     */
    @Scheduled(cron = "${scheduled.email.critical-alert-cron:0 0 */2 * * ?}")
    public void sendCriticalViolationAlerts() {
        try {
            List<RegulatoryViolation> critical = violationRepository.findAll().stream()
                    .filter(v -> "critical".equalsIgnoreCase(v.getSeverity())
                            && !"completed".equalsIgnoreCase(v.getStatus())
                            && (v.getEmailSent() == null || !v.getEmailSent()))
                    .collect(Collectors.toList());
            for (RegulatoryViolation v : critical) {
                emailService.sendDeadlineAlertEmail(
                        v.getCreatedBy(),
                        v.getCreatedBy() + "@example.com",
                        v.getTitle(),
                        v.getDeadline() != null ? v.getDeadline().toString() : "N/A",
                        "CRITICAL",
                        v.getEstimatedFine() != null ? "$" + v.getEstimatedFine() : "N/A"
                );
                v.setEmailSent(true);
                violationRepository.save(v);
            }
        } catch (Exception e) {
            System.err.println("Error in critical alert task: " + e.getMessage());
        }
    }

    /**
     * Build report data HTML from violations
     */
    private String buildReportData(List<RegulatoryViolation> violations) {
        java.time.format.DateTimeFormatter formatter = java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
        StringBuilder sb = new StringBuilder();
        sb.append("<table style='width:100%; border-collapse: collapse;'>");
        sb.append("<tr><th>Title</th><th>Severity</th><th>Status</th><th>Deadline</th></tr>");

        for (RegulatoryViolation v : violations) {
            sb.append("<tr>");
            sb.append("<td>").append(v.getTitle()).append("</td>");
            sb.append("<td>").append(v.getSeverity() != null ? v.getSeverity() : "N/A").append("</td>");
            sb.append("<td>").append(v.getStatus() != null ? v.getStatus() : "N/A").append("</td>");
            String deadline = v.getDeadline() != null ? v.getDeadline().format(formatter) : "N/A";
            sb.append("<td>").append(deadline).append("</td>");
            sb.append("</tr>");
        }

        sb.append("</table>");
        return sb.toString();
    }
}
