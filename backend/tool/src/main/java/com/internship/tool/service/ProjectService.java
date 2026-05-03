package com.internship.tool.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.internship.tool.entity.Project;
import com.internship.tool.repository.ProjectRepository;

@Service
public class ProjectService {

	@Autowired
	private ProjectRepository projectRepository;

	public List<Project> getAllProjects() {
		return projectRepository.findAll();
	}

	public Project createProject(Project project) {
		return projectRepository.save(project);
	}
}