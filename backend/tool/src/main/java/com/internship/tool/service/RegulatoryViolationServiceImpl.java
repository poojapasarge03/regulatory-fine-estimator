package com.internship.tool.service;

import java.util.List;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import com.internship.tool.dto.RegulatoryViolationDto;
import com.internship.tool.dto.RegulatoryViolationResponse;
import com.internship.tool.entity.RegulatoryViolation;
import com.internship.tool.repository.RegulatoryViolationRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class RegulatoryViolationServiceImpl implements RegulatoryViolationService {

    private final RegulatoryViolationRepository repository;

    @Override
    public RegulatoryViolationResponse createViolation(RegulatoryViolationDto dto) {
        RegulatoryViolation entity = new RegulatoryViolation();
        entity.setTitle(dto.getTitle());
        entity.setDescription(dto.getDescription());
        entity.setStatus(dto.getStatus());
        entity.setSeverity(dto.getSeverity());
        entity.setCreatedBy(dto.getCreatedBy());

        return mapToResponse(repository.save(entity));
    }

    @Override
    public RegulatoryViolationResponse getById(Long id) {
        RegulatoryViolation entity = repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Violation not found"));
        return mapToResponse(entity);
    }

    @Override
    public Page<RegulatoryViolationResponse> getAll(int page, int size) {
        Pageable pageable = PageRequest.of(page, size);
        return repository.findAll(pageable)
                .map(this::mapToResponse);
    }

    @Override
    public RegulatoryViolationResponse updateViolation(Long id, RegulatoryViolationDto dto) {
        RegulatoryViolation entity = repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Violation not found"));

        entity.setTitle(dto.getTitle());
        entity.setDescription(dto.getDescription());
        entity.setStatus(dto.getStatus());
        entity.setSeverity(dto.getSeverity());

        return mapToResponse(repository.save(entity));
    }

    @Override
    public void deleteViolation(Long id) {
        repository.deleteById(id);
    }

    @Override
    public List<RegulatoryViolationResponse> getByStatus(String status) {
        return repository.findByStatus(status)
                .stream()
                .map(this::mapToResponse)
                .toList();
    }

    @Override
    public List<RegulatoryViolationResponse> search(String keyword) {
        return repository.searchByKeyword(keyword)
                .stream()
                .map(this::mapToResponse)
                .toList();
    }

    private RegulatoryViolationResponse mapToResponse(RegulatoryViolation entity) {
        return RegulatoryViolationResponse.builder()
                .id(entity.getId())
                .title(entity.getTitle())
                .description(entity.getDescription())
                .status(entity.getStatus())
                .severity(entity.getSeverity())
                .createdBy(entity.getCreatedBy())
                .build();
    }
}
