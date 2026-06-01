class CookStep {
  final int order;
  final String instruction;
  final int? durationSeconds;
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
