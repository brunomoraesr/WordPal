# M003: Audio Reading / Voice Search

**Vision:** Enhance the WordPal search experience by allowing users to speak the word they want to look up, making it faster and more accessible.

## Success Criteria

- Users can search for words using their voice.
- The app handles microphone permissions correctly on both iOS and Android.

## Slices

- [x] **S01: S01** `risk:Medium` `depends:[]`
  > After this: A microphone button in the search bar captures voice and populates the text field.

## Boundary Map

# Boundary Map

- **Search Screen**: Add a microphone button next to the search field for voice input.
- **Audio Service**: Implement a service to capture audio and convert it to text using device speech recognition.
- **Permissions**: Request microphone access on both Android and iOS.
