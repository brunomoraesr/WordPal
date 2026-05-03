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
        title: const Text('Edit name',
            style: TextStyle(
                fontFamily: 'Fraunces',
                fontSize: 20,
                fontWeight: FontWeight.w400)),
        content: TextField(
          controller: controller,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: 'Enter your name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.inkMuted)),
          ),
          TextButton(
            onPressed: () {
              provider.updateName(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Save',
                style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _showAccentDialog(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgRaised,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Pronunciation', style: TextStyle(fontFamily: 'Fraunces', fontSize: 20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['American English', 'British English', 'Australian English']
              .map((accent) => RadioListTile(
                    title: Text(accent, style: const TextStyle(color: AppColors.ink)),
                    value: accent,
                    groupValue: provider.userProfile.pronunciationAccent,
                    onChanged: (value) {
                      if (value != null) provider.updatePronunciationAccent(value);
                      Navigator.pop(context);
                    },
                    activeColor: AppColors.primary,
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _showTranslationDialog(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgRaised,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Translation', style: TextStyle(fontFamily: 'Fraunces', fontSize: 20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Português (BR)', 'Español', 'Français']
              .map((lang) => RadioListTile(
                    title: Text(lang, style: const TextStyle(color: AppColors.ink)),
                    value: lang,
                    groupValue: provider.userProfile.translationLanguage,
                    onChanged: (value) {
                      if (value != null) provider.updateTranslationLanguage(value);
                      Navigator.pop(context);
                    },
                    activeColor: AppColors.primary,
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgRaised,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Help & Support', style: TextStyle(fontFamily: 'Fraunces', fontSize: 20)),
        content: const Text('For support, please email support@wordpal.app or visit our website.',
            style: TextStyle(color: AppColors.inkSoft)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: AppColors.primary)),
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
                      Text('Intermediate · Level B2 · Joined $joinedStr',
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
                            text: TextSpan(
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink),
                              children: [
                                TextSpan(text: '$totalMinutesThisWeek minutes '),
                                const TextSpan(
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
                        child: const Text('Active',
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
                _Achievement(
                    emoji: '⭐',
                    title: 'Week strong',
                    sub: '7 day streak',
                    unlocked: practiceMinutes.values.where((v) => v > 0).length >= 3),
                const SizedBox(width: 8),
                _Achievement(
                    emoji: '📖',
                    title: 'Wordsmith',
                    sub: '50 words saved',
                    unlocked: total >= 50),
                const SizedBox(width: 8),
                _Achievement(
                    emoji: '🎓',
                    title: 'Scholar',
                    sub: 'Master 10 words',
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
                    'Daily reminder · 8:00 AM',
                    Icons.notifications_outlined,
                    0,
                    provider.userProfile.dailyReminder,
                    () => provider.toggleDailyReminder(),
                  ),
                  _SettingsRow(
                    'Pronunciation · ${provider.userProfile.pronunciationAccent}',
                    Icons.volume_up_outlined,
                    1,
                    true,
                    () => _showAccentDialog(context, provider),
                  ),
                  _SettingsRow(
                    'Translation · ${provider.userProfile.translationLanguage}',
                    Icons.translate_rounded,
                    1,
                    true,
                    () => _showTranslationDialog(context, provider),
                  ),
                  _SettingsRow(
                    'Help & support',
                    Icons.help_outline_rounded,
                    1,
                    true,
                    () => _showHelpDialog(context),
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
  final bool value;
  final VoidCallback onTap;

  const _SettingsRow(this.label, this.icon, this.topBorder, this.value, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: topBorder == 1
            ? const Border(top: BorderSide(color: AppColors.divider))
            : null,
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, size: 20, color: AppColors.inkSoft),
        title: Text(label,
            style: const TextStyle(fontSize: 14, color: AppColors.ink)),
        trailing: icon == Icons.notifications_outlined
            ? Switch.adaptive(
                value: value,
                onChanged: (v) => onTap(),
                activeColor: AppColors.primary,
              )
            : const Icon(Icons.chevron_right_rounded,
                size: 18, color: AppColors.inkMuted),
        dense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      ),
    );
  }
}
