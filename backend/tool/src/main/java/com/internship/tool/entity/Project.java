package com.internship.tool.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "project_data")
public class Project {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	@Column(nullable = false)
	private String title;

	private String description;

	private String status;

	public Long getId() { return id; }
	public void setId(Long id) { this.id = id; }
	public String getTitle() { return title; }
	public void setTitle(String title) { this.title = title; }
	public String getDescription() { return description; }
	public void setDescription(String description) { this.description = description; }
	public String getStatus() { return status; }
	public void setStatus(String status) { this.status = status; }
}