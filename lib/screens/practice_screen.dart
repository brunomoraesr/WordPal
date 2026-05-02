import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/saved_word.dart';
import '../main.dart';
import '../theme/app_theme.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  int _qIdx = 0;
  String? _picked;
  int _score = 0;
  bool _finished = false;
  late List<_Question> _questions;
  bool _built = false;

  void _buildQuestions(List<SavedWord> words) {
    if (_built || words.length < 2) return;
    _built = true;
    final rng = Random();
    final shuffled = [...words]..shuffle(rng);
    final pool = shuffled.take(min(10, shuffled.length)).toList();

    _questions = pool.map((word) {
      final others = words.where((w) => w.word != word.word).toList()
        ..shuffle(rng);
      final distractors = others.take(3).map((w) => w.word).toList();
      final options = [...distractors, word.word]..shuffle(rng);
      return _Question(
        word: word.word,
        phonetic: word.phonetic,
        correctAnswer: word.word,
        prompt: 'Which word matches this definition?',
        options: options,
        hint: word.definition,
      );
    }).toList();
  }

  void _pick(String option) {
    if (_picked != null) return;
    setState(() => _picked = option);
    if (option == _questions[_qIdx].correctAnswer) {
      _score++;
    }
    Future.delayed(const Duration(milliseconds: 1100), () {
      if (!mounted) return;
      setState(() {
        _picked = null;
        if (_qIdx + 1 >= _questions.length) {
          _finished = true;
        } else {
          _qIdx++;
        }
      });
    });
  }

  void _restart() {
    setState(() {
      _qIdx = 0;
      _score = 0;
      _picked = null;
      _finished = false;
      _built = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final words = context.watch<AppProvider>().savedWords;

    if (words.length < 2) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.quiz_outlined,
                    size: 56, color: AppColors.inkMuted),
                const SizedBox(height: 20),
                const Text('Save at least 2 words',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink),
                    textAlign: TextAlign.center),
                const SizedBox(height: 10),
                const Text(
                    'Add more words to your notebook\nto start practicing.',
                    style: TextStyle(fontSize: 15, color: AppColors.inkSoft),
                    textAlign: TextAlign.center),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    final shell = context
                        .findAncestorStateOfType<MainShellState>();
                    shell?.setTab(0);
                  },
                  child: const Text('Go to Search'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    _buildQuestions(words);

    if (_finished) {
      return _ResultScreen(
          score: _score, total: _questions.length, onRestart: _restart);
    }

    final q = _questions[_qIdx];
    final progress = (_qIdx + 1) / _questions.length;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Row(
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('DAILY QUIZ',
                          style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                              color: AppColors.inkMuted)),
                      SizedBox(height: 2),
                      Text('Practice',
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                              letterSpacing: -0.5)),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.successSoft,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_rounded,
                            size: 14, color: AppColors.success),
                        const SizedBox(width: 4),
                        Text('$_score',
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.success)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Progress
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Question ${_qIdx + 1} of ${_questions.length}',
                          style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              color: AppColors.inkSoft)),
                      const Text('3 min remaining',
                          style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              color: AppColors.inkMuted)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.border,
                      color: AppColors.primary,
                      minHeight: 4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Question card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: AppColors.bgRaised,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          Text(q.prompt.toUpperCase(),
                              style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 11,
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary)),
                          const SizedBox(height: 12),
                          Text(q.word,
                              style: const TextStyle(
                                  fontSize: 38,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                  letterSpacing: -1,
                                  height: 1)),
                          if (q.phonetic.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.primarySoft,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.volume_up_rounded,
                                      size: 12, color: AppColors.primary),
                                  const SizedBox(width: 4),
                                  Text(q.phonetic,
                                      style: const TextStyle(
                                          fontFamily: 'monospace',
                                          fontSize: 12,
                                          color: AppColors.primary)),
                                ],
                              ),
                            ),
                          ],
                          if (q.hint.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(q.hint,
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.inkSoft,
                                    height: 1.4),
                                textAlign: TextAlign.center,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Options
                    Expanded(
                      child: ListView.separated(
                        itemCount: q.options.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          final opt = q.options[i];
                          final label = String.fromCharCode(65 + i);
                          final isCorrect =
                              opt == q.correctAnswer;
                          final isPicked = _picked == opt;
                          final showResult = _picked != null;

                          Color bg = AppColors.bgRaised;
                          Color border = AppColors.border;
                          Color fg = AppColors.ink;

                          if (showResult && isCorrect) {
                            bg = AppColors.successSoft;
                            border = AppColors.success;
                            fg = AppColors.success;
                          } else if (showResult && isPicked && !isCorrect) {
                            bg = AppColors.accentSoft;
                            border = AppColors.accent;
                            fg = AppColors.accent;
                          }

                          return GestureDetector(
                            onTap: () => _pick(opt),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: bg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: border, width: 1.5),
                              ),
                              child: Row(
                                children: [
                                  AnimatedContainer(
                                    duration:
                                        const Duration(milliseconds: 200),
                                    width: 26,
                                    height: 26,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: showResult &&
                                              (isCorrect || isPicked)
                                          ? (isCorrect
                                              ? AppColors.success
                                              : AppColors.accent)
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: fg.withValues(alpha: 0.5),
                                        width: 1.5,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: showResult && isCorrect
                                        ? const Icon(Icons.check_rounded,
                                            size: 14, color: Colors.white)
                                        : showResult && isPicked
                                            ? const Text('✕',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold))
                                            : Text(label,
                                                style: const TextStyle(
                                                    fontFamily: 'monospace',
                                                    fontSize: 11,
                                                    fontWeight:
                                                        FontWeight.w700,
                                                    color: AppColors
                                                        .inkMuted)),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(opt,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          fontStyle: FontStyle.italic,
                                          color: fg)),
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
            ),
          ],
        ),
      ),
    );
  }
}

class _Question {
  final String word;
  final String phonetic;
  final String correctAnswer;
  final String prompt;
  final List<String> options;
  final String hint;

  _Question({
    required this.word,
    required this.phonetic,
    required this.correctAnswer,
    required this.prompt,
    required this.options,
    required this.hint,
  });
}

class _ResultScreen extends StatelessWidget {
  final int score;
  final int total;
  final VoidCallback onRestart;

  const _ResultScreen(
      {required this.score,
      required this.total,
      required this.onRestart});

  @override
  Widget build(BuildContext context) {
    final pct = (score / total * 100).round();
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.successSoft,
                ),
                alignment: Alignment.center,
                child: Text('$pct%',
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.success)),
              ),
              const SizedBox(height: 24),
              Text('$score of $total correct',
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink)),
              const SizedBox(height: 8),
              Text(
                  pct >= 80
                      ? 'Great job! Keep it up!'
                      : 'Keep practicing — you\'ll get there!',
                  style: const TextStyle(
                      fontSize: 15, color: AppColors.inkSoft),
                  textAlign: TextAlign.center),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onRestart,
                  child: const Text('Try again',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

