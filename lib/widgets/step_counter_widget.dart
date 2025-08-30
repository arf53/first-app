import 'package:flutter/material.dart';
import '../services/step_counter_service.dart';

class StepCounterWidget extends StatefulWidget {
  final Function(int steps)? onStepUpdate;

  const StepCounterWidget({
    super.key,
    this.onStepUpdate,
  });

  @override
  State<StepCounterWidget> createState() => _StepCounterWidgetState();
}

class _StepCounterWidgetState extends State<StepCounterWidget> {
  final StepCounterService _stepService = StepCounterService.instance;
  int _currentSteps = 0;
  bool _isListening = false;
  String _status = 'Başlatılmadı';

  @override
  void initState() {
    super.initState();
    _currentSteps = _stepService.todaySteps;
  }

  Future<void> _startStepCounting() async {
    try {
      setState(() {
        _status = 'Başlatılıyor...';
      });

      await _stepService.startListening((steps) {
        setState(() {
          _currentSteps = steps;
          _isListening = true;
          _status = 'Aktif';
        });
        widget.onStepUpdate?.call(steps);
      });

      setState(() {
        _isListening = true;
        _status = 'Aktif';
      });
    } catch (e) {
      setState(() {
        _status = 'Hata: $e';
      });
    }
  }

  void _stopStepCounting() {
    _stepService.stopListening();
    setState(() {
      _isListening = false;
      _status = 'Durduruldu';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isListening ? Colors.green : colorScheme.outline.withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text('👟', style: TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Adım Sayısı',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _isListening ? Colors.green : Colors.orange,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _status,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '$_currentSteps/10000 adım',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Progress
          LinearProgressIndicator(
            value: (_currentSteps / 10000).clamp(0.0, 1.0),
            backgroundColor: colorScheme.outline.withOpacity(0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
            minHeight: 8,
          ),

          const SizedBox(height: 16),

          // Step Display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.red, Colors.pink],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  '$_currentSteps',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'BUGÜN',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Control Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Start/Stop Button
              ElevatedButton.icon(
                onPressed: _isListening ? _stopStepCounting : _startStepCounting,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isListening ? Colors.red : Colors.green,
                  foregroundColor: Colors.white,
                ),
                icon: Icon(_isListening ? Icons.stop : Icons.play_arrow),
                label: Text(_isListening ? 'Durdur' : 'Başlat'),
              ),

              // Manual Add (Test için)
              ElevatedButton.icon(
                onPressed: () {
                  _stepService.addManualSteps(100);
                  setState(() {
                    _currentSteps = _stepService.todaySteps;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  foregroundColor: Colors.blue,
                  elevation: 0,
                ),
                icon: const Icon(Icons.add),
                label: const Text('+100'),
              ),

              // Reset
              ElevatedButton.icon(
                onPressed: () {
                  _stepService.resetToday();
                  setState(() {
                    _currentSteps = 0;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.withOpacity(0.1),
                  foregroundColor: Colors.orange,
                  elevation: 0,
                ),
                icon: const Icon(Icons.refresh),
                label: const Text('Reset'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}