# Email Notifications System - Documentation

## Overview
This document describes the comprehensive email notification system implementation for the Regulatory Fine Estimator application using JavaMailSender, Thymeleaf templates, and scheduled tasks.

## Features

### 1. JavaMailSender Configuration
- **Location**: `com.internship.tool.config.MailConfig`
- **Functionality**:
  - SMTP configuration with Gmail support (configurable for any SMTP provider)
  - TLS encryption enabled by default
  - Connection pooling and timeout management
  - HTML email support

### 2. Thymeleaf Email Templates
- **Location**: `src/main/resources/templates/emails/`
- **Templates**:
  - `daily-reminder.html` - Daily summary of active violations
  - `deadline-alert.html` - Urgent deadline alerts with countdown
  - `violation-report.html` - Weekly compliance report
  - `base.html` - Base template with common styling

### 3. Scheduled Email Tasks
- **Location**: `com.internship.tool.service.ScheduledEmailService`
- **Scheduled Jobs**:
  - **Daily Reminders** (9:00 AM) - Summary of user's violations
  - **Deadline Alerts** (10:00 AM) - Violations with upcoming deadlines
  - **Weekly Reports** (Monday 8:00 AM) - Weekly compliance summary
  - **Critical Alerts** (Every 2 hours) - Critical severity violations

### 4. Email Service
- **Location**: `com.internship.tool.service.EmailService`
- **Methods**:
  - `sendSimpleEmail()` - Send plain text emails
  - `sendHtmlEmail()` - Send HTML emails using templates
  - `sendDailyReminderEmail()` - Send daily reminder
  - `sendDeadlineAlertEmail()` - Send deadline alert
  - `sendViolationReportEmail()` - Send weekly report

## Configuration

### Email SMTP Settings (application.properties)
```properties
# Email Configuration
spring.mail.host=smtp.gmail.com
spring.mail.port=587
spring.mail.username=your-email@gmail.com
spring.mail.password=your-app-password
spring.mail.from-name=Regulatory Fine Estimator
```

### Scheduled Tasks Configuration
```properties
# Cron expressions for scheduled tasks
scheduled.email.daily-reminder-cron=0 9 * * *        # 9:00 AM daily
scheduled.email.deadline-alert-cron=0 10 * * *       # 10:00 AM daily
scheduled.email.weekly-report-cron=0 8 * * 1         # Monday 8:00 AM
scheduled.email.critical-alert-cron=0 */2 * * *      # Every 2 hours
```

### Cron Expression Format
```
┌───────────── second (0-59)
│ ┌───────────── minute (0-59)
│ │ ┌───────────── hour (0-23)
│ │ │ ┌───────────── day of month (1-31)
│ │ │ │ ┌───────────── month (1-12)
│ │ │ │ │ ┌───────────── day of week (0-7)
│ │ │ │ │ │
0 9 * * *  - 9:00 AM every day
0 10 * * * - 10:00 AM every day
0 8 * * 1  - 8:00 AM on Monday
0 */2 * * * - Every 2 hours
```

## Email Setup - Gmail Example

### Step 1: Enable 2-Factor Authentication
1. Go to myaccount.google.com/security
2. Enable 2-Step Verification

### Step 2: Generate App Password
1. Go to myaccount.google.com/security
2. Look for "App passwords" (appears only if 2FA is enabled)
3. Select "Mail" and "Windows Computer"
4. Google will generate a 16-character password

### Step 3: Update application.properties
```properties
spring.mail.username=your-email@gmail.com
spring.mail.password=xxxx xxxx xxxx xxxx  # 16-character App Password
```

## Database Schema

### New Tables
- **email_notification_log**: Tracks all sent emails
- **Updated app_user**: Added `email` and `email_notifications_enabled` columns
- **Updated regulatory_violation**: Added `deadline`, `estimated_fine`, `created_date`, `email_sent` columns

### Email Notification Log Table
```sql
CREATE TABLE email_notification_log (
    id BIGSERIAL PRIMARY KEY,
    recipient_email VARCHAR(255) NOT NULL,
    subject VARCHAR(255) NOT NULL,
    template_name VARCHAR(100) NOT NULL,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50),
    error_message TEXT,
    violation_id BIGINT REFERENCES regulatory_violation(id)
);
```

## REST API Endpoints

### 1. Send Test Email
**Endpoint**: `POST /api/email/test`
```json
{
    "email": "user@example.com"
}
```
**Response**:
```json
{
    "message": "Test email sent successfully to user@example.com",
    "status": "success"
}
```

### 2. Send Custom Email
**Endpoint**: `POST /api/email/send-custom`
```json
{
    "to": "user@example.com",
    "subject": "Test Subject",
    "templateName": "daily-reminder",
    "variables": {
        "userName": "John Doe",
        "violationCount": 5
    },
    "isHtml": true
}
```

### 3. Get Email Preferences
**Endpoint**: `GET /api/email/preferences/{userId}`
**Response**:
```json
{
    "userId": 1,
    "email": "user@example.com",
    "emailNotificationsEnabled": true
}
```

### 4. Update Email Preferences
**Endpoint**: `PUT /api/email/preferences/{userId}`
```json
{
    "enableNotifications": true
}
```

### 5. Update User Email
**Endpoint**: `PUT /api/email/update-email/{userId}`
```json
{
    "email": "newemail@example.com"
}
```

### 6. Email Service Health Check
**Endpoint**: `GET /api/email/health`
**Response**:
```json
{
    "status": "healthy",
    "message": "Email service is running",
    "timestamp": "2026-05-04T12:00:00"
}
```

## Entities

### User Entity Updates
- `email`: User's email address (unique, not null)
- `emailNotificationsEnabled`: Boolean flag for email preferences

### RegulatoryViolation Entity Updates
- `deadline`: Deadline for addressing violation
- `estimatedFine`: Estimated fine amount
- `createdDate`: When violation was created
- `emailSent`: Flag to track if deadline alert was sent

### EmailNotificationLog Entity
- Tracks all sent emails
- Records success/failure status
- Links to regulatory violations

## Email Template Variables

### Daily Reminder Template
- `userName`: User's name
- `violationCount`: Number of active violations

### Deadline Alert Template
- `userName`: User's name
- `violationTitle`: Title of violation
- `deadline`: Deadline date and time
- `severity`: Severity level (Low, Medium, High, Critical)
- `estimatedFine`: Estimated fine amount
- `daysUntilDeadline`: Days remaining

### Violation Report Template
- `userName`: User's name
- `reportData`: HTML table with violations

## Service Classes

### MailConfig
Configures JavaMailSender with SMTP properties.

### ThymeleafConfig
Configures Thymeleaf template engine for email templates.

### EmailService
Main service for sending emails:
- Supports both plain text and HTML emails
- Uses Thymeleaf for template processing
- Error handling and logging

### ScheduledEmailService
Handles scheduled email tasks:
- Daily reminders for active violations
- Deadline alerts for upcoming deadlines
- Weekly compliance reports
- Critical violation alerts

## Testing

### Test Email Configuration
1. Use the `/api/email/test` endpoint to verify SMTP configuration
2. Check application logs for any connection errors
3. Verify email is received in test recipient's inbox

### Debugging
Enable mail debug logging in application.properties:
```properties
spring.mail.properties.mail.debug=true
```

## Troubleshooting

### Common Issues

**1. Gmail Connection Issues**
- Ensure 2-Factor Authentication is enabled
- Generate App Password (not regular password)
- Ensure app password is set in application.properties

**2. Scheduled Tasks Not Running**
- Verify `@EnableScheduling` is on ToolApplication class
- Check `spring.task.scheduling.pool.size` is > 0
- Verify cron expressions in application.properties

**3. Template Not Found**
- Ensure templates are in `src/main/resources/templates/emails/`
- Check template names match in application code
- Verify Thymeleaf configuration

**4. Database Migration Failures**
- Run `mvn flyway:info` to check migration status
- Check database user has necessary permissions
- Verify PostgreSQL server is running

## Future Enhancements

1. **Email Queue System**: Implement asynchronous email sending with retry logic
2. **Email Templates Management UI**: Admin interface to customize templates
3. **Batch Email Processing**: Optimize large-scale email sending
4. **Email Delivery Tracking**: Track opens, clicks, and bounces
5. **SMS Notifications**: Add SMS as alternative notification channel
6. **Email Unsubscribe**: Add unsubscribe links and management
7. **Template Versioning**: Support multiple template versions

## Maven Dependencies

```xml
<!-- Spring Mail -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-mail</artifactId>
</dependency>

<!-- Thymeleaf -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-thymeleaf</artifactId>
</dependency>
```

## Support

For issues or questions:
1. Check application logs
2. Review email template files
3. Verify SMTP configuration
4. Test with `/api/email/test` endpoint
5. Check email notification log table for error details

---
**Last Updated**: May 4, 2026
**Version**: 1.0
