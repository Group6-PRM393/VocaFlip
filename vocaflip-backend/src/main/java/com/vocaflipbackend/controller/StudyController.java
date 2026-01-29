package com.vocaflipbackend.controller;

import com.vocaflipbackend.dto.response.StudySessionResponse;
import com.vocaflipbackend.service.StudyService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/study")
@RequiredArgsConstructor
public class StudyController {

    private final StudyService studyService;

    @PostMapping("/start")
    public ResponseEntity<StudySessionResponse> startSession(@RequestParam String userId, @RequestParam String deckId) {
        return ResponseEntity.ok(studyService.startSession(userId, deckId));
    }

    @PostMapping("/{sessionId}/submit")
    public ResponseEntity<Void> submitResult(@PathVariable String sessionId, 
                                             @RequestParam String cardId,
                                             @RequestParam boolean isRemembered,
                                             @RequestParam int responseTimeSeconds) {
        studyService.submitCardResult(sessionId, cardId, isRemembered, responseTimeSeconds);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/{sessionId}/complete")
    public ResponseEntity<StudySessionResponse> completeSession(@PathVariable String sessionId) {
        return ResponseEntity.ok(studyService.completeSession(sessionId));
    }
}
