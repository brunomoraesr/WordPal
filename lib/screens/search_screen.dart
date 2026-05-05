import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _search(BuildContext context, String word) async {
    if (word.trim().isEmpty) return;
    _focusNode.unfocus();
    final provider = context.read<AppProvider>();
    await provider.search(word);
    if (!context.mounted) return;
    if (provider.searchState == SearchState.success) {
      Navigator.pushNamed(context, '/word', arguments: word);
    } else {
      _showError(context, provider.searchError);
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isLoading = provider.searchState == SearchState.loading;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        _WordPalMark(),
                        const SizedBox(width: 8),
                        const Text(
                          'WordPal',
                          style: TextStyle(
                            fontFamily: 'Fraunces',
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: AppColors.ink,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.accentSoft,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.local_fire_department_rounded,
                                  size: 14, color: AppColors.accent),
                              const SizedBox(width: 4),
                              Text(
                                '${provider.history.length} buscadas',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.accent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Greeting
                    const Text('Bom dia!',
                        style: TextStyle(
                            fontSize: 13, color: AppColors.inkSoft)),
                    const SizedBox(height: 4),
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontFamily: 'Fraunces',
                          fontSize: 28,
                          fontWeight: FontWeight.w400,
                          color: AppColors.ink,
                          letterSpacing: -0.6,
                          height: 1.1,
                        ),
                        children: [
                          TextSpan(text: 'Qual palavra você está\n'),
                          TextSpan(
                            text: 'buscando',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: AppColors.primary,
                            ),
                          ),
                          TextSpan(text: ' hoje?'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Search field
                    _SearchField(
                      controller: _controller,
                      focusNode: _focusNode,
                      isLoading: isLoading,
                      onSubmit: (v) => _search(context, v),
                    ),
                  ],
                ),
              ),
            ),

            // Loading indicator
            if (isLoading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primary),
                  ),
                ),
              ),

            if (!isLoading) ...[
              // Most recent search
              if (provider.history.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: GestureDetector(
                      onTap: () {
                        _controller.text = provider.history.first;
                        _search(context, provider.history.first);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primary),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.bgRaised,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.history_rounded,
                                  size: 20, color: AppColors.primary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('BUSCA MAIS RECENTE',
                                      style: TextStyle(
                                          fontFamily: 'monospace',
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 1.2,
                                          color: AppColors.inkMuted)),
                                  const SizedBox(height: 2),
                                  Text(
                                    provider.history.first,
                                    style: const TextStyle(
                                      fontFamily: 'Fraunces',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FontStyle.italic,
                                      color: AppColors.ink,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_rounded,
                                size: 18, color: AppColors.primary),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // Saved words preview
              if (provider.savedWords.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('PALAVRAS SALVAS',
                                style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.2,
                                    color: AppColors.inkMuted)),
                            GestureDetector(
                              onTap: () =>
                                  Navigator.pushNamed(context, '/notebook'),
                              child: const Text('Ver todas',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),

              if (provider.savedWords.isNotEmpty)
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 110,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: provider.savedWords.take(10).length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, i) {
                        final w = provider.savedWords[i];
                        return GestureDetector(
                          onTap: () => _search(context, w.word),
                          child: Container(
                            width: 140,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.bgRaised,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        w.word,
                                        style: const TextStyle(
                                          fontFamily: 'Fraunces',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.ink,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (w.audioUrl != null)
                                      const Icon(Icons.volume_up_rounded,
                                          size: 14,
                                          color: AppColors.primary),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  w.partOfSpeech,
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 10,
                                    color: AppColors.inkMuted,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  w.definition,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.inkSoft,
                                      height: 1.3),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

              // History
              if (provider.history.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('RECENTES',
                            style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                                color: AppColors.inkMuted)),
                        GestureDetector(
                          onTap: () => provider.clearHistory(),
                          child: const Text('Limpar',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary)),
                        ),
                      ],
                    ),
                  ),
                ),

              if (provider.history.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: provider.history.map((word) {
                        return GestureDetector(
                          onTap: () {
                            _controller.text = word;
                            _search(context, word);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.bgRaised,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.history_rounded,
                                    size: 12,
                                    color: AppColors.inkMuted),
                                const SizedBox(width: 5),
                                Text(
                                  word,
                                  style: const TextStyle(
                                    fontFamily: 'Fraunces',
                                    fontSize: 13,
                                    fontStyle: FontStyle.italic,
                                    color: AppColors.ink,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isLoading;
  final ValueChanged<String> onSubmit;

  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _speechEnabled = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _speechEnabled = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (mounted) setState(() => _isListening = false);
        }
      },
      onError: (errorNotification) {
        if (mounted) setState(() => _isListening = false);
      },
    );
    if (mounted) setState(() {});
  }

  void _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      return;
    }

    var status = await Permission.microphone.request();
    if (status.isGranted) {
      if (!_speechEnabled) {
        await _initSpeech();
      }
      
      if (_speechEnabled) {
        setState(() => _isListening = true);
        await _speech.listen(
          onResult: (result) {
            widget.controller.text = result.recognizedWords;
            if (result.finalResult && result.recognizedWords.isNotEmpty) {
              widget.onSubmit(result.recognizedWords);
            }
          },
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permissão de microfone necessária para busca por voz.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            textInputAction: TextInputAction.search,
            textCapitalization: TextCapitalization.none,
            onSubmitted: widget.onSubmit,
            style: const TextStyle(fontSize: 15, color: AppColors.ink),
            decoration: InputDecoration(
              hintText: 'Digite uma palavra em inglês…',
              prefixIcon: const Padding(
                padding: EdgeInsets.only(left: 14, right: 8),
                child: Icon(Icons.search_rounded,
                    color: AppColors.inkMuted, size: 20),
              ),
              prefixIconConstraints:
                  const BoxConstraints(minWidth: 0, minHeight: 0),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ValueListenableBuilder(
                    valueListenable: widget.controller,
                    builder: (_, value, __) => value.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded,
                                size: 18, color: AppColors.inkMuted),
                            onPressed: () => widget.controller.clear(),
                          )
                        : const SizedBox.shrink(),
                  ),
                  IconButton(
                    icon: Icon(_isListening ? Icons.mic : Icons.mic_none,
                        size: 20, color: _isListening ? AppColors.error : AppColors.inkMuted),
                    onPressed: _toggleListening,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: widget.isLoading ? null : () => widget.onSubmit(widget.controller.text),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(52, 52),
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          child: widget.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
              : const Icon(Icons.arrow_forward_rounded, size: 20),
        ),
      ],
    );
  }
}

class _WordPalMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(7),
      ),
      alignment: Alignment.center,
      child: const Text(
        'W',
        style: TextStyle(
          fontFamily: 'Fraunces',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          fontStyle: FontStyle.italic,
          color: Colors.white,
          letterSpacing: -1,
        ),
      ),
    );
  }
}
