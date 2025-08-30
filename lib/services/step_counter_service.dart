import 'dart:async';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StepCounterService {
  static StepCounterService? _instance;
  static StepCounterService get instance => _instance ??= StepCounterService._();
  StepCounterService._();

  Stream<StepCount>? _stepCountStream;
  StreamSubscription<StepCount>? _stepSubscription;

  int _todaySteps = 0;
  int _baselineSteps = 0;
  DateTime? _lastResetDate;

  int get todaySteps => _todaySteps;

  Future<bool> requestPermissions() async {
    if (await Permission.activityRecognition.request().isGranted) {
      return true;
    }
    return false;
  }

  Future<void> startListening(Function(int steps) onStepUpdate) async {
    await _loadSavedData();

    if (!await requestPermissions()) {
      throw Exception('Adım sayısı izni reddedildi');
    }

    _stepCountStream = Pedometer.stepCountStream;
    _stepSubscription = _stepCountStream?.listen(
          (StepCount event) async {
        await _handleStepCount(event);
        onStepUpdate(_todaySteps);
      },
      onError: (error) {
        print('Pedometer Error: $error');
      },
    );
  }

  Future<void> _handleStepCount(StepCount stepCount) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Yeni gün kontrolü
    if (_lastResetDate == null || _lastResetDate!.isBefore(today)) {
      _baselineSteps = stepCount.steps;
      _lastResetDate = today;
      _todaySteps = 0;
      await _saveData();
      return;
    }

    // Bugünün adımlarını hesapla
    _todaySteps = stepCount.steps - _baselineSteps;
    if (_todaySteps < 0) _todaySteps = 0;

    await _saveData();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    _todaySteps = prefs.getInt('today_steps') ?? 0;
    _baselineSteps = prefs.getInt('baseline_steps') ?? 0;

    final lastResetString = prefs.getString('last_reset_date');
    if (lastResetString != null) {
      _lastResetDate = DateTime.parse(lastResetString);
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('today_steps', _todaySteps);
    await prefs.setInt('baseline_steps', _baselineSteps);
    if (_lastResetDate != null) {
      await prefs.setString('last_reset_date', _lastResetDate!.toIso8601String());
    }
  }

  void stopListening() {
    _stepSubscription?.cancel();
  }

  // Manuel adım ekleme (test için)
  void addManualSteps(int steps) {
    _todaySteps += steps;
    _saveData();
  }

  // Bugünü sıfırla
  void resetToday() {
    _todaySteps = 0;
    _saveData();
  }
}