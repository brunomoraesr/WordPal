import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../providers/app_provider.dart';
import '../models/saved_word.dart';
import '../services/translation_service.dart';
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
  List<_Question> _questions = [];
  bool _loading = false;
  bool _built = false;
  String? _loadError;
  bool _isPlaying = false;

  final _translationService = TranslationService();
  final _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _isPlaying = false);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _playAudio(String? url) async {
    if (url == null || url.isEmpty) return;
    setState(() => _isPlaying = true);
    try {
      await _player.stop();
      await _player.play(UrlSource(url));
    } catch (_) {
      if (mounted) setState(() => _isPlaying = false);
    }
  }

  Future<void> _buildQuestions(List<SavedWord> words) async {
    if (_built || words.length < 2) return;
    _built = true;

    setState(() {
      _loading = true;
      _loadError = null;
    });

    final rng = Random();
    final shuffled = [...words]..shuffle(rng);
    final pool = shuffled.take(min(10, shuffled.length)).toList();

    // Fetch translations in parallel for all words in pool + possible distractors
    // We need translations for everything so distractors also have PT text.
    final allNeeded = {...pool, ...words}.toList();
    final translationMap = <String, String>{};

    await Future.wait(allNeeded.map((w) async {
      final pt = await _translationService.translate(w.word);
      if (pt != null) translationMap[w.word] = pt;
    }));

    // Build questions — only for words that got a translation
    final translatable = pool.where((w) => translationMap.containsKey(w.word)).toList();

    if (translatable.length < 2) {
      // Fallback: use English definition as the "translation" for all words
      for (final w in pool) {
        if (!translationMap.containsKey(w.word) && w.definition.isNotEmpty) {
          translationMap[w.word] = w.definition;
        }
      }
    }

    final finalPool = pool.where((w) => translationMap.containsKey(w.word)).toList();

    if (finalPool.length < 2) {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadError = 'Não foi possível carregar as traduções.\nVerifique sua conexão e tente novamente.';
        });
      }
      return;
    }

    final questions = finalPool.map((word) {
      final correctTranslation = translationMap[word.word]!;
      final otherWords = finalPool
          .where((w) => w.word != word.word && translationMap.containsKey(w.word))
          .toList()
        ..shuffle(rng);
      final distractorTranslations =
          otherWords.take(3).map((w) => translationMap[w.word]!).toList();
      final options = [...distractorTranslations, correctTranslation]..shuffle(rng);

      return _Question(
        word: word.word,
        phonetic: word.phonetic,
        audioUrl: word.audioUrl,
        correctAnswer: correctTranslation,
        options: options,
      );
    }).toList()
      ..shuffle(rng);

    if (mounted) {
      setState(() {
        _questions = questions;
        _loading = false;
      });
    }
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
          context.read<AppProvider>().addPracticeMinutes(3);
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
      _questions = [];
      _loadError = null;
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
                const Text('Salve pelo menos 2 palavras',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink),
                    textAlign: TextAlign.center),
                const SizedBox(height: 10),
                const Text(
                    'Adicione mais palavras ao seu caderno\npara começar a praticar.',
                    style: TextStyle(fontSize: 15, color: AppColors.inkSoft),
                    textAlign: TextAlign.center),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    final shell =
                        context.findAncestorStateOfType<MainShellState>();
                    shell?.setTab(0);
                  },
                  child: const Text('Ir para Busca'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Kick off async build after first frame
    if (!_built && !_loading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _buildQuestions(words.toList());
      });
    }

    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        body: SafeArea(
          child: Column(
            children: [
              _Header(score: _score),
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: AppColors.primary),
                      SizedBox(height: 20),
                      Text('Buscando traduções…',
                          style: TextStyle(
                              fontSize: 14, color: AppColors.inkSoft)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_loadError != null) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off_rounded,
                    size: 48, color: AppColors.inkMuted),
                const SizedBox(height: 20),
                Text(_loadError!,
                    style: const TextStyle(
                        fontSize: 15, color: AppColors.inkSoft),
                    textAlign: TextAlign.center),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _restart,
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_questions.isEmpty) {
      // Still initializing
      return const Scaffold(backgroundColor: AppColors.bg);
    }

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
                      Text('QUIZ DIÁRIO',
                          style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                              color: AppColors.inkMuted)),
                      SizedBox(height: 2),
                      Text('Praticar',
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

            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Questão ${_qIdx + 1} de ${_questions.length}',
                          style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              color: AppColors.inkSoft)),
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
                    // Word card
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
                          const Text('QUAL É A TRADUÇÃO?',
                              style: TextStyle(
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
                            GestureDetector(
                              onTap: q.audioUrl != null
                                  ? () => _playAudio(q.audioUrl)
                                  : null,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: _isPlaying
                                      ? AppColors.primary
                                      : AppColors.primarySoft,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _isPlaying
                                          ? Icons.pause_rounded
                                          : Icons.volume_up_rounded,
                                      size: 12,
                                      color: _isPlaying
                                          ? Colors.white
                                          : AppColors.primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(q.phonetic,
                                        style: TextStyle(
                                            fontFamily: 'monospace',
                                            fontSize: 12,
                                            color: _isPlaying
                                                ? Colors.white
                                                : AppColors.primary)),
                                  ],
                                ),
                              ),
                            ),
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
                          final isCorrect = opt == q.correctAnswer;
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
                                border:
                                    Border.all(color: border, width: 1.5),
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
                                  Expanded(
                                    child: Text(opt,
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: fg)),
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
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final int score;
  const _Header({required this.score});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('QUIZ DIÁRIO',
                  style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      color: AppColors.inkMuted)),
              SizedBox(height: 2),
              Text('Praticar',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                      letterSpacing: -0.5)),
            ],
          ),
          const Spacer(),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.successSoft,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_rounded,
                    size: 14, color: AppColors.success),
                const SizedBox(width: 4),
                Text('$score',
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.success)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Question {
  final String word;
  final String phonetic;
  final String? audioUrl;
  final String correctAnswer;
  final List<String> options;

  _Question({
    required this.word,
    required this.phonetic,
    this.audioUrl,
    required this.correctAnswer,
    required this.options,
  });
}

class _ResultScreen extends StatelessWidget {
  final int score;
  final int total;
  final VoidCallback onRestart;

  const _ResultScreen(
      {required this.score, required this.total, required this.onRestart});

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
              Text('$score de $total corretas',
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink)),
              const SizedBox(height: 8),
              Text(
                  pct >= 80
                      ? 'Ótimo trabalho! Continue assim!'
                      : 'Continue praticando — você vai chegar lá!',
                  style:
                      const TextStyle(fontSize: 15, color: AppColors.inkSoft),
                  textAlign: TextAlign.center),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onRestart,
                  child: const Text('Tentar novamente',
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
