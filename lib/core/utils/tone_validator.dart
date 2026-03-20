class ToneValidator {
  static void validate(String text) {
    // LAW-08 enforcement
    final forbiddenWords = ['huissier', 'poursuite', 'tribunal', 'immédiat', 'mise en demeure'];
    for (final word in forbiddenWords) {
      if (text.toLowerCase().contains(word)) {
        throw Exception('LAW-08 Violation: Tone must be amiable. Forbidden word: $word');
      }
    }
  }
}
