package com.internship.tool.entity;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "project_data")
@Data
public class Project {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	@Column(nullable = false)
	private String title;

	private String description;

	private String status;
}