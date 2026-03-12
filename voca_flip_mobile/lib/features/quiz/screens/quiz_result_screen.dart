import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:voca_flip_mobile/features/quiz/models/quiz_result.dart';
import 'package:voca_flip_mobile/features/quiz/screens/quiz_review_screen.dart';

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
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              SizedBox(
                height: 220,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 0,
                        centerSpaceRadius: 70,
                        startDegreeOffset: -90,
                        sections: [
                          PieChartSectionData(
                            color: Colors.blue[700],
                            value: quizResult.scorePercentage.toDouble(),
                            title: '',
                            radius: 20,
                          ),
                          PieChartSectionData(
                            color: Colors.grey[200],
                            value: (100 - quizResult.scorePercentage)
                                .toDouble(),
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
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const Text(
                          "Score",
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
              const Text(
                "Fantastic Work!",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "You're getting better every day.",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),

              const SizedBox(height: 40),

              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      Icons.check_circle_outline_rounded,
                      Colors.green,
                      "${quizResult.correctAnswers}",
                      "Correct",
                    ),
                    _buildStatItem(
                      Icons.highlight_off_rounded,
                      Colors.red,
                      "${quizResult.incorrectAnswers}",
                      "Incorrect",
                    ),
                    _buildStatItem(
                      Icons.timer_outlined,
                      Colors.blue,
                      "${quizResult.timeTakenSeconds}s",
                      "Time",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 60),

              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  side: BorderSide(color: Colors.blue[700]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
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
                child: Text(
                  "Review Answers",
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  backgroundColor: Colors.blue[700],
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
                child: const Text(
                  "Back to Home",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
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
        Icon(icon, size: 28, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
      ],
    );
  }
}
