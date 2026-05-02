import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final total = provider.savedWords.length;
    final mastered = provider.savedWords.where((w) => w.mastered).length;
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final activity = [0.6, 0.9, 0.4, 0.8, 1.0, 0.7, 0.3];

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
                  child: const Text('M',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Maria Almeida',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                              letterSpacing: -0.4)),
                      SizedBox(height: 3),
                      Text('Intermediate · Level B2 · Joined March 2026',
                          style: TextStyle(
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
                    label: 'Searches',
                    bgColor: AppColors.accentSoft,
                    fgColor: AppColors.accent),
                const SizedBox(width: 10),
                _BigStat(
                    icon: Icons.menu_book_rounded,
                    value: '$total',
                    label: 'Words saved',
                    bgColor: AppColors.primarySoft,
                    fgColor: AppColors.primary),
                const SizedBox(width: 10),
                _BigStat(
                    icon: Icons.star_rounded,
                    value: '$mastered',
                    label: 'Mastered',
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
                          const Text('THIS WEEK',
                              style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1,
                                  color: AppColors.inkMuted)),
                          const SizedBox(height: 4),
                          RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink),
                              children: [
                                TextSpan(text: '23 minutes '),
                                TextSpan(
                                  text: 'practiced',
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
                        child: const Text('+18%',
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
                        final active = activity[i] >= 0.7;
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
                                      heightFactor: activity[i],
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
            const Text('RECENT ACHIEVEMENTS',
                style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: AppColors.inkMuted)),
            const SizedBox(height: 10),
            Row(
              children: [
                const _Achievement(
                    emoji: '⭐',
                    title: 'Week strong',
                    sub: '7 day streak',
                    unlocked: true),
                const SizedBox(width: 8),
                _Achievement(
                    emoji: '📖',
                    title: 'Wordsmith',
                    sub: '50 words saved',
                    unlocked: total >= 50),
                const SizedBox(width: 8),
                const _Achievement(
                    emoji: '🎓',
                    title: 'Scholar',
                    sub: 'C2 word learned',
                    unlocked: false),
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
              child: const Column(
                children: [
                  _SettingsRow('Daily reminder · 8:00 AM',
                      Icons.notifications_outlined, 0, true),
                  _SettingsRow('Pronunciation · British English',
                      Icons.volume_up_outlined, 1, true),
                  _SettingsRow('Translation · Português (BR)',
                      Icons.translate_rounded, 1, true),
                  _SettingsRow(
                      'Help & support', Icons.help_outline_rounded, 1, false),
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
  final bool showChevron;

  const _SettingsRow(this.label, this.icon, this.topBorder, this.showChevron);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: topBorder == 1
            ? const Border(top: BorderSide(color: AppColors.divider))
            : null,
      ),
      child: ListTile(
        leading: Icon(icon, size: 20, color: AppColors.inkSoft),
        title: Text(label,
            style: const TextStyle(fontSize: 14, color: AppColors.ink)),
        trailing: showChevron
            ? const Icon(Icons.chevron_right_rounded,
                size: 18, color: AppColors.inkMuted)
            : null,
        dense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      ),
    );
  }
}
