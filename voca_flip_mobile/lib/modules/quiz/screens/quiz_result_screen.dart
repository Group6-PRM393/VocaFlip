import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:voca_flip_mobile/models/quiz/quiz_result.dart';
import 'package:voca_flip_mobile/screens/quiz/quiz_review_screen.dart';

class QuizResultScreen extends StatelessWidget {
  final QuizResult quizResult;
  final String attemptId;

  const QuizResultScreen({
    super.key,
    required this.quizResult,
    required this.attemptId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Quiz Result"),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            SizedBox(
              height: 20,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 0,
                      centerSpaceRadius: 70,
                      sections: [
                        PieChartSectionData(
                          color: Colors.blue[700],
                          value: quizResult.scorePercentage,
                          title: '',
                          radius: 20,
                        ),
                        PieChartSectionData(
                          color: Colors.grey[300],
                          value: 100 - quizResult.scorePercentage,
                          title: '',
                          radius: 20,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${quizResult.scorePercentage.toInt()}%",
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const Text(
                        "Mastered",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              "Fantastic Work!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              "You're getting better every day.",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 30),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    Icons.check_circle,
                    Colors.green,
                    "${quizResult.correctAnswers}",
                    "Correct",
                  ),
                  _buildStatItem(
                    Icons.cancel,
                    Colors.red,
                    "${quizResult.incorrectAnswers}",
                    "Incorrect",
                  ),
                  _buildStatItem(
                    Icons.timer,
                    Colors.blue,
                    "${quizResult.timeTakenSeconds}",
                    "Time",
                  ),
                ],
              ),
            ),

            const Spacer(),

            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: const BorderSide(color: Colors.blue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QuizReviewScreen(attemptId: attemptId),
                  ),
                );
              },
              child: const Text("Review Answers"),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blue[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
              child: const Text(
                "Back to Home",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    IconData icon,
    Color color,
    String value,
    String label,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
