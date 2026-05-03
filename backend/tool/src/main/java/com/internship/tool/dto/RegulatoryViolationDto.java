package com.internship.tool.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class RegulatoryViolationDto {
    private String title;
    private String description;
    private String status;
    private String severity;
    private String createdBy;
}
