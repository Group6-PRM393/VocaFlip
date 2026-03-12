import 'package:flutter/material.dart';
import 'package:voca_flip_mobile/features/quiz/screens/active_quiz_screen.dart';

class QuizSettingsScreen extends StatefulWidget {
  final String deckId;
  const QuizSettingsScreen({super.key, required this.deckId});

  @override
  State<QuizSettingsScreen> createState() => _QuizSettingsScreenState();
}

class _QuizSettingsScreenState extends State<QuizSettingsScreen> {
  int _numberOfQuestions = 10;
  double _timeLimitMinutes = 5.0;
  String _questionType = 'MULTIPLE_CHOICE';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Quiz Settings",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Question Type"),
            const SizedBox(height: 10),
            Row(
              children:
                  [
                    {"display": "Multiple Choice", "value": "MULTIPLE_CHOICE"},
                    {"display": "Fill in Blanks", "value": "FILL_IN_THE_BLANK"},
                  ].map((type) {
                    final isSelected = _questionType == type['value'];
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _questionType = type['value']!;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : Colors.grey[100],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              type['display']!,
                              style: TextStyle(
                                color: isSelected ? Colors.blue : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),

            const SizedBox(height: 30),
            _buildSectionTitle("Number of Questions"),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                10,
                20,
                50,
              ].map((value) => _buildNumberOption(value)).toList(),
            ),
            const SizedBox(height: 30),
            _buildSectionTitle("Time Limit (minutes)"),
            Slider(
              value: _timeLimitMinutes,
              min: 1,
              max: 30,
              divisions: 29,
              label: "${_timeLimitMinutes.toInt()} min",
              onChanged: (value) => setState(() => _timeLimitMinutes = value),
            ),
            Center(
              child: Text(
                "${_timeLimitMinutes.toInt()}:00 min",
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ActiveQuizScreen(
                        deckId: widget.deckId,
                        numberOfQuestions: _numberOfQuestions,
                        timeLimitSeconds: (_timeLimitMinutes * 60).toInt(),
                        questionType: _questionType,
                      ),
                    ),
                  );
                },
                child: const Text(
                  "Start Quiz",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildNumberOption(int value) {
    final isSelected = _numberOfQuestions == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _numberOfQuestions = value;
        });
      },
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.grey[100],
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.transparent,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            "$value",
            style: TextStyle(
              color: isSelected ? Colors.blue : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
