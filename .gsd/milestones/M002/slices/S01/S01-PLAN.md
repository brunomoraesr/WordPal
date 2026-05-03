# S01: Profile Data & State

**Goal:** Implement the underlying data structures, preferences persistence, and state management for user profiles.
**Demo:** After this: Provider correctly loads default and updated profile data without UI integration yet.

## Tasks
- [x] **T01: Created UserProfile model and serialization tests.** — Create `lib/models/user_profile.dart` to store user data: name, join date, weekly practice minutes (Map of day index to minutes), and settings (reminder, pronunciation, translation). Write `test/models/user_profile_test.dart` to verify JSON serialization.
  - Estimate: 30m
  - Files: lib/models/user_profile.dart, test/models/user_profile_test.dart
  - Verify: `flutter test test/models/user_profile_test.dart` passes.
- [x] **T02: Updated PreferencesService to persist UserProfile.** — Update `lib/services/preferences_service.dart` with methods to save and load the `UserProfile`. If no profile exists, return a default one. Create/update tests if applicable.
  - Estimate: 30m
  - Files: lib/services/preferences_service.dart
  - Verify: `PreferencesService` correctly handles `UserProfile` serialization.
- [x] **T03: Added dynamic profile state management methods to AppProvider.** — Update `lib/providers/app_provider.dart` to hold the `UserProfile` state. Add methods: `updateName()`, `addPracticeMinutes()`, and methods to update individual settings. Update `test/providers/app_provider_test.dart` to verify this logic.
  - Estimate: 1h
  - Files: lib/providers/app_provider.dart, test/providers/app_provider_test.dart
  - Verify: `flutter test test/providers/app_provider_test.dart` passes and covers profile state updates.
