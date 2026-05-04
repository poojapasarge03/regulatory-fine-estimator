package com.internship.tool.controller;

import java.util.List;

import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.internship.tool.dto.RegulatoryViolationDto;
import com.internship.tool.dto.RegulatoryViolationResponse;
import com.internship.tool.entity.RegulatoryViolation;
import com.internship.tool.repository.RegulatoryViolationRepository;
import com.internship.tool.service.RegulatoryViolationService;

import jakarta.validation.Valid;

/**
 * Legacy API Controller - Alternative endpoint at /violations
 * ✅ Same functionality as /api/violations but WITHOUT RBAC (for easier testing)
 * ✅ Works directly with entities
 * ✅ No authentication required
 */
@RestController
@RequestMapping("/violations")
public class RegulatoryViolationLegacyController {

    private final RegulatoryViolationService service;
    private final RegulatoryViolationRepository repository;

    public RegulatoryViolationLegacyController(RegulatoryViolationService service, 
                                               RegulatoryViolationRepository repository) {
        this.service = service;
        this.repository = repository;
    }

    // ✅ GET ALL (with pagination)
    @GetMapping
    public ResponseEntity<List<RegulatoryViolation>> getAll(Pageable pageable) {
        return ResponseEntity.ok(repository.findAll(pageable).getContent());
    }

    // ✅ GET BY ID - THIS FIXES YOUR 404 ISSUE
    @GetMapping("/{id}")
    public ResponseEntity<RegulatoryViolationResponse> getById(@PathVariable Long id) {
        return ResponseEntity.ok(service.getById(id));
    }

    // ✅ CREATE
    @PostMapping
    public ResponseEntity<RegulatoryViolationResponse> create(@Valid @RequestBody RegulatoryViolationDto dto) {
        RegulatoryViolationResponse resp = service.createViolation(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(resp);
    }

    // ✅ UPDATE
    @PutMapping("/{id}")
    public ResponseEntity<RegulatoryViolationResponse> update(@PathVariable Long id,
                                              @Valid @RequestBody RegulatoryViolationDto dto) {
        return ResponseEntity.ok(service.updateViolation(id, dto));
    }

    // ✅ DELETE
    @DeleteMapping("/{id}")
    public ResponseEntity<String> delete(@PathVariable Long id) {
        service.deleteViolation(id);
        return ResponseEntity.ok("Violation deleted successfully");
    }

    // ✅ SEARCH
    @GetMapping("/search")
    public ResponseEntity<List<RegulatoryViolationResponse>> search(@RequestParam String keyword) {
        return ResponseEntity.ok(service.search(keyword));
    }

    // ✅ GET BY STATUS
    @GetMapping("/status/{status}")
    public ResponseEntity<List<RegulatoryViolationResponse>> getByStatus(@PathVariable String status) {
        return ResponseEntity.ok(service.getByStatus(status));
    }
}
