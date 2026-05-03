# S02: Profile Screen Integration

**Goal:** Connect the Profile screen UI to the dynamic profile state, replacing all mock data.
**Demo:** After this: Profile screen displays real stats, allows editing the username, and updates the UI instantly.

## Tasks
- [x] **T01: Replaced mock user data with dynamic ProfileState values in ProfileScreen.** — Refactor `ProfileScreen` to display dynamic data from `AppProvider`: name, joined date, searches, total words, mastered words, and the practice minutes chart. The chart should scale relative to the maximum minutes practiced in the week.
  - Estimate: 1h 30m
  - Files: lib/screens/profile_screen.dart
  - Verify: Profile screen reflects actual state when run in emulator.
- [x] **T02: Added an interactive dialog to edit the user's name on the Profile screen.** — Add an `IconButton` (pencil) next to the user's name and create a dialog to edit it using `AppProvider.updateName()`. Update the UI upon saving.
  - Estimate: 30m
  - Files: lib/screens/profile_screen.dart
  - Verify: Name can be edited and is persisted.
- [x] **T03: Made achievements dynamic and linked Practice quizzes to profile practice tracking.** — Refactor achievements in `ProfileScreen` to evaluate dynamically. e.g., 'Wordsmith' unlocks if total words >= 50. Add a new `addPracticeMinutes()` call to `PracticeScreen` at the end of a quiz, simulating a session duration (e.g. 3 mins).
  - Estimate: 1h
  - Files: lib/screens/profile_screen.dart, lib/screens/practice_screen.dart
  - Verify: Completing a quiz increments the practice chart in Profile. Achievements unlock dynamically.
- [x] **T04: Made profile settings rows interactive with dialogs and toggles.** — Make the settings rows interactive. Allow toggling daily reminders, and picking pronunciation accents and translation languages. Add a simple dialog for "Help & support".
  - Estimate: 1h
  - Files: lib/screens/profile_screen.dart
  - Verify: Settings update visually and trigger `AppProvider` methods.
