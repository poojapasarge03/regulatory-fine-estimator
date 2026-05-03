package com.internship.tool.service;

import java.util.List;

import com.internship.tool.dto.RegulatoryViolationDto;
import com.internship.tool.dto.RegulatoryViolationResponse;

public interface RegulatoryViolationService {

    RegulatoryViolationResponse createViolation(RegulatoryViolationDto dto);

    RegulatoryViolationResponse getById(Long id);

    List<RegulatoryViolationResponse> getAll();

    RegulatoryViolationResponse updateViolation(Long id, RegulatoryViolationDto dto);

    void deleteViolation(Long id);

    List<RegulatoryViolationResponse> getByStatus(String status);

    List<RegulatoryViolationResponse> search(String keyword);
}
