package com.internship.tool.controller;

import java.util.List;

import org.springframework.data.domain.Page;
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
import com.internship.tool.service.RegulatoryViolationService;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/violations")
public class RegulatoryViolationController {

    private final RegulatoryViolationService service;

    public RegulatoryViolationController(RegulatoryViolationService service) {
        this.service = service;
    }

    @PostMapping
    public ResponseEntity<RegulatoryViolationResponse> create(@Valid @RequestBody RegulatoryViolationDto dto) {
        RegulatoryViolationResponse resp = service.createViolation(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(resp);
    }

    @GetMapping("/{id}")
    public ResponseEntity<RegulatoryViolationResponse> getById(@PathVariable Long id) {
        return ResponseEntity.ok(service.getById(id));
    }

    @GetMapping
    public ResponseEntity<Page<RegulatoryViolationResponse>> getAll(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        return ResponseEntity.ok(service.getAll(page, size));
    }

    @PutMapping("/{id}")
    public ResponseEntity<RegulatoryViolationResponse> update(@PathVariable Long id,
                                              @Valid @RequestBody RegulatoryViolationDto dto) {
        return ResponseEntity.ok(service.updateViolation(id, dto));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        service.deleteViolation(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/status/{status}")
    public ResponseEntity<List<RegulatoryViolationResponse>> getByStatus(@PathVariable String status) {
        return ResponseEntity.ok(service.getByStatus(status));
    }

    @GetMapping("/search")
    public ResponseEntity<List<RegulatoryViolationResponse>> search(@RequestParam String keyword) {
        return ResponseEntity.ok(service.search(keyword));
    }
}
