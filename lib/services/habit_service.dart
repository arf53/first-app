import '../models/habit.dart';
import 'package:flutter/material.dart';

class HabitService {
  static List<Habit> getDefaultHabits() {
    return [
      Habit(
        id: '1',
        name: 'Su İçme',
        emoji: '💧',
        targetCount: 8,
        unit: 'bardak',
        color: Colors.blue,
        streakDays: 3,
      ),
      Habit(
        id: '2',
        name: 'Egzersiz',
        emoji: '🏃‍♂️',
        targetCount: 30,
        unit: 'dakika',
        color: Colors.green,
        streakDays: 7,
      ),
      Habit(
        id: '3',
        name: 'Kitap Okuma',
        emoji: '📚',
        targetCount: 30,
        unit: 'sayfa',
        color: Colors.orange,
        streakDays: 5,
      ),
      Habit(
        id: '4',
        name: 'Meditasyon',
        emoji: '🧘‍♀️',
        targetCount: 10,
        unit: 'dakika',
        color: Colors.purple,
        streakDays: 2,
      ),
      Habit(
        id: '5',
        name: 'Adım Sayısı',
        emoji: '👟',
        targetCount: 10000,
        unit: 'adım',
        color: Colors.red,
        streakDays: 12,
      ),
    ];
  }

  // SharedPreferences ile veri kaydetme/yükleme
  static Future<void> saveHabits(List<Habit> habits) async {
    // SharedPreferences implementation
  }

  static Future<List<Habit>> loadHabits() async {
    // SharedPreferences implementation
    return getDefaultHabits();
  }
}