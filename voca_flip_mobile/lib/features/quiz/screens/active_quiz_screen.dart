import 'dart:async';

import 'package:flutter/material.dart';
import 'package:voca_flip_mobile/features/quiz/models/quiz_question.dart';
import 'package:voca_flip_mobile/features/quiz/models/quiz_session.dart';
import 'package:voca_flip_mobile/features/quiz/services/quiz_service.dart';
import 'package:voca_flip_mobile/features/quiz/screens/quiz_result_screen.dart';

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
  final TextEditingController _fillController = TextEditingController();

  String? _selectedOptionId;
  bool _isShowingFeedback = false;

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
        widget.questionType,
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

    List<Map<String, String>> formattedAnswers = _quizSession!.questions.map((
      question,
    ) {
      return {
        "questionId": question.questionId,
        "selectedOptionId": _userAnswers[question.questionId] ?? "",
      };
    }).toList();

    try {
      final result = await _quizService.submitQuiz(
        _quizSession!.attemptId,
        widget.timeLimitSeconds - _secondsRemaining,
        formattedAnswers,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => QuizResultScreen(
              quizResult: result,
              attemptId: _quizSession!.attemptId,
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
    _fillController.dispose();
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
                setState(() {
                  _currentQuestionIndex++;
                  _selectedOptionId = null;
                  _isShowingFeedback = false;
                });
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
              child: widget.questionType == "FILL_IN_THE_BLANK"
                  ? _buildFillInTheBlank(question)
                  : ListView.separated(
                      itemCount: question.options.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final option = question.options[index];
                        final bool isCorrect =
                            option.optionId == question.questionId;
                        final bool isSelected =
                            _selectedOptionId == option.optionId;

                        Color borderColor = Colors.grey.shade300;
                        Color bgColor = Colors.white;
                        Widget trailingIcon = const SizedBox.shrink();

                        if (_isShowingFeedback) {
                          if (isCorrect) {
                            borderColor = Colors.green;
                            bgColor = Colors.green.shade50;
                            trailingIcon = const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            );
                          } else if (isSelected) {
                            borderColor = Colors.red;
                            bgColor = Colors.red.shade50;
                            trailingIcon = const Icon(
                              Icons.cancel,
                              color: Colors.red,
                            );
                          }
                        } else if (isSelected) {
                          borderColor = Colors.blue;
                          bgColor = Colors.blue.shade50;
                        }

                        return InkWell(
                          onTap: () {
                            if (_isShowingFeedback) return;

                            setState(() {
                              _selectedOptionId = option.optionId;
                              _isShowingFeedback = true;
                              _userAnswers[question.questionId] =
                                  option.optionId;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: borderColor, width: 2),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.transparent
                                        : Colors.grey[100],
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
                                Expanded(
                                  child: Text(
                                    option.content,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                trailingIcon,
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: !_isShowingFeedback
                    ? null
                    : () {
                        if (_currentQuestionIndex <
                            _quizSession!.questions.length - 1) {
                          setState(() {
                            _currentQuestionIndex++;
                            _selectedOptionId = null;
                            _isShowingFeedback = false;
                            _fillController.clear();
                          });
                        } else {
                          _submitQuiz();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isShowingFeedback
                      ? Colors.blue
                      : Colors.grey.shade300,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                child: Text(
                  _currentQuestionIndex < _quizSession!.questions.length - 1
                      ? "Next Question"
                      : "Submit Quiz",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFillInTheBlank(QuizQuestion question) {
    final String correctAnswer = question.options
        .firstWhere((opt) => opt.optionId == question.questionId)
        .content;
    final bool isCorrect =
        _fillController.text.trim().toLowerCase() ==
        correctAnswer.trim().toLowerCase();

    return Column(
      children: [
        TextField(
          controller: _fillController,
          enabled: !_isShowingFeedback,
          decoration: InputDecoration(
            hintText: "Type your answer here...",
            filled: true,
            fillColor: _isShowingFeedback
                ? (isCorrect ? Colors.green.shade50 : Colors.red.shade50)
                : Colors.grey.shade100,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _isShowingFeedback
                    ? (isCorrect ? Colors.green : Colors.red)
                    : Colors.grey.shade300,
              ),
            ),
          ),
        ),
        if (_isShowingFeedback) ...[
          const SizedBox(height: 12),
          if (!isCorrect)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "Correct answer: $correctAnswer",
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          else
            const Text(
              "Correct!",
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
        const SizedBox(height: 20),
        if (!_isShowingFeedback)
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                if (_fillController.text.trim().isEmpty) {
                  return;
                }
                setState(() {
                  _isShowingFeedback = true;
                  _userAnswers[question.questionId] = _fillController.text
                      .trim();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                shadowColor: Colors.blue,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified_user_outlined, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "CHECK ANSWER",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
