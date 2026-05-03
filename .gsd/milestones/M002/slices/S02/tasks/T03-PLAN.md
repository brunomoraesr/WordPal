---
estimated_steps: 1
estimated_files: 2
skills_used: []
---

# T03: Dynamic Achievements & Practice Linking

Refactor achievements in `ProfileScreen` to evaluate dynamically. e.g., 'Wordsmith' unlocks if total words >= 50. Add a new `addPracticeMinutes()` call to `PracticeScreen` at the end of a quiz, simulating a session duration (e.g. 3 mins).

## Inputs

- `lib/screens/profile_screen.dart`
- `lib/screens/practice_screen.dart`

## Expected Output

- `lib/screens/profile_screen.dart`
- `lib/screens/practice_screen.dart`

## Verification

Completing a quiz increments the practice chart in Profile. Achievements unlock dynamically.

## Observability Impact

None
