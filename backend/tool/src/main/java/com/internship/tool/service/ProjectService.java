package com.internship.tool.service;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;

import com.internship.tool.entity.Project;
import com.internship.tool.repository.ProjectRepository;

@Service
public class ProjectService {

	@Autowired
	private ProjectRepository projectRepository;

	@Cacheable(value = "projects", key = "'all'")
	public List<Project> getAllProjects() {
		return projectRepository.findAll();
	}

	@Cacheable(value = "projects", key = "#id")
	public Project getProjectById(Long id) {
		return projectRepository.findById(id)
				.orElseThrow(() -> new RuntimeException("Project not found"));
	}

	@CacheEvict(value = "projects", allEntries = true)
	public Project createProject(Project project) {
		return projectRepository.save(project);
	}

	@CacheEvict(value = "projects", allEntries = true)
	public Project updateProject(Long id, Project project) {
		Project existing = projectRepository.findById(id)
				.orElseThrow(() -> new RuntimeException("Project not found"));
		existing.setName(project.getName());
		existing.setDescription(project.getDescription());
		return projectRepository.save(existing);
	}

	@CacheEvict(value = "projects", allEntries = true)
	public void deleteProject(Long id) {
		projectRepository.deleteById(id);
	}
}