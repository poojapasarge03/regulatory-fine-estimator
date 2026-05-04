package com.internship.tool.service;

import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

import com.internship.tool.dto.EmailNotificationDto;

@Service
public class EmailService {

    @Autowired(required = false)
    private JavaMailSender javaMailSender;

    @Value("${spring.mail.username:no-reply@example.com}")
    private String fromEmail;

    @Value("${spring.mail.host:disabled}")
    private String mailHost;

    public void sendSimpleEmail(String to, String subject, String text) {
        if (javaMailSender == null || "disabled".equals(mailHost)) {
            System.out.println("[EMAIL DISABLED] To: " + to + " | Subject: " + subject);
            return;
        }
        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setFrom(fromEmail);
            message.setTo(to);
            message.setSubject(subject);
            message.setText(text);
            javaMailSender.send(message);
        } catch (Exception e) {
            System.err.println("Failed to send email to: " + to + " - " + e.getMessage());
        }
    }

    public void sendHtmlEmail(EmailNotificationDto emailDto) {
        sendHtmlEmail(emailDto.getTo(), emailDto.getSubject(), "<p>" + emailDto.getSubject() + "</p>");
    }

    public void sendHtmlEmail(String to, String subject, String htmlContent) {
        if (javaMailSender == null || "disabled".equals(mailHost)) {
            System.out.println("[EMAIL DISABLED] To: " + to + " | Subject: " + subject);
            return;
        }
        try {
            MimeMessage mimeMessage = javaMailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(mimeMessage, true, "UTF-8");
            helper.setFrom(fromEmail);
            helper.setTo(to);
            helper.setSubject(subject);
            helper.setText(htmlContent, true);
            javaMailSender.send(mimeMessage);
        } catch (MessagingException e) {
            System.err.println("Failed to send HTML email to: " + to + " - " + e.getMessage());
        }
    }

    public void sendDailyReminderEmail(String userName, String userEmail, int violationCount) {
        String subject = "Daily Reminder: You have " + violationCount + " violation(s)";
        String body = "<p>Hello " + userName + ", you have <b>" + violationCount + "</b> open violation(s).</p>";
        sendHtmlEmail(userEmail, subject, body);
    }

    public void sendDeadlineAlertEmail(String userName, String userEmail, String violationTitle,
                                       String deadline, String severity, String estimatedFine) {
        String subject = "URGENT: Deadline Alert - " + violationTitle;
        String body = "<p>Hello " + userName + ", violation <b>" + violationTitle + "</b> (severity: "
                + severity + ") is due on " + deadline + ". Estimated fine: " + estimatedFine + "</p>";
        sendHtmlEmail(userEmail, subject, body);
    }

    public void sendViolationReportEmail(String userName, String userEmail, String reportData) {
        String subject = "Weekly Regulatory Violation Report";
        String body = "<p>Hello " + userName + ",</p>" + reportData;
        sendHtmlEmail(userEmail, subject, body);
    }
}
