package com.internship.tool.controller;

import java.util.List;

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

@RestController
@RequestMapping("/api/violations")
public class RegulatoryViolationController {

    private final RegulatoryViolationService service;

    public RegulatoryViolationController(RegulatoryViolationService service) {
        this.service = service;
    }

    @PostMapping
    public RegulatoryViolationResponse create(@RequestBody RegulatoryViolationDto dto) {
        return service.createViolation(dto);
    }

    @GetMapping("/{id}")
    public RegulatoryViolationResponse getById(@PathVariable Long id) {
        return service.getById(id);
    }

    @GetMapping
    public List<RegulatoryViolationResponse> getAll() {
        return service.getAll();
    }

    @PutMapping("/{id}")
    public RegulatoryViolationResponse update(@PathVariable Long id,
                                              @RequestBody RegulatoryViolationDto dto) {
        return service.updateViolation(id, dto);
    }

    @DeleteMapping("/{id}")
    public void delete(@PathVariable Long id) {
        service.deleteViolation(id);
    }

    @GetMapping("/status/{status}")
    public List<RegulatoryViolationResponse> getByStatus(@PathVariable String status) {
        return service.getByStatus(status);
    }

    @GetMapping("/search")
    public List<RegulatoryViolationResponse> search(@RequestParam String keyword) {
        return service.search(keyword);
    }
}
