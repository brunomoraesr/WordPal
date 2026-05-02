import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/saved_word.dart';
import '../theme/app_theme.dart';

class FlashcardsScreen extends StatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen>
    with SingleTickerProviderStateMixin {
  int _idx = 0;
  bool _flipped = false;
  late AnimationController _animCtrl;
  late Animation<double> _flipAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _flipAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _flip() {
    if (!_flipped) {
      _animCtrl.forward();
    } else {
      _animCtrl.reverse();
    }
    setState(() => _flipped = !_flipped);
  }

  void _next() {
    final cards = context.read<AppProvider>().savedWords;
    setState(() {
      _flipped = false;
      _animCtrl.reset();
      _idx = (_idx + 1) % cards.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cards = context.watch<AppProvider>().savedWords;

    if (cards.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          title: const Text('Flashcards'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.style_outlined, size: 56, color: AppColors.inkMuted),
                SizedBox(height: 16),
                Text('No cards yet',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink)),
                SizedBox(height: 8),
                Text('Save words in your notebook\nto create flashcards.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: AppColors.inkSoft)),
              ],
            ),
          ),
        ),
      );
    }

    final card = cards[_idx % cards.length];
    final progress = (_idx + 1) / cards.length;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 20, color: AppColors.ink),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  Text(
                    '${_idx + 1} / ${cards.length}',
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.shuffle_rounded,
                        size: 22, color: AppColors.inkSoft),
                    onPressed: () {
                      setState(() {
                        _idx = 0;
                        _flipped = false;
                        _animCtrl.reset();
                      });
                    },
                  ),
                ],
              ),
            ),

            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.border,
                  color: AppColors.primary,
                  minHeight: 4,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Card
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: GestureDetector(
                  onTap: _flip,
                  child: AnimatedBuilder(
                    animation: _flipAnim,
                    builder: (_, __) {
                      final angle = _flipAnim.value * 3.14159;
                      final showBack = _flipAnim.value > 0.5;
                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(angle),
                        child: showBack
                            ? Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()..rotateY(3.14159),
                                child: _CardBack(card: card),
                              )
                            : _CardFront(card: card),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _next,
                      icon: const Text('✕',
                          style: TextStyle(
                              color: AppColors.accent, fontSize: 16)),
                      label: const Text('Review again',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.ink,
                        side: const BorderSide(color: AppColors.border),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _next,
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: const Text('Got it',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardFront extends StatelessWidget {
  final SavedWord card;
  const _CardFront({required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.bgRaised,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 30,
            offset: const Offset(0, 12),
          )
        ],
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(card.partOfSpeech.toUpperCase(),
                  style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      color: AppColors.inkMuted)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('C1',
                    style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary)),
              ),
            ],
          ),
          const Spacer(),
          Text(
            card.word,
            style: const TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
              letterSpacing: -1,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            card.phonetic,
            style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                color: AppColors.inkSoft),
          ),
          const Spacer(),
          const Center(
            child: Text(
              'TAP CARD TO REVEAL',
              style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardBack extends StatelessWidget {
  final SavedWord card;
  const _CardBack({required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.35),
            blurRadius: 30,
            offset: const Offset(0, 12),
          )
        ],
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('DEFINITION',
              style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: Colors.white70)),
          const Spacer(),
          Text(
            card.definition,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            height: 1,
            color: Colors.white24,
          ),
          const SizedBox(height: 20),
          Text(
            'PT · ${card.word}',
            style: const TextStyle(
              fontSize: 15,
              fontStyle: FontStyle.italic,
              color: Colors.white70,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
