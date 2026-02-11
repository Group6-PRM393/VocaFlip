package com.vocaflipbackend.service.impl;

import com.vocaflipbackend.constants.CloudinaryConstants;
import com.vocaflipbackend.dto.request.DeckRequest;
import com.vocaflipbackend.dto.response.DeckResponse;
import com.vocaflipbackend.dto.response.PageResponse;
import com.vocaflipbackend.entity.Category;
import com.vocaflipbackend.entity.Deck;
import com.vocaflipbackend.entity.User;
import com.vocaflipbackend.exception.AppException;
import com.vocaflipbackend.exception.ErrorCode;
import com.vocaflipbackend.mapper.DeckMapper;
import com.vocaflipbackend.repository.CategoryRepository;
import com.vocaflipbackend.repository.DeckRepository;
import com.vocaflipbackend.repository.UserRepository;
import com.vocaflipbackend.service.CloudinaryService;
import com.vocaflipbackend.service.DeckService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class DeckServiceImpl implements DeckService {

    private final DeckRepository deckRepository;
    private final UserRepository userRepository;
    private final CategoryRepository categoryRepository;
    private final DeckMapper deckMapper;
    private final CloudinaryService cloudinaryService;


    @Override
    public DeckResponse createDeck(DeckRequest request, String userId, MultipartFile coverImage) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new AppException(ErrorCode.USER_NOT_FOUND));
        Deck deck = deckMapper.toEntity(request);
        deck.setUser(user);

        if (request.getCategory() != null) {
            Category category = categoryRepository.findById(request.getCategory())
                    .orElseThrow(() -> new AppException(ErrorCode.CATEGORY_NOT_FOUND));
            deck.setCategory(category);
        } else {
            throw new AppException(ErrorCode.CATEGORY_REQUIRED);
        }

        // Upload cover image lên Cloudinary nếu có
        if (coverImage != null && !coverImage.isEmpty()) {
            String coverUrl = uploadCoverImage(coverImage);
            deck.setCoverImageUrl(coverUrl);
        }

        Deck savedDeck = deckRepository.save(deck);
        return deckMapper.toResponse(savedDeck);
    }

    @Override
    public DeckResponse getDeckById(String id) {
        return deckRepository.findById(id)
                .filter(deck -> !deck.isRemoved())
                .map(deckMapper::toResponse)
                .orElseThrow(() -> new AppException(ErrorCode.DECK_NOT_FOUND));
    }


    @Override
    public DeckResponse updateDeck(String id, DeckRequest request, MultipartFile coverImage) {
        Deck deck = deckRepository.findById(id)
                .filter(d -> !d.isRemoved())
                .orElseThrow(() -> new AppException(ErrorCode.DECK_NOT_FOUND));

        if (request.getTitle() != null && !request.getTitle().isBlank()) {
            deck.setTitle(request.getTitle());
        }

        deck.setDescription(request.getDescription());

        if (request.getCategory() != null) {
            Category category = categoryRepository.findById(request.getCategory())
                    .orElseThrow(() -> new AppException(ErrorCode.CATEGORY_NOT_FOUND));
            deck.setCategory(category);
        }

        // Upload cover image mới nếu có
        if (coverImage != null && !coverImage.isEmpty()) {
            String coverUrl = uploadCoverImage(coverImage);
            deck.setCoverImageUrl(coverUrl);
        }

        Deck updatedDeck = deckRepository.save(deck);
        return deckMapper.toResponse(updatedDeck);
    }

    @Override
    public List<DeckResponse> getDecksByUserId(String userId) {
        if (!userRepository.existsById(userId)) {
            throw new AppException(ErrorCode.USER_NOT_FOUND);
        }
        return deckRepository.findByUserIdAndIsRemovedFalse(userId).stream()
                .map(deckMapper::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    public void deleteDeck(String id) {
        Deck deck = deckRepository.findById(id)
                .orElseThrow(() -> new AppException(ErrorCode.DECK_NOT_FOUND));
        deck.setRemoved(true);
        deckRepository.save(deck);
    }

    @Override
    public PageResponse<DeckResponse> searchDecks(String keyword, int page, int pageSize) {
        Pageable pageable = PageRequest.of(page, pageSize, Sort.by(Sort.Direction.DESC, "createdAt"));

        Page<Deck> deckPage;

        if (keyword == null || keyword.trim().isEmpty()) {
            deckPage = deckRepository.findByIsRemovedFalse(pageable);
        } else {
            deckPage = deckRepository.searchDecks(keyword.trim(), pageable);
        }

        List<DeckResponse> content = deckPage.getContent().stream()
                .map(deckMapper::toResponse)
                .collect(Collectors.toList());

        return PageResponse.<DeckResponse>builder()
                .content(content)
                .page(deckPage.getNumber())
                .pageSize(deckPage.getSize())
                .totalElements(deckPage.getTotalElements())
                .totalPages(deckPage.getTotalPages())
                .first(deckPage.isFirst())
                .last(deckPage.isLast())
                .build();
    }

    // Helper method để upload cover image
    private String uploadCoverImage(MultipartFile coverImage) {
        Map<String, Object> uploadResult = cloudinaryService.uploadImage(
                coverImage,
                CloudinaryConstants.DECK_COVER_FOLDER,
                CloudinaryConstants.COVER_WIDTH,
                CloudinaryConstants.COVER_HEIGHT);
        return (String) uploadResult.get("secure_url");
    }
}



