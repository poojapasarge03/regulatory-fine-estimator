package com.internship.tool.dto;

import java.util.Map;

public class EmailNotificationDto {
    private String to;
    private String subject;
    private String templateName;
    private Map<String, Object> variables;
    private Boolean isHtml;

    public EmailNotificationDto() {
        this.isHtml = true;
    }

    public EmailNotificationDto(String to, String subject, String templateName, Map<String, Object> variables) {
        this.to = to;
        this.subject = subject;
        this.templateName = templateName;
        this.variables = variables;
        this.isHtml = true;
    }

    public String getTo() {
        return to;
    }

    public void setTo(String to) {
        this.to = to;
    }

    public String getSubject() {
        return subject;
    }

    public void setSubject(String subject) {
        this.subject = subject;
    }

    public String getTemplateName() {
        return templateName;
    }

    public void setTemplateName(String templateName) {
        this.templateName = templateName;
    }

    public Map<String, Object> getVariables() {
        return variables;
    }

    public void setVariables(Map<String, Object> variables) {
        this.variables = variables;
    }

    public Boolean getIsHtml() {
        return isHtml;
    }

    public void setIsHtml(Boolean isHtml) {
        this.isHtml = isHtml;
    }
}
