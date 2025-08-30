import 'dart:ui';

class Habit {
  final String id;
  final String name;
  final String emoji;
  final int targetCount;
  final String unit;
  int currentCount;
  int streakDays;
  List<DateTime> completedDates;
  Color color;

  Habit({
    required this.id,
    required this.name,
    required this.emoji,
    required this.targetCount,
    required this.unit,
    this.currentCount = 0,
    this.streakDays = 0,
    List<DateTime>? completedDates,
    required this.color,
  }) : completedDates = completedDates ?? [];

  double get progress => currentCount / targetCount;
  bool get isCompleted => currentCount >= targetCount;
  String get progressText => '$currentCount/$targetCount $unit';

  // JSON serialization için
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'emoji': emoji,
    'targetCount': targetCount,
    'unit': unit,
    'currentCount': currentCount,
    'streakDays': streakDays,
    'completedDates': completedDates.map((d) => d.toIso8601String()).toList(),
    'color': color.value,
  };

  factory Habit.fromJson(Map<String, dynamic> json) => Habit(
    id: json['id'],
    name: json['name'],
    emoji: json['emoji'],
    targetCount: json['targetCount'],
    unit: json['unit'],
    currentCount: json['currentCount'] ?? 0,
    streakDays: json['streakDays'] ?? 0,
    completedDates: (json['completedDates'] as List<dynamic>?)
        ?.map((d) => DateTime.parse(d))
        .toList() ?? [],
    color: Color(json['color']),
  );
}