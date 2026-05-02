import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../models/saved_word.dart';
import '../theme/app_theme.dart';

class NotebookScreen extends StatefulWidget {
  final VoidCallback? onOpenFlashcards;
  const NotebookScreen({super.key, this.onOpenFlashcards});

  @override
  State<NotebookScreen> createState() => _NotebookScreenState();
}

class _NotebookScreenState extends State<NotebookScreen> {
  String _statusFilter = 'learning';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    final all = provider.savedWords;
    final learning = all.where((w) => !w.mastered).toList();
    final mastered = all.where((w) => w.mastered).toList();
    final displayed = switch (_statusFilter) {
      'all' => all,
      'mastered' => mastered,
      _ => learning,
    };

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('YOUR COLLECTION',
                      style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                          color: AppColors.inkMuted)),
                  const SizedBox(height: 4),
                  const Text(
                    'Notebook',
                    style: TextStyle(
                      fontFamily: 'Fraunces',
                      fontSize: 30,
                      fontWeight: FontWeight.w400,
                      color: AppColors.ink,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Stats row
                  Row(
                    children: [
                      _StatChip(
                          label: 'Total',
                          value: '${all.length}',
                          color: AppColors.primary),
                      const SizedBox(width: 10),
                      _StatChip(
                          label: 'Learning',
                          value: '${learning.length}',
                          color: AppColors.accent),
                      const SizedBox(width: 10),
                      _StatChip(
                          label: 'Mastered',
                          value: '${mastered.length}',
                          color: AppColors.success),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Flashcards CTA
                  if (all.isNotEmpty)
                    GestureDetector(
                      onTap: widget.onOpenFlashcards ??
                          () => Navigator.pushNamed(context, '/flashcards'),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryDeep],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.style_rounded,
                                  size: 20, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Review with flashcards',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white)),
                                  Text('${all.length} cards · ~${(all.length * 0.5).ceil()} min',
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.white70)),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_rounded,
                                size: 18, color: Colors.white),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 14),

                  // Status filters
                  Row(
                    children: [
                      _FilterChip(
                        label: 'Learning',
                        selected: _statusFilter == 'learning',
                        onTap: () =>
                            setState(() => _statusFilter = 'learning'),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Mastered',
                        selected: _statusFilter == 'mastered',
                        onTap: () =>
                            setState(() => _statusFilter = 'mastered'),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'All',
                        selected: _statusFilter == 'all',
                        onTap: () => setState(() => _statusFilter = 'all'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Word list
            Expanded(
              child: displayed.isEmpty
                  ? _EmptyState(statusFilter: _statusFilter)
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                      itemCount: displayed.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        return _WordCard(
                          word: displayed[i],
                          onToggleMastery: () =>
                              provider.toggleMastery(displayed[i]),
                          onDelete: () =>
                              _confirmDelete(context, provider, displayed[i]),
                          onTap: () => _openWord(context, provider, displayed[i]),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _openWord(
      BuildContext context, AppProvider provider, SavedWord word) async {
    await provider.search(word.word);
    if (!context.mounted) return;
    if (provider.searchState == SearchState.success) {
      Navigator.pushNamed(context, '/word', arguments: word.word);
    }
  }

  void _confirmDelete(
      BuildContext context, AppProvider provider, SavedWord word) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgRaised,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove word?',
            style: TextStyle(
                fontFamily: 'Fraunces',
                fontSize: 20,
                fontWeight: FontWeight.w400)),
        content: Text(
          'Remove "${word.word}" from your notebook?',
          style: const TextStyle(color: AppColors.inkSoft),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.inkMuted)),
          ),
          TextButton(
            onPressed: () {
              provider.deleteWord(word);
              Navigator.pop(context);
            },
            child: const Text('Remove',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

// ── Word Card ─────────────────────────────────────────────────
class _WordCard extends StatelessWidget {
  final SavedWord word;
  final VoidCallback onToggleMastery;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _WordCard({
    required this.word,
    required this.onToggleMastery,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM d, y').format(word.addedAt);

    return Dismissible(
      key: Key('word_${word.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child:
            const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 22),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return false;
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.bgRaised,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: word.mastered
                  ? AppColors.success.withValues(alpha: 0.4)
                  : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              // Mastered checkbox
              SizedBox(
                width: 40,
                height: 40,
                child: Checkbox(
                  value: word.mastered,
                  onChanged: (_) => onToggleMastery(),
                  activeColor: AppColors.success,
                  side: const BorderSide(
                    color: AppColors.inkMuted,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Word info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          word.word,
                          style: const TextStyle(
                            fontFamily: 'Fraunces',
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (word.phonetic.isNotEmpty)
                          Text(
                            word.phonetic,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              color: AppColors.inkMuted,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (word.partOfSpeech.isNotEmpty) ...[
                          Text(
                            word.partOfSpeech,
                            style: const TextStyle(
                              fontFamily: 'Fraunces',
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                              color: AppColors.primary,
                            ),
                          ),
                          const Text(' · ',
                              style: TextStyle(
                                  color: AppColors.inkMuted, fontSize: 11)),
                        ],
                        Text(
                          dateStr,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.inkMuted),
                        ),
                      ],
                    ),
                    if (word.definition.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        word.definition,
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.inkSoft,
                            height: 1.4),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Status badge + chevron
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: word.mastered
                          ? AppColors.successSoft
                          : AppColors.accentSoft,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      word.mastered ? 'Mastered' : 'Learning',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: word.mastered
                            ? AppColors.success
                            : AppColors.accent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Icon(Icons.chevron_right_rounded,
                      size: 18, color: AppColors.inkMuted),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: TextStyle(
                fontFamily: 'Fraunces',
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: color,
                height: 1)),
        Text(label,
            style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 9,
                letterSpacing: 1,
                color: AppColors.inkMuted)),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.bgRaised,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : AppColors.inkSoft,
          ),
          child: Text(label),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String statusFilter;

  const _EmptyState({required this.statusFilter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              statusFilter == 'mastered'
                  ? Icons.emoji_events_outlined
                  : Icons.menu_book_outlined,
              size: 48,
              color: AppColors.inkMuted,
            ),
            const SizedBox(height: 16),
            Text(
              statusFilter == 'mastered'
                  ? 'No mastered words yet'
                  : statusFilter == 'learning'
                      ? 'No learning words'
                  : 'Your notebook is empty',
              style: const TextStyle(
                fontFamily: 'Fraunces',
                fontSize: 20,
                fontWeight: FontWeight.w400,
                color: AppColors.ink,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              statusFilter == 'mastered'
                  ? 'Keep learning! Check words as mastered\nfrom the word detail screen.'
                  : statusFilter == 'learning'
                      ? 'Search for words and save them here\nto start your learning list.'
                  : 'Search for words and save them here\nto build your vocabulary.',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.inkMuted,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
