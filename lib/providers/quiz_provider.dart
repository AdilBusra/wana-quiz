import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/question_model.dart';
import '../data/dummy_questions.dart';

class QuizProvider extends ChangeNotifier {
  String _playerName = '';
  int _questionCount = 5;
  List<QuestionModel> _activeQuestions = [];
  int _currentIndex = 0;
  int _score = 0;
  
  bool _isAnswered = false;
  int? _selectedAnswerIndex;
  
  List<Map<String, dynamic>> _historyList = [];

  // State untuk Timer
  int _elapsedSeconds = 0;
  Timer? _timer;

  // State untuk opsi yang diacak pada soal saat ini
  List<String> _shuffledOptions = [];
  int _correctOptionIndex = 0;

  String get playerName => _playerName;
  int get questionCount => _questionCount;
  List<QuestionModel> get activeQuestions => _activeQuestions;
  int get currentIndex => _currentIndex;
  int get score => _score;
  bool get isAnswered => _isAnswered;
  int? get selectedAnswerIndex => _selectedAnswerIndex;
  List<Map<String, dynamic>> get historyList => _historyList;
  List<String> get shuffledOptions => _shuffledOptions;
  int get correctOptionIndex => _correctOptionIndex;
  
  QuestionModel get currentQuestion => _activeQuestions[_currentIndex];

  // Format Timer menjadi MM:SS
  String get formattedTime {
    final minutes = (_elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void startGame(String name, int count) {
    _playerName = name;
    _questionCount = count;
    _currentIndex = 0;
    _score = 0;
    _isAnswered = false;
    _selectedAnswerIndex = null;
    _elapsedSeconds = 0;

    List<QuestionModel> allQuestions = List.from(dummyQuestions);
    allQuestions.shuffle();
    _activeQuestions = allQuestions.take(_questionCount).toList();

    _prepareQuestion();
    _startTimer();

    notifyListeners();
  }

  // Fungsi untuk mengacak opsi jawaban pada soal aktif
  void _prepareQuestion() {
    final q = currentQuestion;
    // Simpan teks jawaban yang benar terlebih dahulu
    final correctOptionText = q.options[q.correctOptionIndex];
    
    // Acak opsinya
    _shuffledOptions = List.from(q.options);
    _shuffledOptions.shuffle();
    
    // Cari tahu di mana indeks jawaban benar setelah diacak
    _correctOptionIndex = _shuffledOptions.indexOf(correctOptionText);
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedSeconds++;
      notifyListeners();
    });
  }

  // Fungsi untuk melanjutkan timer tanpa mereset waktu yang sudah berjalan
  void resumeTimer() {
    if (_timer == null || !_timer!.isActive) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _elapsedSeconds++;
        notifyListeners();
      });
    }
  }

  void stopTimer() {
    _timer?.cancel();
  }

  Future<void> answerQuestion(int selectedIndex, BuildContext context) async {
    if (_isAnswered) return;

    _isAnswered = true;
    _selectedAnswerIndex = selectedIndex;

    if (selectedIndex == _correctOptionIndex) {
      _score += 10;
    }

    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1500));

    if (_currentIndex < _activeQuestions.length - 1) {
      _currentIndex++;
      _isAnswered = false;
      _selectedAnswerIndex = null;
      _prepareQuestion(); // Siapkan acakan opsi untuk soal berikutnya
      notifyListeners();
    } else {
      _finishQuiz(context);
    }
  }

  void _finishQuiz(BuildContext context) {
    stopTimer();
    _historyList.insert(0, {
      'name': _playerName,
      'score': _score,
      'totalQuestions': _questionCount,
      'time': formattedTime,
      'date': DateTime.now(),
    });
    notifyListeners();
    context.go('/result');
  }

  void resetQuiz() {
    stopTimer();
    _playerName = '';
    _currentIndex = 0;
    _score = 0;
    _elapsedSeconds = 0;
    _isAnswered = false;
    _selectedAnswerIndex = null;
    _activeQuestions.clear();
    notifyListeners();
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}