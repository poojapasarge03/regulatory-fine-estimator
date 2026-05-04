# Quick Setup Guide - Email Notifications

## 5-Minute Setup

### Step 1: Gmail Setup (if using Gmail)
```
1. Go to myaccount.google.com/security
2. Enable 2-Step Verification
3. Go to App passwords section
4. Select "Mail" and "Windows Computer"
5. Copy the 16-character password
```

### Step 2: Update application.properties
```properties
spring.mail.host=smtp.gmail.com
spring.mail.port=587
spring.mail.username=your-email@gmail.com
spring.mail.password=xxxx xxxx xxxx xxxx
spring.mail.from-name=Regulatory Fine Estimator
```

### Step 3: Build and Run
```bash
cd backend/tool
mvn clean install
mvn spring-boot:run
```

### Step 4: Test Email
```bash
curl -X POST http://localhost:8080/api/email/test \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com"}'
```

## What's Included

### Email Services
- ✅ Email configuration (MailConfig.java)
- ✅ Thymeleaf template engine (ThymeleafConfig.java)
- ✅ Email sending service (EmailService.java)
- ✅ Scheduled tasks (ScheduledEmailService.java)

### Email Templates
- ✅ Daily Reminder (daily-reminder.html)
- ✅ Deadline Alert (deadline-alert.html)
- ✅ Violation Report (violation-report.html)
- ✅ Base Template (base.html)

### REST API Endpoints
```
POST   /api/email/test                    - Test email
POST   /api/email/send-custom             - Send custom email
GET    /api/email/preferences/{userId}    - Get preferences
PUT    /api/email/preferences/{userId}    - Update preferences
PUT    /api/email/update-email/{userId}   - Update email
GET    /api/email/health                  - Health check
```

### Scheduled Tasks
- Daily Reminders: 9:00 AM
- Deadline Alerts: 10:00 AM
- Weekly Reports: Monday 8:00 AM
- Critical Alerts: Every 2 hours

## For Different Email Providers

### Outlook/Office 365
```properties
spring.mail.host=smtp.office365.com
spring.mail.port=587
spring.mail.username=your-email@outlook.com
spring.mail.password=your-password
```

### Custom SMTP Server
```properties
spring.mail.host=your-smtp-server.com
spring.mail.port=587
spring.mail.username=your-username
spring.mail.password=your-password
```

## Database Migrations
Flyway automatically runs migrations:
- V3__add_email_notifications.sql - Adds email support to database

## Troubleshooting

**Email not sending?**
1. Check SMTP credentials
2. Verify firewall allows port 587
3. Check application logs for errors
4. Test with `/api/email/test` endpoint

**Scheduled tasks not running?**
1. Verify `@EnableScheduling` on ToolApplication
2. Check `spring.task.scheduling.pool.size > 0`
3. Check logs for task execution

**Templates not found?**
1. Ensure templates in `src/main/resources/templates/emails/`
2. Verify template names match in code
3. Check Thymeleaf configuration

## File Locations

```
Email Configuration:
  - config/MailConfig.java
  - config/ThymeleafConfig.java

Services:
  - service/EmailService.java
  - service/ScheduledEmailService.java

Controllers:
  - controller/EmailNotificationController.java

Entities:
  - entity/User.java (updated)
  - entity/RegulatoryViolation.java (updated)
  - entity/EmailNotificationLog.java

Templates:
  - resources/templates/emails/daily-reminder.html
  - resources/templates/emails/deadline-alert.html
  - resources/templates/emails/violation-report.html
  - resources/templates/emails/base.html

Configuration:
  - resources/application.properties

Documentation:
  - EMAIL_NOTIFICATIONS_GUIDE.md
  - IMPLEMENTATION_SUMMARY.md
```

## Email Template Variables

### Daily Reminder
```
${userName}           - User's name
${violationCount}     - Number of violations
```

### Deadline Alert
```
${userName}           - User's name
${violationTitle}     - Violation title
${deadline}           - Deadline date/time
${severity}           - Severity level
${estimatedFine}      - Fine amount
${daysUntilDeadline}  - Days remaining
```

### Weekly Report
```
${userName}           - User's name
${reportData}         - HTML table with violations
```

## Performance Tips

1. **Email Queue**: Consider async sending for large volumes
2. **Template Caching**: Enabled by default (cache=true)
3. **Connection Pooling**: Configured in MailConfig
4. **Scheduled Tasks**: Staggered execution times to avoid conflicts

## Security Notes

- Never commit credentials to git
- Use environment variables for passwords
- Enable email preference options for users
- Log all email sending for audit trail
- Validate email addresses before sending

## Support

Refer to:
- EMAIL_NOTIFICATIONS_GUIDE.md - Detailed documentation
- IMPLEMENTATION_SUMMARY.md - Complete overview
- Application logs - For debugging
- email_notification_log table - For email history

---
**Status**: Ready to Deploy
**Last Updated**: May 4, 2026
