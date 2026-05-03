package com.internship.tool.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.internship.tool.entity.Project;

@Repository
public interface ProjectRepository extends JpaRepository<Project, Long> {

	List<Project> findByTitleContainingIgnoreCase(String keyword);

}