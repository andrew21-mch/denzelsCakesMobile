class TrainingPeriod {
  final String id;
  final String title;
  final String months;
  final String description;
  final List<String> topics;
  final bool isCurrentPeriod;
  final String status; // 'upcoming', 'current', 'completed'

  const TrainingPeriod({
    required this.id,
    required this.title,
    required this.months,
    required this.description,
    required this.topics,
    this.isCurrentPeriod = false,
    this.status = 'upcoming',
  });

  factory TrainingPeriod.fromMap(Map<String, dynamic> map) {
    return TrainingPeriod(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      months: map['months'] ?? '',
      description: map['description'] ?? '',
      topics: List<String>.from(map['topics'] ?? []),
      isCurrentPeriod: map['isCurrentPeriod'] ?? false,
      status: map['status'] ?? 'upcoming',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'months': months,
      'description': description,
      'topics': topics,
      'isCurrentPeriod': isCurrentPeriod,
      'status': status,
    };
  }

  TrainingPeriod copyWith({
    String? id,
    String? title,
    String? months,
    String? description,
    List<String>? topics,
    bool? isCurrentPeriod,
    String? status,
  }) {
    return TrainingPeriod(
      id: id ?? this.id,
      title: title ?? this.title,
      months: months ?? this.months,
      description: description ?? this.description,
      topics: topics ?? this.topics,
      isCurrentPeriod: isCurrentPeriod ?? this.isCurrentPeriod,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'TrainingPeriod(id: $id, title: $title, months: $months, description: $description, topics: $topics, isCurrentPeriod: $isCurrentPeriod, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TrainingPeriod &&
        other.id == id &&
        other.title == title &&
        other.months == months &&
        other.description == description &&
        other.topics == topics &&
        other.isCurrentPeriod == isCurrentPeriod &&
        other.status == status;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        months.hashCode ^
        description.hashCode ^
        topics.hashCode ^
        isCurrentPeriod.hashCode ^
        status.hashCode;
  }
}
