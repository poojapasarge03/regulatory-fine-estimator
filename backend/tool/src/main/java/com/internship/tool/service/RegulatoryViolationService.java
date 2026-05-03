package com.internship.tool.service;

import java.util.List;

import org.springframework.data.domain.Page;

import com.internship.tool.dto.RegulatoryViolationDto;
import com.internship.tool.dto.RegulatoryViolationResponse;

public interface RegulatoryViolationService {

    RegulatoryViolationResponse createViolation(RegulatoryViolationDto dto);

    RegulatoryViolationResponse getById(Long id);

    Page<RegulatoryViolationResponse> getAll(int page, int size);

    RegulatoryViolationResponse updateViolation(Long id, RegulatoryViolationDto dto);

    void deleteViolation(Long id);

    List<RegulatoryViolationResponse> getByStatus(String status);

    List<RegulatoryViolationResponse> search(String keyword);
}
