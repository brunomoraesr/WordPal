---
estimated_steps: 1
estimated_files: 3
skills_used: []
---

# T01: Dependencies & Permissions

Add `speech_to_text` and `permission_handler` to `pubspec.yaml` and configure native OS permissions (`AndroidManifest.xml` and `Info.plist`).

## Inputs

- `pubspec.yaml`

## Expected Output

- `pubspec.yaml`
- `android/app/src/main/AndroidManifest.xml`
- `ios/Runner/Info.plist`

## Verification

flutter pub get; flutter build apk

## Observability Impact

Ensure build still succeeds after adding plugins.
