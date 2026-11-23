/// Short meaning of dictionary words, keyed by the word as it is in `dicio`.
///
/// The app has no meanings yet. Until it does, this map stays empty and the
/// UI shows only the word: no empty card, no "no meaning" text.
const definitions = <String, String>{};

String? meaningOf(String word) => definitions[word.toUpperCase()];
