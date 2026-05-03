package com.internship.tool.entity;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "regulatory_violation")
@Data
public class RegulatoryViolation {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String title;

    @Column(columnDefinition = "TEXT")
    private String description;

    private String status;

    private String severity;

    private String createdBy;
}
