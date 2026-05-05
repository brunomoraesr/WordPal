import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showEditNameDialog(BuildContext context, AppProvider provider) {
    final controller = TextEditingController(text: provider.userProfile.name);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgRaised,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Editar nome',
            style: TextStyle(
                fontFamily: 'Fraunces',
                fontSize: 20,
                fontWeight: FontWeight.w400)),
        content: TextField(
          controller: controller,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: 'Digite seu nome',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar',
                style: TextStyle(color: AppColors.inkMuted)),
          ),
          TextButton(
            onPressed: () {
              provider.updateName(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Salvar',
                style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  String _formatReminderTime(String hhmm) {
    final parts = hhmm.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    final period = hour < 12 ? 'AM' : 'PM';
    final h = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$h:${minute.toString().padLeft(2, '0')} $period';
  }

  Future<void> _pickReminderTime(BuildContext context, AppProvider provider) async {
    final parts = provider.userProfile.reminderTime.split(':');
    final initial = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
        child: child!,
      ),
    );
    if (picked != null && context.mounted) {
      provider.updateReminderTime(picked);
    }
  }

  String _fontSizeLabel(double scale) {
    if (scale <= 0.85) return 'Pequena';
    if (scale <= 1.0) return 'Normal';
    return 'Grande';
  }

  void _showFontSizeDialog(BuildContext context, AppProvider provider) {
    final options = [
      (0.85, 'Pequena'),
      (1.0, 'Normal'),
      (1.15, 'Grande'),
    ];
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgRaised,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Tamanho da fonte',
            style: TextStyle(
                fontFamily: 'Fraunces',
                fontSize: 20,
                fontWeight: FontWeight.w400)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((opt) {
            final selected = (provider.userProfile.fontSize - opt.$1).abs() < 0.01;
            return ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(opt.$2,
                  style: TextStyle(
                      fontSize: 14 * opt.$1,
                      color: selected ? AppColors.primary : AppColors.ink,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w400)),
              trailing: selected
                  ? const Icon(Icons.check_rounded,
                      size: 18, color: AppColors.primary)
                  : null,
              onTap: () {
                provider.updateFontSize(opt.$1);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar',
                style: TextStyle(color: AppColors.inkMuted)),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgRaised,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Ajuda e suporte', style: TextStyle(fontFamily: 'Fraunces', fontSize: 20)),
        content: const Text('Para suporte, envie um e-mail para support@wordpal.app ou acesse nosso site.',
            style: TextStyle(color: AppColors.inkSoft)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _showResetOnboardingDialog(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgRaised,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Refazer configuração',
            style: TextStyle(fontFamily: 'Fraunces', fontSize: 20)),
        content: const Text(
            'O assistente de configuração será exibido na próxima vez que você abrir o app.',
            style: TextStyle(color: AppColors.inkSoft)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.inkMuted)),
          ),
          TextButton(
            onPressed: () async {
              await provider.resetOnboarding();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Configuração será exibida na próxima abertura'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Redefinir', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final profile = provider.userProfile;
    final total = provider.savedWords.length;
    final mastered = provider.savedWords.where((w) => w.mastered).length;
    final joinedStr = DateFormat('MMMM yyyy').format(profile.joinedAt);
    
    // Calculate activity
    final days = ['M', 'T', 'W', 'Th', 'F', 'S', 'Su'];
    final practiceMinutes = profile.weeklyPracticeMinutes;
    final maxMinutes = practiceMinutes.values.isEmpty ? 0 : practiceMinutes.values.reduce(max);
    
    final activityFractions = days.map((day) {
      final mins = practiceMinutes[day] ?? 0;
      return maxMinutes == 0 ? 0.0 : (mins / maxMinutes);
    }).toList();
    
    final totalMinutesThisWeek = practiceMinutes.values.fold(0, (sum, mins) => sum + mins);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            // Avatar + name
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.accent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(profile.name,
                              style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                  letterSpacing: -0.4)),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => _showEditNameDialog(context, provider),
                            child: const Icon(Icons.edit_rounded, size: 16, color: AppColors.inkMuted),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text('${profile.englishLevel} · Entrou em $joinedStr',
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.inkSoft)),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Stats row
            Row(
              children: [
                _BigStat(
                    icon: Icons.local_fire_department_rounded,
                    value: '${provider.history.length}',
                    label: 'Buscas',
                    bgColor: AppColors.accentSoft,
                    fgColor: AppColors.accent),
                const SizedBox(width: 10),
                _BigStat(
                    icon: Icons.menu_book_rounded,
                    value: '$total',
                    label: 'Palavras salvas',
                    bgColor: AppColors.primarySoft,
                    fgColor: AppColors.primary),
                const SizedBox(width: 10),
                _BigStat(
                    icon: Icons.star_rounded,
                    value: '$mastered',
                    label: 'Dominadas',
                    bgColor: AppColors.successSoft,
                    fgColor: AppColors.success),
              ],
            ),

            const SizedBox(height: 20),

            // Activity chart
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.bgRaised,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('ESTA SEMANA',
                              style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1,
                                  color: AppColors.inkMuted)),
                          const SizedBox(height: 4),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink),
                              children: [
                                TextSpan(text: '$totalMinutesThisWeek minutos '),
                                const TextSpan(
                                  text: 'praticados',
                                  style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: AppColors.primary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.successSoft,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('Ativo',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.success)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 64,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(7, (i) {
                        final frac = activityFractions[i];
                        final active = frac >= 0.7;
                        return Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 3),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: FractionallySizedBox(
                                      heightFactor: frac == 0.0 ? 0.05 : frac, // Min height of 5% for visibility
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: active
                                              ? AppColors.primary
                                              : AppColors.primarySoft,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(days[i],
                                    style: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.inkMuted)),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Achievements
            const Text('CONQUISTAS RECENTES',
                style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: AppColors.inkMuted)),
            const SizedBox(height: 10),
            Row(
              children: [
                _Achievement(
                    emoji: '⭐',
                    title: 'Foco total',
                    sub: 'Ofensiva 7 dias',
                    unlocked: practiceMinutes.values.where((v) => v > 0).length >= 3),
                const SizedBox(width: 8),
                _Achievement(
                    emoji: '📖',
                    title: 'Vocabulário',
                    sub: '50 pal. salvas',
                    unlocked: total >= 50),
                const SizedBox(width: 8),
                _Achievement(
                    emoji: '🎓',
                    title: 'Mestre',
                    sub: 'Dominou 10',
                    unlocked: mastered >= 10),
              ],
            ),

            const SizedBox(height: 20),

            // Settings list
            Container(
              decoration: BoxDecoration(
                color: AppColors.bgRaised,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _SettingsRow(
                    'Lembrete diário · ${_formatReminderTime(provider.userProfile.reminderTime)}',
                    Icons.notifications_outlined,
                    0,
                    () => _pickReminderTime(context, provider),
                  ),
                  _SettingsRow(
                    'Tamanho da fonte · ${_fontSizeLabel(provider.userProfile.fontSize)}',
                    Icons.text_fields_rounded,
                    1,
                    () => _showFontSizeDialog(context, provider),
                  ),
                  _SettingsRow(
                    'Ajuda e suporte',
                    Icons.help_outline_rounded,
                    1,
                    () => _showHelpDialog(context),
                  ),
                  _SettingsRow(
                    'Refazer configuração',
                    Icons.refresh_rounded,
                    1,
                    () => _showResetOnboardingDialog(context, provider),
                    danger: true,
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

class _BigStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color bgColor;
  final Color fgColor;

  const _BigStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.bgColor,
    required this.fgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: fgColor),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: fgColor,
                    height: 1)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: fgColor.withValues(alpha: 0.8))),
          ],
        ),
      ),
    );
  }
}

class _Achievement extends StatelessWidget {
  final String emoji;
  final String title;
  final String sub;
  final bool unlocked;

  const _Achievement({
    required this.emoji,
    required this.title,
    required this.sub,
    required this.unlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Opacity(
        opacity: unlocked ? 1 : 0.45,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: unlocked ? AppColors.bgRaised : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: unlocked ? AppColors.border : AppColors.divider),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 6),
              Text(title,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink),
                  textAlign: TextAlign.center),
              const SizedBox(height: 2),
              Text(sub,
                  style: const TextStyle(
                      fontSize: 10, color: AppColors.inkMuted),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final int topBorder;
  final VoidCallback onTap;
  final bool danger;

  const _SettingsRow(
    this.label,
    this.icon,
    this.topBorder,
    this.onTap, {
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final fgColor = danger ? AppColors.error : AppColors.inkSoft;
    final textColor = danger ? AppColors.error : AppColors.ink;

    return Container(
      decoration: BoxDecoration(
        border: topBorder == 1
            ? const Border(top: BorderSide(color: AppColors.divider))
            : null,
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, size: 20, color: fgColor),
        title: Text(label,
            style: TextStyle(fontSize: 14, color: textColor)),
        trailing: Icon(Icons.chevron_right_rounded,
            size: 18, color: danger ? AppColors.error : AppColors.inkMuted),
        dense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      ),
    );
  }
}
