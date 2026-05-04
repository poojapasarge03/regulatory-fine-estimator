package com.internship.tool;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

import java.util.List;
import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;

import com.internship.tool.dto.RegulatoryViolationDto;
import com.internship.tool.dto.RegulatoryViolationResponse;
import com.internship.tool.entity.RegulatoryViolation;
import com.internship.tool.repository.RegulatoryViolationRepository;
import com.internship.tool.service.RegulatoryViolationServiceImpl;

@ExtendWith(MockitoExtension.class)
public class RegulatoryViolationServiceTest {

    @Mock
    private RegulatoryViolationRepository repository;

    @InjectMocks
    private RegulatoryViolationServiceImpl service;

    private RegulatoryViolation violation;
    private RegulatoryViolationDto dto;

    @BeforeEach
    void setUp() {
        violation = new RegulatoryViolation();
        violation.setId(1L);
        violation.setTitle("GDPR Violation");
        violation.setDescription("Data breach detected");
        violation.setStatus("OPEN");
        violation.setSeverity("HIGH");
        violation.setCreatedBy("admin");

        dto = new RegulatoryViolationDto();
        dto.setTitle("GDPR Violation");
        dto.setDescription("Data breach detected");
        dto.setStatus("OPEN");
        dto.setSeverity("HIGH");
        dto.setCreatedBy("admin");
    }

    @Test
    void createViolation_shouldReturnResponse() {
        when(repository.save(any(RegulatoryViolation.class))).thenReturn(violation);

        RegulatoryViolationResponse response = service.createViolation(dto);

        assertNotNull(response);
        assertEquals("GDPR Violation", response.getTitle());
        assertEquals("OPEN", response.getStatus());
        assertEquals("HIGH", response.getSeverity());
        verify(repository, times(1)).save(any(RegulatoryViolation.class));
    }

    @Test
    void getById_shouldReturnResponse_whenFound() {
        when(repository.findById(1L)).thenReturn(Optional.of(violation));

        RegulatoryViolationResponse response = service.getById(1L);

        assertNotNull(response);
        assertEquals(1L, response.getId());
        assertEquals("GDPR Violation", response.getTitle());
        verify(repository, times(1)).findById(1L);
    }

    @Test
    void getById_shouldThrowException_whenNotFound() {
        when(repository.findById(99L)).thenReturn(Optional.empty());

        RuntimeException ex = assertThrows(RuntimeException.class, () -> service.getById(99L));
        assertEquals("Violation not found", ex.getMessage());
        verify(repository, times(1)).findById(99L);
    }

    @Test
    void getAll_shouldReturnPage() {
        Pageable pageable = PageRequest.of(0, 10);
        Page<RegulatoryViolation> page = new PageImpl<>(List.of(violation));
        when(repository.findAll(pageable)).thenReturn(page);

        Page<RegulatoryViolation> result = service.getAll(pageable);

        assertNotNull(result);
        assertEquals(1, result.getTotalElements());
        verify(repository, times(1)).findAll(pageable);
    }

    @Test
    void updateViolation_shouldReturnUpdatedResponse() {
        when(repository.findById(1L)).thenReturn(Optional.of(violation));
        when(repository.save(any(RegulatoryViolation.class))).thenReturn(violation);

        dto.setTitle("Updated Title");
        dto.setStatus("CLOSED");
        RegulatoryViolationResponse response = service.updateViolation(1L, dto);

        assertNotNull(response);
        verify(repository, times(1)).findById(1L);
        verify(repository, times(1)).save(any(RegulatoryViolation.class));
    }

    @Test
    void updateViolation_shouldThrowException_whenNotFound() {
        when(repository.findById(99L)).thenReturn(Optional.empty());

        assertThrows(RuntimeException.class, () -> service.updateViolation(99L, dto));
        verify(repository, never()).save(any());
    }

    @Test
    void deleteViolation_shouldCallRepository() {
        doNothing().when(repository).deleteById(1L);

        service.deleteViolation(1L);

        verify(repository, times(1)).deleteById(1L);
    }

    @Test
    void getByStatus_shouldReturnList() {
        when(repository.findByStatus("OPEN")).thenReturn(List.of(violation));

        List<RegulatoryViolationResponse> result = service.getByStatus("OPEN");

        assertNotNull(result);
        assertEquals(1, result.size());
        assertEquals("OPEN", result.get(0).getStatus());
        verify(repository, times(1)).findByStatus("OPEN");
    }

    @Test
    void search_shouldReturnMatchingResults() {
        when(repository.searchByKeyword("GDPR")).thenReturn(List.of(violation));

        List<RegulatoryViolationResponse> result = service.search("GDPR");

        assertNotNull(result);
        assertEquals(1, result.size());
        assertEquals("GDPR Violation", result.get(0).getTitle());
        verify(repository, times(1)).searchByKeyword("GDPR");
    }
}
