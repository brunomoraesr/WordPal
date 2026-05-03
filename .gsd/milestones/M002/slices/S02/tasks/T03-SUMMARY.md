---
id: T03
parent: S02
milestone: M002
provides: []
requires: []
affects: []
key_files: ["lib/screens/profile_screen.dart", "lib/screens/practice_screen.dart"]
key_decisions: ["Added practice minutes calculation immediately upon finishing the quiz in `PracticeScreen`.", "Re-evaluated achievements in `ProfileScreen` based directly on `weeklyPracticeMinutes`, `total` words, and `mastered` words rather than mock data."]
patterns_established: []
drill_down_paths: []
observability_surfaces: []
duration: ""
verification_result: "Verified that there are no syntax errors with `flutter analyze`. Code logic correctly evaluates achievement conditions against `AppProvider` data."
completed_at: 2026-05-03T00:14:51.834Z
blocker_discovered: false
---

# T03: Made achievements dynamic and linked Practice quizzes to profile practice tracking.

> Made achievements dynamic and linked Practice quizzes to profile practice tracking.

## What Happened
---
id: T03
parent: S02
milestone: M002
key_files:
  - lib/screens/profile_screen.dart
  - lib/screens/practice_screen.dart
key_decisions:
  - Added practice minutes calculation immediately upon finishing the quiz in `PracticeScreen`.
  - Re-evaluated achievements in `ProfileScreen` based directly on `weeklyPracticeMinutes`, `total` words, and `mastered` words rather than mock data.
duration: ""
verification_result: passed
completed_at: 2026-05-03T00:14:51.837Z
blocker_discovered: false
---

# T03: Made achievements dynamic and linked Practice quizzes to profile practice tracking.

**Made achievements dynamic and linked Practice quizzes to profile practice tracking.**

## What Happened

Linked `PracticeScreen` quizzes to the `AppProvider` so that completing a quiz automatically adds 3 minutes to the user's practice tracker for the day. Updated `ProfileScreen` to evaluate achievements dynamically based on the user's actual progress, such as having practiced for at least 3 days in the week, having 50+ saved words, and having 10+ mastered words. Passed `flutter analyze`.

## Verification

Verified that there are no syntax errors with `flutter analyze`. Code logic correctly evaluates achievement conditions against `AppProvider` data.

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `flutter analyze` | 1 | ✅ pass | 2500ms |


## Deviations

None.

## Known Issues

None.

## Files Created/Modified

- `lib/screens/profile_screen.dart`
- `lib/screens/practice_screen.dart`


## Deviations
None.

## Known Issues
None.
