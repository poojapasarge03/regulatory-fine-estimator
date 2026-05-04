package com.internship.tool.dto;

public class RegulatoryViolationResponse {
    private Long id;
    private String title;
    private String description;
    private String status;
    private String severity;
    private String createdBy;

    public RegulatoryViolationResponse() {}

    public RegulatoryViolationResponse(Long id, String title, String description, String status, String severity, String createdBy) {
        this.id = id;
        this.title = title;
        this.description = description;
        this.status = status;
        this.severity = severity;
        this.createdBy = createdBy;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
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

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private Long id;
        private String title;
        private String description;
        private String status;
        private String severity;
        private String createdBy;

        public Builder id(Long id) { this.id = id; return this; }
        public Builder title(String title) { this.title = title; return this; }
        public Builder description(String description) { this.description = description; return this; }
        public Builder status(String status) { this.status = status; return this; }
        public Builder severity(String severity) { this.severity = severity; return this; }
        public Builder createdBy(String createdBy) { this.createdBy = createdBy; return this; }
        public RegulatoryViolationResponse build() {
            return new RegulatoryViolationResponse(id, title, description, status, severity, createdBy);
        }
    }
}
