package com.vocaflipbackend.controller;

import com.vocaflipbackend.dto.response.UserProgressResponse;
import com.vocaflipbackend.enums.LearningStatus;
import com.vocaflipbackend.service.ProgressService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/progress")
@RequiredArgsConstructor
public class ProgressController {

    private final ProgressService progressService;

    @PostMapping("/update")
    public ResponseEntity<Void> updateProgress(@RequestParam String userId,
                                               @RequestParam String cardId,
                                               @RequestParam LearningStatus status) {
        progressService.updateProgress(userId, cardId, status);
        return ResponseEntity.ok().build();
    }

    @GetMapping
    public ResponseEntity<UserProgressResponse> getProgress(@RequestParam String userId,
                                                            @RequestParam String cardId) {
        return progressService.getProgress(userId, cardId)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
}
