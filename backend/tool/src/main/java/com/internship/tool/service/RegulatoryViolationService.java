package com.internship.tool.service;

import java.util.List;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import com.internship.tool.dto.RegulatoryViolationDto;
import com.internship.tool.dto.RegulatoryViolationResponse;
import com.internship.tool.entity.RegulatoryViolation;

public interface RegulatoryViolationService {

    RegulatoryViolationResponse createViolation(RegulatoryViolationDto dto);

    RegulatoryViolationResponse getById(Long id);

    Page<RegulatoryViolation> getAll(Pageable pageable);

    RegulatoryViolationResponse updateViolation(Long id, RegulatoryViolationDto dto);

    void deleteViolation(Long id);

    List<RegulatoryViolationResponse> getByStatus(String status);

    List<RegulatoryViolationResponse> search(String keyword);
}
