import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../providers/app_provider.dart';
import '../models/word_entry.dart';
import '../theme/app_theme.dart';

class WordDetailScreen extends StatefulWidget {
  const WordDetailScreen({super.key});

  @override
  State<WordDetailScreen> createState() => _WordDetailScreenState();
}

class _WordDetailScreenState extends State<WordDetailScreen> {
  final _player = AudioPlayer();
  bool _isPlaying = false;
  bool _showTranslation = false;
  int _tabIndex = 0; // 0=definition, 1=examples, 2=related

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
      _player.onPlayerComplete.listen((_) {
        if (mounted) setState(() => _isPlaying = false);
      });
    } catch (_) {
      if (mounted) setState(() => _isPlaying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final word = provider.currentWord;

    if (word == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final filteredMeanings = provider.posFilter == 'all'
        ? word.meanings
        : word.meanings.where((m) => m.partOfSpeech == provider.posFilter).toList();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
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
                  const Text('Definition',
                      style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10,
                          letterSpacing: 1.2,
                          color: AppColors.inkMuted)),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      provider.isCurrentWordSaved
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      size: 22,
                      color: provider.isCurrentWordSaved
                          ? AppColors.accent
                          : AppColors.ink,
                    ),
                    onPressed: () => provider.toggleSaveCurrentWord(),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                children: [
                  // Part of speech + word
                  Row(
                    children: [
                      if (word.meanings.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            word.meanings.first.partOfSpeech,
                            style: const TextStyle(
                              fontFamily: 'Fraunces',
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    word.word,
                    style: const TextStyle(
                      fontFamily: 'Fraunces',
                      fontSize: 44,
                      fontWeight: FontWeight.w400,
                      color: AppColors.ink,
                      letterSpacing: -1.2,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Phonetic + audio
                  Row(
                    children: [
                      if (word.displayPhonetic.isNotEmpty) ...[
                        GestureDetector(
                          onTap: () => _playAudio(word.audioUrl),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
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
                                  size: 14,
                                  color: _isPlaying
                                      ? Colors.white
                                      : AppColors.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _isPlaying ? 'Playing…' : 'Listen',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _isPlaying
                                        ? Colors.white
                                        : AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          word.displayPhonetic,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13,
                            color: AppColors.inkSoft,
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Examples-only switch
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.bgRaised,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.self_improvement_rounded,
                            size: 16, color: AppColors.inkSoft),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Examples only mode',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.ink)),
                              Text('Hide definitions for self-assessment',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.inkMuted)),
                            ],
                          ),
                        ),
                        Switch.adaptive(
                          value: provider.examplesOnly,
                          onChanged: (v) => provider.setExamplesOnly(v),
                          activeColor: AppColors.primary,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // POS radio filter
                  if (word.partsOfSpeech.length > 1) ...[
                    const Text('FILTER BY',
                        style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                            color: AppColors.inkMuted)),
                    const SizedBox(height: 8),
                    _PosFilterRow(
                      partsOfSpeech: word.partsOfSpeech,
                      selected: provider.posFilter,
                      onChanged: provider.setPosFilter,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Tabs
                  _TabBar(
                    tabs: const ['Definition', 'Examples', 'Related'],
                    selected: _tabIndex,
                    onTap: (i) => setState(() => _tabIndex = i),
                  ),

                  const SizedBox(height: 16),

                  // Tab content
                  if (_tabIndex == 0)
                    _DefinitionTab(
                      meanings: filteredMeanings,
                      examplesOnly: provider.examplesOnly,
                    ),

                  if (_tabIndex == 1)
                    _ExamplesTab(meanings: filteredMeanings),

                  if (_tabIndex == 2)
                    _RelatedTab(
                      synonyms: word.allSynonyms,
                      antonyms: word.allAntonyms,
                    ),
                ],
              ),
            ),

            // Save button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => provider.toggleSaveCurrentWord(),
                  icon: Icon(
                    provider.isCurrentWordSaved
                        ? Icons.check_rounded
                        : Icons.bookmark_add_outlined,
                    size: 18,
                  ),
                  label: Text(provider.isCurrentWordSaved
                      ? 'Saved to notebook'
                      : 'Save to notebook'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: provider.isCurrentWordSaved
                        ? AppColors.successSoft
                        : AppColors.primary,
                    foregroundColor: provider.isCurrentWordSaved
                        ? AppColors.success
                        : Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── POS filter (Radio buttons) ──────────────────────────────
class _PosFilterRow extends StatelessWidget {
  final List<String> partsOfSpeech;
  final String selected;
  final ValueChanged<String> onChanged;

  const _PosFilterRow({
    required this.partsOfSpeech,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final options = ['all', ...partsOfSpeech];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((pos) {
        final isSelected = selected == pos;
        return GestureDetector(
          onTap: () => onChanged(pos),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color:
                  isSelected ? AppColors.primary : AppColors.bgRaised,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.white : AppColors.inkMuted,
                      width: 1.5,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 6),
                Text(
                  pos,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.inkSoft,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Tab bar ─────────────────────────────────────────────────
class _TabBar extends StatelessWidget {
  final List<String> tabs;
  final int selected;
  final ValueChanged<int> onTap;

  const _TabBar(
      {required this.tabs, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(tabs.length, (i) {
        final active = i == selected;
        return Expanded(
          child: GestureDetector(
            onTap: () => onTap(i),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color:
                        active ? AppColors.primary : AppColors.divider,
                    width: active ? 2 : 1,
                  ),
                ),
              ),
              child: Text(
                tabs[i],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      active ? FontWeight.w600 : FontWeight.w500,
                  color: active ? AppColors.primary : AppColors.inkMuted,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ── Definition tab ───────────────────────────────────────────
class _DefinitionTab extends StatelessWidget {
  final List<Meaning> meanings;
  final bool examplesOnly;

  const _DefinitionTab(
      {required this.meanings, required this.examplesOnly});

  @override
  Widget build(BuildContext context) {
    if (meanings.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('No definitions found for this filter.',
              style: TextStyle(color: AppColors.inkMuted)),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: meanings.map((meaning) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                meaning.partOfSpeech,
                style: const TextStyle(
                  fontFamily: 'Fraunces',
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: AppColors.primary,
                ),
              ),
            ),
            ...meaning.definitions.take(3).toList().asMap().entries.map((e) {
              final idx = e.key;
              final def = e.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${idx + 1}.',
                      style: const TextStyle(
                        fontFamily: 'Fraunces',
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!examplesOnly)
                            Text(def.definition,
                                style: const TextStyle(
                                    fontSize: 15,
                                    color: AppColors.ink,
                                    height: 1.5)),
                          if (examplesOnly)
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primarySoft,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Definition hidden — test yourself!',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.primary,
                                    fontStyle: FontStyle.italic),
                              ),
                            ),
                          if (def.example != null &&
                              def.example!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              '"${def.example}"',
                              style: const TextStyle(
                                fontFamily: 'Fraunces',
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                                color: AppColors.inkSoft,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
            const Divider(color: AppColors.divider, height: 24),
          ],
        );
      }).toList(),
    );
  }
}

// ── Examples tab ─────────────────────────────────────────────
class _ExamplesTab extends StatelessWidget {
  final List<Meaning> meanings;

  const _ExamplesTab({required this.meanings});

  @override
  Widget build(BuildContext context) {
    final examples = <String>[];
    for (final m in meanings) {
      for (final d in m.definitions) {
        if (d.example != null && d.example!.isNotEmpty) {
          examples.add(d.example!);
        }
      }
    }

    if (examples.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('No examples available for this word.',
              style: TextStyle(color: AppColors.inkMuted)),
        ),
      );
    }

    return Column(
      children: examples.map((ex) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.bgRaised,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            '"$ex"',
            style: const TextStyle(
              fontFamily: 'Fraunces',
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: AppColors.ink,
              height: 1.55,
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Related tab ───────────────────────────────────────────────
class _RelatedTab extends StatelessWidget {
  final List<String> synonyms;
  final List<String> antonyms;

  const _RelatedTab({required this.synonyms, required this.antonyms});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (synonyms.isNotEmpty) ...[
          const Text('SYNONYMS',
              style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: AppColors.success)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: synonyms.map((s) => _Chip(s, AppColors.successSoft, AppColors.success)).toList(),
          ),
          const SizedBox(height: 20),
        ],
        if (antonyms.isNotEmpty) ...[
          const Text('ANTONYMS',
              style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: AppColors.accent)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: antonyms.map((s) => _Chip(s, AppColors.accentSoft, AppColors.accent)).toList(),
          ),
        ],
        if (synonyms.isEmpty && antonyms.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('No synonyms or antonyms available.',
                  style: TextStyle(color: AppColors.inkMuted)),
            ),
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;

  const _Chip(this.label, this.bg, this.fg);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fg.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Fraunces',
          fontSize: 13,
          fontStyle: FontStyle.italic,
          color: fg,
        ),
      ),
    );
  }
}
