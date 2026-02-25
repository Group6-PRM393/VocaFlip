import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/responses/study_card_response.dart';
import '../../data/models/responses/study_session_response.dart';
import '../../data/repositories/study_repository.dart';
import '../../data/services/api_service.dart';

enum StudyStatus {
  initial,
  loading,
  studying,
  submitting,
  completing,
  completed,
  error,
}

class StudyNotifier extends ChangeNotifier {
  final StudyRepository _repository;

  StudyStatus _status = StudyStatus.initial;
  StudySessionResponse? _session;
  List<StudyCardResponse> _cards = [];
  int _currentIndex = 0;
  bool _isFlipped = false;
  int _forgotCount = 0;
  int _rememberedCount = 0;
  String? _errorMessage;

  DateTime? _cardStartTime;

  StudyNotifier(SharedPreferences prefs)
    : _repository = StudyRepository(ApiService(prefs));

  StudyStatus get status => _status;
  StudySessionResponse? get session => _session;
  List<StudyCardResponse> get cards => _cards;
  int get currentIndex => _currentIndex;
  bool get isFlipped => _isFlipped;
  int get forgotCount => _forgotCount;
  int get rememberedCount => _rememberedCount;
  String? get errorMessage => _errorMessage;

  StudyCardResponse? get currentCard =>
      _cards.isNotEmpty && _currentIndex < _cards.length
      ? _cards[_currentIndex]
      : null;

  int get totalCards => _cards.length;

  double get progress =>
      totalCards > 0 ? (_currentIndex + 1) / totalCards : 0.0;

  double get accuracy {
    final total = _forgotCount + _rememberedCount;
    return total > 0 ? (_rememberedCount / total) * 100 : 0.0;
  }

  Future<void> startSession(String deckId) async {
    _status = StudyStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _session = await _repository.startSession(deckId);
      _cards = _session!.cards;
      _currentIndex = 0;
      _isFlipped = false;
      _forgotCount = 0;
      _rememberedCount = 0;
      _cardStartTime = DateTime.now();

      _status = _cards.isNotEmpty
          ? StudyStatus.studying
          : StudyStatus.completed;
    } catch (e) {
      _status = StudyStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  /// Nap du lieu session da duoc tao san (VD: tu daily-review API).
  /// Khong goi them API, chi set state tu du lieu co san.
  void loadFromResponse(StudySessionResponse sessionResponse) {
    _session = sessionResponse;
    _cards = sessionResponse.cards;
    _currentIndex = 0;
    _isFlipped = false;
    _forgotCount = 0;
    _rememberedCount = 0;
    _cardStartTime = DateTime.now();

    _status = _cards.isNotEmpty ? StudyStatus.studying : StudyStatus.completed;
    notifyListeners();
  }

  /// lat the
  void flipCard() {
    _isFlipped = true;
    notifyListeners();
  }

  /// lat the tro lai
  void onCardFlip(bool isFront) {
    _isFlipped = !isFront;
    notifyListeners();
  }

  /// 0=Forgot, 1=Hard, 2=Good, 3=Easy
  Future<void> submitRating(int grade) async {
    if (currentCard == null || _session == null) return;

    // thoi gian phan hoi
    final responseTime = _cardStartTime != null
        ? DateTime.now().difference(_cardStartTime!).inSeconds
        : 5; // fallback 5 giay

    if (grade == 0) {
      _forgotCount++;
    } else {
      _rememberedCount++;
    }

    _status = StudyStatus.submitting;
    notifyListeners();

    try {
      await _repository.submitCardResult(
        sessionId: _session!.id,
        cardId: currentCard!.cardId,
        grade: grade,
        responseTimeSeconds: responseTime,
      );
    } catch (e) {
      debugPrint('Submit card result error: $e');
    }

    // kiem tra het the chua
    if (_currentIndex >= _cards.length - 1) {
      await _completeSession();
      return;
    }

    // chuyen sang the tiep theo
    _currentIndex++;
    _isFlipped = false;
    _cardStartTime = DateTime.now();
    _status = StudyStatus.studying;
    notifyListeners();
  }

  Future<void> _completeSession() async {
    _status = StudyStatus.completing;
    notifyListeners();

    try {
      final result = await _repository.completeSession(_session!.id);
      _session = result;
      _status = StudyStatus.completed;
    } catch (e) {
      debugPrint('Complete session error: $e');
      _status = StudyStatus.completed;
    }
    notifyListeners();
  }

  // hoc lai
  void reset() {
    _currentIndex = 0;
    _isFlipped = false;
    _forgotCount = 0;
    _rememberedCount = 0;
    _cardStartTime = DateTime.now();
    _status = _cards.isNotEmpty ? StudyStatus.studying : StudyStatus.initial;
    notifyListeners();
  }

  // thoat study session dot ngot
  Future<void> forceCompleteSession() async {
    if (_session == null) return;
    try {
      await _repository.completeSession(_session!.id);
    } catch (e) {
      debugPrint('Force complete session error: $e');
    }
  }
}
