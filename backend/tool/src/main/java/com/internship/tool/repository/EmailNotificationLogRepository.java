package com.internship.tool.repository;

import com.internship.tool.entity.EmailNotificationLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface EmailNotificationLogRepository extends JpaRepository<EmailNotificationLog, Long> {

    /**
     * Find all email logs for a specific recipient email
     */
    List<EmailNotificationLog> findByRecipientEmail(String recipientEmail);

    /**
     * Find all email logs sent after a specific date
     */
    List<EmailNotificationLog> findBySentAtAfter(LocalDateTime sentAt);

    /**
     * Find all email logs for a specific template
     */
    List<EmailNotificationLog> findByTemplateName(String templateName);

    /**
     * Find all email logs with a specific status
     */
    List<EmailNotificationLog> findByStatus(String status);

    /**
     * Count emails sent in a specific date range
     */
    @Query("SELECT COUNT(e) FROM EmailNotificationLog e WHERE e.sentAt BETWEEN :startDate AND :endDate")
    long countEmailsSentBetween(@Param("startDate") LocalDateTime startDate, 
                                @Param("endDate") LocalDateTime endDate);

    /**
     * Find failed email logs
     */
    List<EmailNotificationLog> findByStatusAndErrorMessageIsNotNull(String status);
}
