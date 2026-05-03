---
id: T01
parent: S01
milestone: M002
provides: []
requires: []
affects: []
key_files: ["lib/models/user_profile.dart", "test/models/user_profile_test.dart"]
key_decisions: ["Used a simple Map<String, int> to store practice minutes per day.", "Included default values for all profile fields so the app works seamlessly on first launch."]
patterns_established: []
drill_down_paths: []
observability_surfaces: []
duration: ""
verification_result: "Ran `flutter test test/models/user_profile_test.dart` which passed all 4 test cases."
completed_at: 2026-05-02T23:39:53.756Z
blocker_discovered: false
---

# T01: Created UserProfile model and serialization tests.

> Created UserProfile model and serialization tests.

## What Happened
---
id: T01
parent: S01
milestone: M002
key_files:
  - lib/models/user_profile.dart
  - test/models/user_profile_test.dart
key_decisions:
  - Used a simple Map<String, int> to store practice minutes per day.
  - Included default values for all profile fields so the app works seamlessly on first launch.
duration: ""
verification_result: passed
completed_at: 2026-05-02T23:39:53.775Z
blocker_discovered: false
---

# T01: Created UserProfile model and serialization tests.

**Created UserProfile model and serialization tests.**

## What Happened

Created the `UserProfile` model with serialization methods (`toMap`, `fromMap`) and a `defaultProfile` factory. Added unit tests in `test/models/user_profile_test.dart` to verify serialization and state copying via `copyWith`. All tests pass.

## Verification

Ran `flutter test test/models/user_profile_test.dart` which passed all 4 test cases.

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `flutter test test/models/user_profile_test.dart` | 0 | ✅ pass | 1000ms |


## Deviations

None.

## Known Issues

None.

## Files Created/Modified

- `lib/models/user_profile.dart`
- `test/models/user_profile_test.dart`


## Deviations
None.

## Known Issues
None.
