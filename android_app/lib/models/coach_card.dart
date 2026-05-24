class CoachCard {
  final String severity;
  final String title;
  final String message;

  CoachCard({required this.severity, required this.title, required this.message});

  factory CoachCard.fromJson(Map<String, dynamic> json) {
    return CoachCard(
      severity: (json['severity'] ?? 'tactical').toString(),
      title: (json['title'] ?? 'Coach').toString(),
      message: (json['message'] ?? '').toString(),
    );
  }
}
