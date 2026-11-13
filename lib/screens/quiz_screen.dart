import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../providers/quiz_provider.dart';
import '../widgets/option_card.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  void _showExitConfirmation(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    // 1. Hentikan timer sementara saat pop-up keluar
    final quizProvider = context.read<QuizProvider>();
    quizProvider.stopTimer();

    showDialog(
      context: context,
      barrierDismissible:
          false, // Mencegah dialog tertutup jika diklik di luar area
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Keluar Kuis?',
          style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
        ),
        content: Text(
          'Apakah kamu yakin ingin berhenti mengerjakan kuis? Progres kamu akan hilang.',
          style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[800]),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              // 2. Lanjutkan kembali timer dari detik terakhir saat tombol Batal ditekan
              quizProvider.resumeTimer();
            },
            child: const Text(
              'Batal',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              quizProvider.stopTimer();
              context.go('/');
            },
            child: Text(
              'Ya, Berhenti',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red.shade400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quizProvider = context.watch<QuizProvider>();
    final question = quizProvider.currentQuestion;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER BAR (Diperbarui dengan Stack)
                    SizedBox(
                      height: 45, // Tinggi tetap untuk area header
                      child: Stack(
                        children: [
                          // Tombol Back Terkunci di Kiri
                          Align(
                            alignment: Alignment.centerLeft,
                            child: InkWell(
                              onTap: () => _showExitConfirmation(context),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.grey[800]
                                      : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.arrow_back_ios_new,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),

                          // Judul Terkunci Tepat di Tengah Layar
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              'WanaQ',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ),

                          // Timer Terkunci di Kanan dengan Lebar Tetap
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              width: 85, // Lebar tetap agar tidak goyang
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.timer_outlined,
                                    size: 16,
                                    color: primaryColor,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    quizProvider.formattedTime,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Indikator Progres
                    Text(
                      'Soal ${quizProvider.currentIndex + 1} dari ${quizProvider.questionCount}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Teks Pertanyaan
                    // KODE BARU (YANG BENAR):
                    Text(
                      question.questionText,
                      style: const TextStyle(
                        fontSize:
                            20, // Sedikit disesuaikan agar pas di landscape
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                    const Spacer(),
                    // Daftar Pilihan Ganda
                    Column(
                      children: List.generate(
                        quizProvider.shuffledOptions.length,
                        (index) {
                          final isCorrect =
                              index == quizProvider.correctOptionIndex;
                          final isSelected =
                              index == quizProvider.selectedAnswerIndex;

                          Color bgColor;
                          Color textColor;

                          if (quizProvider.isAnswered) {
                            if (isCorrect) {
                              bgColor = isDark
                                  ? const Color(0xFFDBEE75)
                                  : const Color(0xFF3C5A00); // Hijau = Benar
                              textColor = isDark ? Colors.black : Colors.white;
                            } else if (isSelected) {
                              bgColor = isDark
                                  ? const Color.fromARGB(255, 179, 61, 65)
                                  : const Color(0xFFD32F2F); // Merah = Salah
                              textColor = isDark ? Colors.black : Colors.white;
                            } else {
                              // Warna opsi lain yang tidak dipilih menjadi redup (dimmed)
                              bgColor = isDark
                                  ? const Color(0xFF2D2D2D)
                                  : const Color(0xFFE0E0E0);
                              textColor = isDark
                                  ? const Color(0xFF9E9E9E)
                                  : const Color(0xFF757575);
                            }
                          } else {
                            // Logika Warna Normal (sebelum menjawab)
                            bgColor = isDark
                                ? const Color(0xFF1E1E1E)
                                : const Color(0xFFF5F5F5);
                            textColor = isDark ? Colors.white : Colors.black87;
                          }

                          return OptionCard(
                            text: quizProvider.shuffledOptions[index],
                            backgroundColor: bgColor,
                            textColor: textColor,
                            onTap: () {
                              quizProvider.answerQuestion(index, context);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
