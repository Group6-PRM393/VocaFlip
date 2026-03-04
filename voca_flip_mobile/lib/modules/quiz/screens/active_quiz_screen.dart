import 'dart:async';

import 'package:flutter/material.dart';
import 'package:voca_flip_mobile/modules/quiz/models/quiz_session.dart';
import 'package:voca_flip_mobile/modules/quiz/services/quiz_service.dart';
import 'package:voca_flip_mobile/modules/quiz/screens/quiz_result_screen.dart';

class ActiveQuizScreen extends StatefulWidget {
  final String deckId;
  final int numberOfQuestions;
  final int timeLimitSeconds;
  final String questionType;

  const ActiveQuizScreen({
    super.key,
    required this.deckId,
    required this.numberOfQuestions,
    required this.timeLimitSeconds,
    required this.questionType,
  });

  @override
  State<ActiveQuizScreen> createState() => _ActiveQuizScreenState();
}

class _ActiveQuizScreenState extends State<ActiveQuizScreen> {
  final QuizService _quizService = QuizService();

  QuizSession? _quizSession;
  bool _isLoading = true;
  int _currentQuestionIndex = 0;
  int _secondsRemaining = 0;
  Timer? _timer;

  final Map<String, String> _userAnswers = {};

  @override
  void initState() {
    super.initState();
    _startQuiz();
  }

  void _startQuiz() async {
    try {
      final session = await _quizService.generateQuiz(
        widget.deckId,
        widget.numberOfQuestions,
        widget.timeLimitSeconds,
      );

      if (mounted) {
        setState(() {
          _quizSession = session;
          _isLoading = false;
          _secondsRemaining = widget.timeLimitSeconds.toInt();
        });
        _startTimer();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to start quiz: $e")));
        Navigator.pop(context);
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
        _submitQuiz();
      }
    });
  }

  void _submitQuiz() async {
    _timer?.cancel();
    setState(() => _isLoading = true);

    List<Map<String, String>> formattedAnswers = _userAnswers.entries
        .map(
          (entry) => {"questionId": entry.key, "selectedOptionId": entry.value},
        )
        .toList();

    try {
      final result = await _quizService.submitQuiz(
        _quizSession!.attempId,
        widget.timeLimitSeconds - _secondsRemaining,
        formattedAnswers,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => QuizResultScreen(
              quizResult: result,
              attemptId: _quizSession!.attempId,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to submit quiz: $e")));
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final question = _quizSession!.questions[_currentQuestionIndex];

    final double progess =
        (_currentQuestionIndex + 1) / _quizSession!.questions.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Take Quiz"),
        actions: [
          TextButton(
            onPressed: () {
              if (_currentQuestionIndex < _quizSession!.questions.length - 1) {
                setState(() => _currentQuestionIndex++);
              } else {
                _submitQuiz();
              }
            },
            child: const Text("Skip", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Session Progress",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "${_currentQuestionIndex + 1}/${_quizSession!.questions.length}",
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progess,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),

            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.timer, color: Colors.blue, size: 20),
                  const SizedBox(width: 5),
                  Text(
                    "${(_secondsRemaining ~/ 60)}:${(_secondsRemaining % 60).toString().padLeft(2, '0')}",
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(color: Colors.grey.shade100, blurRadius: 10),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    "IDENTIFY THE MEANING",
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    question.questionText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.separated(
                itemCount: question.options.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final option = question.options[index];
                  final isSelected =
                      _userAnswers[question.questionId] == option.optionId;

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _userAnswers[question.questionId] = option.optionId;
                      });

                      Future.delayed(const Duration(milliseconds: 300), () {
                        if (_currentQuestionIndex <
                            _quizSession!.questions.length - 1) {
                          setState(() => _currentQuestionIndex++);
                        } else {
                          _submitQuiz();
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue[50] : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Colors.blue
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: Text(
                                String.fromCharCode(65 + index),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Text(
                            option.content,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
