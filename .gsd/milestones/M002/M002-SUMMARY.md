---
id: M002
title: "Dynamic Profile & Settings"
status: complete
completed_at: 2026-05-03T00:24:55.107Z
key_decisions:
  - Saved practice minutes by aggregating them per weekday string, ensuring the chart is trivially populated without expensive aggregations during UI build.
  - Set default values in `UserProfile` to guarantee a seamless first-time startup experience without null checks.
key_files:
  - lib/models/user_profile.dart
  - lib/services/preferences_service.dart
  - lib/providers/app_provider.dart
  - lib/screens/profile_screen.dart
  - lib/screens/practice_screen.dart
lessons_learned:
  - `AnimatedContainer` and implicit animations continue to excel for simple settings UI.
  - Using immutable state transitions with `copyWith` on data models prevents unpredictable provider errors.
---

# M002: Dynamic Profile & Settings

**Refactored the Profile screen to replace mock data with an interactive and persistent UserProfile state.**

## What Happened

Successfully completed **M002: Dynamic Profile & Settings**. The milestone replaced all static mock data inside the `ProfileScreen` with a persistent, dynamic state stored via `SharedPreferences`. Slice S01 provided the `UserProfile` model and tested serialization logic. Slice S02 connected the UI seamlessly, allowing the user to rename their profile, view real practice activity driven by `PracticeScreen` quizzes, and configure dynamic settings for Reminders, Pronunciation, and Translations.

## Success Criteria Results

- **Profile name can be edited and is persisted:** Yes, dialog added and state managed via SharedPreferences.
- **"Minutes practiced" updates based on app usage:** Yes, completing a quiz logs 3 minutes of practice.
- **Achievements reflect actual progress:** Yes, achievements unlock conditionally based on provider stats.
- **Settings options have functional UI:** Yes, dialog pickers and toggles were added.

## Definition of Done Results

- **Profile name and settings are persistent:** Used `SharedPreferences` via `PreferencesService` to persist data, proven by S01 tests.
- **Practice minutes are tracked and displayed:** The `PracticeScreen` adds minutes on quiz completion, and `ProfileScreen` renders this dynamically on a week chart.
- **Achievements unlock dynamically:** Conditions changed to use provider data.
- **User can edit their name:** An edit button on ProfileScreen brings up an `AlertDialog` to update the name safely.

## Requirement Outcomes

Advanced the project by introducing user personalization and gamification tracking, making the application feel like a fully realized product.

## Deviations

Instead of tracking specific practice sessions with timestamps, we grouped them into simple buckets by day of the week ('M', 'T', 'W', etc.) to keep the `UserProfile` lightweight and suited for the 7-day display chart.

## Follow-ups

Implement deep linking for the "Help & Support" to open an actual email client or browser. Build actual settings behavior into the Audio player to use the "Pronunciation Accent" setting.
