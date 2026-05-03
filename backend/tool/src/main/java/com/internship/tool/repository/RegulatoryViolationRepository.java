package com.internship.tool.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.internship.tool.entity.RegulatoryViolation;

@Repository
public interface RegulatoryViolationRepository extends JpaRepository<RegulatoryViolation, Long> {

    List<RegulatoryViolation> findByStatus(String status);

    @Query("SELECT v FROM RegulatoryViolation v WHERE LOWER(v.title) LIKE LOWER(CONCAT('%', :keyword, '%')) OR LOWER(v.description) LIKE LOWER(CONCAT('%', :keyword, '%'))")
    List<RegulatoryViolation> searchByKeyword(@Param("keyword") String keyword);
}
