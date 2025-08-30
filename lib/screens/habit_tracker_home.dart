import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../services/habit_service.dart';
import '../widgets/habit_card.dart';
import '../widgets/progress_overview_card.dart';
import '../widgets/stat_card.dart';
import '../services/step_counter_service.dart';
import 'dart:math' as math;

class HabitTrackerHome extends StatefulWidget {
  const HabitTrackerHome({super.key});

  @override
  State<HabitTrackerHome> createState() => _HabitTrackerHomeState();
}

class _HabitTrackerHomeState extends State<HabitTrackerHome>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _celebrationController;
  List<Habit> habits = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _loadHabits();
    // Step counter'ı habits yüklendikten sonra başlat
    Future.delayed(const Duration(milliseconds: 500), () {
      _initStepCounter();
    });
  }

  @override
  void dispose() {
    StepCounterService.instance.stopListening();
    _tabController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  Future<void> _loadHabits() async {
    final loadedHabits = await HabitService.loadHabits();
    setState(() {
      habits = loadedHabits;
    });
  }

  Future<void> _initStepCounter() async {
    try {
      final stepService = StepCounterService.instance;
      await stepService.startListening((steps) {
        // Adım sayısı alışkanlığını güncelle
        if (habits.isNotEmpty) {
          final stepHabitIndex = habits.indexWhere((habit) => habit.id == '5');
          if (stepHabitIndex != -1) {
            setState(() {
              habits[stepHabitIndex].currentCount = steps;
            });
            HabitService.saveHabits(habits);
          }
        }
      });
    } catch (e) {
      print('Step counter başlatılamadı: $e');
      // Kullanıcıya hata mesajı göster (opsiyonel)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Adım sayacı başlatılamadı: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _incrementHabit(Habit habit) {
    setState(() {
      habit.currentCount++;
      if (habit.isCompleted && habit.currentCount == habit.targetCount) {
        _celebrationController.forward().then((_) {
          _celebrationController.reset();
        });
      }
    });
    HabitService.saveHabits(habits);
  }

  void _decrementHabit(Habit habit) {
    setState(() {
      if (habit.currentCount > 0) {
        habit.currentCount--;
      }
    });
    HabitService.saveHabits(habits);
  }

  void _resetHabit(Habit habit) {
    setState(() {
      habit.currentCount = 0;
    });
    HabitService.saveHabits(habits);
  }

  // Step counter'ı manuel başlatma fonksiyonu
  void _startStepCounter() async {
    try {
      final stepService = StepCounterService.instance;
      await stepService.startListening((steps) {
        if (habits.isNotEmpty) {
          final stepHabitIndex = habits.indexWhere((habit) => habit.id == '5');
          if (stepHabitIndex != -1) {
            setState(() {
              habits[stepHabitIndex].currentCount = steps;
            });
          }
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Adım sayacı başlatıldı!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Adım sayacı hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary.withOpacity(0.1),
              colorScheme.secondary.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(theme, colorScheme),
              _buildTabBar(),
              Expanded(child: _buildTabBarView()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Habit Tracker',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              Text(
                'Bugün ${_getCompletedHabitsCount()}/${habits.length} alışkanlık tamamlandı',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '🔥 ${_getTotalStreak()}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final colorScheme = Theme.of(context).colorScheme;
    return TabBar(
      controller: _tabController,
      labelColor: colorScheme.primary,
      unselectedLabelColor: colorScheme.onSurface.withOpacity(0.6),
      indicatorColor: colorScheme.primary,
      tabs: const [
        Tab(text: 'Bugün', icon: Icon(Icons.today)),
        Tab(text: 'İstatistik', icon: Icon(Icons.analytics)),
        Tab(text: 'Ayarlar', icon: Icon(Icons.settings)),
      ],
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildTodayView(),
        _buildStatsView(),
        _buildSettingsView(),
      ],
    );
  }

  Widget _buildTodayView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          ProgressOverviewCard(
            progress: _getOverallProgress(),
            completedCount: _getCompletedHabitsCount(),
            totalCount: habits.length,
          ),
          const SizedBox(height: 24),
          ...habits.map((habit) => HabitCard(
            habit: habit,
            onIncrement: () => _incrementHabit(habit),
            onDecrement: () => _decrementHabit(habit),
            onReset: () => _resetHabit(habit),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildStatsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Toplam Streak',
                  value: '${_getTotalStreak()} gün',
                  icon: Icons.local_fire_department,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  title: 'Tamamlanan',
                  value: '${_getCompletedHabitsCount()}/${habits.length}',
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'En İyi Streak',
                  value: '${habits.isNotEmpty ? habits.map((h) => h.streakDays).reduce(math.max) : 0} gün',
                  icon: Icons.star,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  title: 'Ortalama',
                  value: '${(_getOverallProgress() * 100).toInt()}%',
                  icon: Icons.trending_up,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsView() {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Uygulama Ayarları',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Step Counter Kontrolü
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.directions_walk),
                  title: const Text('Adım Sayacı'),
                  subtitle: const Text('Otomatik adım takibi'),
                  trailing: ElevatedButton(
                    onPressed: _startStepCounter,
                    child: const Text('Başlat'),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text('Bildirimler'),
                  subtitle: const Text('Günlük hatırlatmalar'),
                  trailing: Switch(
                      value: true,
                      onChanged: (value) {
                        // Bildirim ayarları
                      }
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.palette),
                  title: const Text('Tema'),
                  subtitle: const Text('Koyu/Açık tema'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Tema ayarları
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Debug bilgileri (development için)
          if (habits.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Debug Info',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Toplam habit sayısı: ${habits.length}'),
                    Text('Adım habit mevcut: ${habits.any((h) => h.id == '5') ? 'Evet' : 'Hayır'}'),
                    if (habits.any((h) => h.id == '5'))
                      Text('Mevcut adım: ${habits.firstWhere((h) => h.id == '5').currentCount}'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  int _getCompletedHabitsCount() {
    return habits.where((habit) => habit.isCompleted).length;
  }

  int _getTotalStreak() {
    return habits.isNotEmpty
        ? habits.map((habit) => habit.streakDays).reduce((a, b) => a + b)
        : 0;
  }

  double _getOverallProgress() {
    if (habits.isEmpty) return 0.0;
    double totalProgress = habits.map((habit) => habit.progress.clamp(0.0, 1.0)).reduce((a, b) => a + b);
    return totalProgress / habits.length;
  }
}