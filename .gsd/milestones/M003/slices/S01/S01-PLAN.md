# S01: Speech-to-Text Search

**Goal:** Integrate speech_to_text for voice search on the Search screen.
**Demo:** A microphone button in the search bar captures voice and populates the text field.

## Must-Haves

- `speech_to_text` and `permission_handler` are added.
- iOS `Info.plist` and Android `AndroidManifest.xml` have microphone permissions.
- `search_screen.dart` features a working microphone button.
- Voice input correctly translates to text and populates the search bar.

## Proof Level

- This slice proves: Fully working integration in the app.

## Integration Closure

Users will be able to search using the microphone button on the search screen, sending audio to text which triggers a word lookup.

## Verification

- Log errors related to microphone permissions and speech recognition initialization.

## Tasks

- [x] **T01: Dependencies & Permissions** `est:30m`
  Add `speech_to_text` and `permission_handler` to `pubspec.yaml` and configure native OS permissions (`AndroidManifest.xml` and `Info.plist`).
  - Files: `pubspec.yaml`, `android/app/src/main/AndroidManifest.xml`, `ios/Runner/Info.plist`
  - Verify: flutter pub get; flutter build apk

- [x] **T02: Speech Recognition UI and Logic** `est:45m`
  Update `search_screen.dart` with a new mic icon button that requests microphone permissions and captures audio input to populate the text field.
  - Files: `lib/screens/search_screen.dart`
  - Verify: flutter analyze; flutter test

## Files Likely Touched

- pubspec.yaml
- android/app/src/main/AndroidManifest.xml
- ios/Runner/Info.plist
- lib/screens/search_screen.dart
