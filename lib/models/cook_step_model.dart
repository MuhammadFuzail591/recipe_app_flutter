// A single step in the playable cook-along mode.
//
// Produced by the LLM from the raw recipe instructions. See
// `lib/services/cook_mode_service.dart` for the schema we lock the model to.
class CookStep {
  final int order;
  final String instruction;
  // Null when the step has no implied duration (e.g. "season to taste").
  // The UI shows "Tap Next when done" instead of a countdown.
  final int? durationSeconds;
  // Optional short verb hint (chop, simmer, fry...). May be null.
  final String? verb;

  CookStep({
    required this.order,
    required this.instruction,
    this.durationSeconds,
    this.verb,
  });

  factory CookStep.fromMap(Map<String, dynamic> map) {
    return CookStep(
      order: map["order"] as int,
      instruction: map["instruction"] as String,
      durationSeconds: map["durationSeconds"] as int?,
      verb: map["verb"] as String?,
    );
  }
}
