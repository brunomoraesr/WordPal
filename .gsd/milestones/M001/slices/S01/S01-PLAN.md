# S01: Testing Foundation

**Goal:** Establish a baseline testing foundation to catch regressions before any major refactoring begins.
**Demo:** After this: A green test suite output from `flutter test`.

## Tasks
- [x] **T01: Added test dependencies and verified the test runner.** — Add `flutter_test` and `mockito` (if needed) to `pubspec.yaml`, run `flutter pub get`, and create the `test/` directory. Create a dummy test to ensure the test runner works.
  - Estimate: 15m
  - Files: pubspec.yaml
  - Verify: `flutter test` passes successfully.
- [x] **T02: Refactored AppProvider for DI and wrote comprehensive unit tests.** — Create `test/providers/app_provider_test.dart` and write tests covering basic state initialization and updates. Use mocking for the API service if required.
  - Estimate: 1h
  - Files: lib/providers/app_provider.dart, test/providers/app_provider_test.dart
  - Verify: `flutter test test/providers/app_provider_test.dart` passes.
- [x] **T03: Wrote model tests for WordEntry and SavedWord serialization.** — Create `test/models/word_entry_test.dart` and `test/models/saved_word_test.dart` to verify JSON serialization and deserialization.
  - Estimate: 30m
  - Files: lib/models/word_entry.dart, lib/models/saved_word.dart, test/models/word_entry_test.dart, test/models/saved_word_test.dart
  - Verify: `flutter test test/models/` passes.
