# S02: State Management & UI Polish

**Goal:** Refactor the state management and polish UI components across the main screens.
**Demo:** After this: A running app with smoother navigation and cleaner UI code.

## Tasks
- [ ] **T01: Refactor AppProvider** — Review `lib/providers/app_provider.dart`. Simplify state updates, add better error handling, and ensure the UI isn't unnecessarily rebuilt. Update tests to reflect any changes.
  - Estimate: 1h 30m
  - Files: lib/providers/app_provider.dart
  - Verify: `flutter test` passes and state updates correctly in the app.
- [ ] **T02: Polish Search & Detail Screens** — Review `SearchScreen` and `WordDetailScreen`. Improve typography, adjust padding/margins, and ensure smooth animations/transitions when searching or navigating.
  - Estimate: 1h 30m
  - Files: lib/screens/search_screen.dart, lib/screens/word_detail_screen.dart, lib/theme/app_theme.dart
  - Verify: Manual review of the search flow and word details UI.
- [ ] **T03: Polish Notebook, Flashcards & Practice** — Review `NotebookScreen`, `FlashcardsScreen`, and `PracticeScreen`. Polish the 3D flip animations, ensure lists scroll smoothly, and improve feedback states (success/error in practice).
  - Estimate: 2h
  - Files: lib/screens/notebook_screen.dart, lib/screens/flashcards_screen.dart, lib/screens/practice_screen.dart
  - Verify: Manual review of Notebook interactions, Flashcard flips, and Practice quiz flow.
- [ ] **T04: End-to-End Verification & UAT** — Perform a full walkthrough of the app. Test SQLite saves/deletes, check SharedPreferences history, and ensure the profile stats update correctly.
  - Estimate: 1h
  - Files: lib/main.dart
  - Verify: All app flows work flawlessly on emulator or device.
