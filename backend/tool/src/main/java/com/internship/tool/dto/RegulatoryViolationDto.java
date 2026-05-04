package com.internship.tool.dto;

import jakarta.validation.constraints.NotBlank;

public class RegulatoryViolationDto {
    @NotBlank(message = "title is required")
    private String title;

    @NotBlank(message = "description is required")
    private String description;

    private String status;
    private String severity;
    private String createdBy;

    public RegulatoryViolationDto() {}

    public RegulatoryViolationDto(String title, String description, String status, String severity, String createdBy) {
        this.title = title;
        this.description = description;
        this.status = status;
        this.severity = severity;
        this.createdBy = createdBy;
    }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getSeverity() { return severity; }
    public void setSeverity(String severity) { this.severity = severity; }
    public String getCreatedBy() { return createdBy; }
    public void setCreatedBy(String createdBy) { this.createdBy = createdBy; }
}
