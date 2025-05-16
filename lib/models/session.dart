class Session {
  final DateTime timestamp;
  final double completionPercentage;
  final int durationInSeconds;
  final bool wasCompleted;
  
  Session({
    required this.timestamp,
    required this.completionPercentage,
    required this.durationInSeconds,
    required this.wasCompleted,
  });
  
  // Convert Session to Map for storage
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'completionPercentage': completionPercentage,
      'durationInSeconds': durationInSeconds,
      'wasCompleted': wasCompleted,
    };
  }
  
  // Create Session from Map
  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      timestamp: DateTime.parse(json['timestamp']),
      completionPercentage: json['completionPercentage'],
      durationInSeconds: json['durationInSeconds'],
      wasCompleted: json['wasCompleted'],
    );
  }
}
