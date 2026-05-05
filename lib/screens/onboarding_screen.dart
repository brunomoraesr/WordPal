import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/preferences_service.dart';
import '../theme/app_theme.dart';

const _levels = [
  'Iniciante · A1',
  'Básico · A2',
  'Pré-intermediário · B1',
  'Intermediário · B2',
  'Pós-intermediário · C1',
  'Avançado · C2',
];

const _goals = [
  'Vocabulário geral',
  'Acadêmico / IELTS / TOEFL',
  'Inglês para negócios',
  'Viagens e dia a dia',
  'Literatura e leitura',
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final _pageController = PageController();
  final _nameController = TextEditingController();
  final _nameFormKey = GlobalKey<FormState>();

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnim;

  int _step = 0;
  String _selectedLevel = _levels[3]; // default: Intermediate B2
  String _selectedGoal = _goals.first;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _fadeController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_step == 0 && !_nameFormKey.currentState!.validate()) return;
    setState(() => _step++);
    _pageController.animateToPage(
      _step,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _prevStep() {
    if (_step == 0) return;
    setState(() => _step--);
    _pageController.animateToPage(
      _step,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _finish() async {
    setState(() => _loading = true);

    final provider = context.read<AppProvider>();
    await provider.updateName(_nameController.text.trim());
    await provider.updateEnglishLevel(_selectedLevel);
    await provider.updateLearningGoal(_selectedGoal);

    final prefs = PreferencesService();
    await prefs.setOnboardingDone();

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            children: [
              const SizedBox(height: 20),
              _StepIndicator(current: _step, total: 3),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _NamePage(
                      controller: _nameController,
                      formKey: _nameFormKey,
                      onNext: _nextStep,
                    ),
                    _PickerPage(
                      title: 'Qual é o seu\nnível de inglês?',
                      subtitle: "Vamos adaptar o vocabulário e os exemplos.",
                      options: _levels,
                      selected: _selectedLevel,
                      onChanged: (v) => setState(() => _selectedLevel = v),
                      onNext: _nextStep,
                      onBack: _prevStep,
                    ),
                    _PickerPage(
                      title: 'Qual é o seu\nobjetivo?',
                      subtitle: 'Ajuda-nos a sugerir as palavras certas.',
                      options: _goals,
                      selected: _selectedGoal,
                      onChanged: (v) => setState(() => _selectedGoal = v),
                      onNext: _loading ? null : _finish,
                      onBack: _prevStep,
                      nextLabel: 'Começar',
                      loading: _loading,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Step indicator ────────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int current;
  final int total;

  const _StepIndicator({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.divider,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

// ── Step 1: Name ─────────────────────────────────────────────────────────────

class _NamePage extends StatelessWidget {
  final TextEditingController controller;
  final GlobalKey<FormState> formKey;
  final VoidCallback onNext;

  const _NamePage({
    required this.controller,
    required this.formKey,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(flex: 2),
            Text(
              'Bem-vindo ao\nWordPal',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1.2,
                    height: 1.1,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              "Vamos configurar sua jornada de vocabulário.",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.inkMuted,
                  ),
            ),
            const Spacer(flex: 1),
            Text(
              'Seu nome',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.inkSoft,
                  ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: controller,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.ink,
              ),
              decoration: const InputDecoration(hintText: 'ex. João'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Por favor, insira seu nome';
                if (v.trim().length < 2) return 'O nome deve ter pelo menos 2 caracteres';
                return null;
              },
              onFieldSubmitted: (_) => onNext(),
            ),
            const Spacer(flex: 3),
            _NextButton(label: 'Continuar', onTap: onNext),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Step 2 & 3: Option picker ─────────────────────────────────────────────────

class _PickerPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onChanged;
  final VoidCallback? onNext;
  final VoidCallback onBack;
  final String nextLabel;
  final bool loading;

  const _PickerPage({
    required this.title,
    required this.subtitle,
    required this.options,
    required this.selected,
    required this.onChanged,
    required this.onNext,
    required this.onBack,
    this.nextLabel = 'Continue',
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(flex: 1),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1.2,
                  height: 1.1,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.inkMuted,
                ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              physics: const ClampingScrollPhysics(),
              itemCount: options.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final opt = options[i];
                final isSelected = opt == selected;
                return GestureDetector(
                  onTap: () => onChanged(opt),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primarySoft
                          : AppColors.bgRaised,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            opt,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.ink,
                            ),
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle_rounded,
                              size: 18, color: AppColors.primary),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              GestureDetector(
                onTap: onBack,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.bgRaised,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(Icons.arrow_back_rounded,
                      size: 20, color: AppColors.inkSoft),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _NextButton(
                  label: nextLabel,
                  onTap: onNext,
                  loading: loading,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Shared next button ────────────────────────────────────────────────────────

class _NextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool loading;

  const _NextButton({
    required this.label,
    required this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        child: loading
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : Text(label),
      ),
    );
  }
}
