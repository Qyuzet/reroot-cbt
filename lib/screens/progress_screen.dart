import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/session.dart';
import '../services/storage_service.dart';
import '../services/gemini_service.dart';
import '../theme/app_theme.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> with SingleTickerProviderStateMixin {
  List<Session> _sessions = [];
  bool _isLoading = true;
  String _aiFeedback = '';
  bool _isLoadingFeedback = false;
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSessions();
  }
  
  Future<void> _loadSessions() async {
    setState(() {
      _isLoading = true;
    });
    
    final sessions = await StorageService.getSessions();
    
    setState(() {
      _sessions = sessions;
      _isLoading = false;
    });
    
    // Get AI feedback if there are sessions
    if (sessions.isNotEmpty) {
      _getAIFeedback();
    }
  }
  
  Future<void> _getAIFeedback() async {
    if (_sessions.isEmpty) return;
    
    setState(() {
      _isLoadingFeedback = true;
    });
    
    try {
      // Get the most recent session
      final latestSession = _sessions.reduce(
        (a, b) => a.timestamp.isAfter(b.timestamp) ? a : b,
      );
      
      // Get AI feedback
      final geminiService = GeminiService();
      final feedback = await geminiService.getSessionFeedback(latestSession);
      
      setState(() {
        _aiFeedback = feedback;
        _isLoadingFeedback = false;
      });
    } catch (e) {
      debugPrint('Error getting AI feedback: $e');
      setState(() {
        _aiFeedback = 'Great job on your progress! Keep up the good work.';
        _isLoadingFeedback = false;
      });
    }
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Dashboard'),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _sessions.isEmpty
              ? _buildEmptyState(theme)
              : _buildProgressDashboard(theme),
    );
  }
  
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.bar_chart,
              size: 80,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Sessions Yet',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Complete your first intervention session to start tracking your progress',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onBackground.withOpacity(0.7),
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start a Session'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProgressDashboard(ThemeData theme) {
    return Column(
      children: [
        // Tabs
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
            indicatorColor: theme.colorScheme.primary,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Analytics'),
              Tab(text: 'History'),
            ],
          ),
        ),
        
        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Overview tab
              _buildOverviewTab(theme),
              
              // Analytics tab
              _buildAnalyticsTab(theme),
              
              // History tab
              _buildHistoryTab(theme),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildOverviewTab(ThemeData theme) {
    // Calculate statistics
    final completedSessions = _sessions.where((s) => s.wasCompleted).length;
    final totalSessions = _sessions.length;
    final completionRate = totalSessions > 0
        ? (completedSessions / totalSessions) * 100
        : 0.0;
    
    // Calculate streak
    final streak = _calculateStreak();
    
    // Calculate average duration
    final avgDuration = _calculateAverageDuration();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Feedback card
          _buildAIFeedbackCard(theme),
          const SizedBox(height: 24),
          
          // Stats grid
          _buildStatsGrid(
            theme,
            totalSessions,
            completionRate,
            streak,
            avgDuration,
          ),
          const SizedBox(height: 24),
          
          // Weekly progress
          _buildWeeklyProgressCard(theme),
          const SizedBox(height: 24),
          
          // Recent sessions
          _buildRecentSessionsCard(theme),
        ],
      ),
    );
  }
  
  Widget _buildAIFeedbackCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppTheme.calmingGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.psychology,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'AI Feedback',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _isLoadingFeedback
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  _aiFeedback,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    height: 1.5,
                  ),
                ),
        ],
      ),
    );
  }
  
  Widget _buildStatsGrid(
    ThemeData theme,
    int totalSessions,
    double completionRate,
    int streak,
    int avgDuration,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Stats',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                theme,
                'Sessions',
                totalSessions.toString(),
                Icons.calendar_today,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                theme,
                'Streak',
                '$streak days',
                Icons.local_fire_department,
                Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                theme,
                'Success Rate',
                '${completionRate.toStringAsFixed(1)}%',
                Icons.check_circle_outline,
                Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                theme,
                'Avg. Duration',
                _formatDuration(avgDuration),
                Icons.timer,
                Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildStatCard(
    ThemeData theme,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios,
                color: theme.colorScheme.onSurface.withOpacity(0.3),
                size: 14,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildWeeklyProgressCard(ThemeData theme) {
    // Get last 7 days of sessions for the chart
    final last7DaysSessions = _getLast7DaysSessions();
    final days = last7DaysSessions.keys.toList()
      ..sort((a, b) => a.compareTo(b));
    
    // Calculate average completion percentage for each day
    final List<FlSpot> spots = [];
    for (int i = 0; i < days.length; i++) {
      final day = days[i];
      final sessions = last7DaysSessions[day] ?? [];
      
      if (sessions.isNotEmpty) {
        final avgCompletion = sessions.fold<double>(
          0,
          (sum, session) => sum + session.completionPercentage,
        ) / sessions.length;
        
        spots.add(FlSpot(i.toDouble(), avgCompletion));
      } else {
        spots.add(FlSpot(i.toDouble(), 0));
      }
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weekly Progress',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 220,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Completion Rate',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 20,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: theme.dividerColor.withOpacity(0.3),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= 0 && value.toInt() < days.length) {
                              final day = days[value.toInt()];
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                child: Text(
                                  DateFormat('E').format(day),
                                  style: theme.textTheme.bodySmall,
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 20,
                          getTitlesWidget: (value, meta) {
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(
                                '${value.toInt()}%',
                                style: theme.textTheme.bodySmall,
                              ),
                            );
                          },
                          reservedSize: 40,
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: false,
                    ),
                    minX: 0,
                    maxX: days.length.toDouble() - 1,
                    minY: 0,
                    maxY: 100,
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: theme.colorScheme.primary,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 4,
                              color: theme.colorScheme.primary,
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          color: theme.colorScheme.primary.withOpacity(0.2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildRecentSessionsCard(ThemeData theme) {
    // Get the 3 most recent sessions
    final recentSessions = List<Session>.from(_sessions)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp))
      ..take(3);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Sessions',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                _tabController.animateTo(2); // Switch to History tab
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...recentSessions.map((session) => _buildSessionCard(theme, session)),
      ],
    );
  }
  
  Widget _buildSessionCard(ThemeData theme, Session session) {
    final dateFormat = DateFormat('MMM d, yyyy - h:mm a');
    final formattedDate = dateFormat.format(session.timestamp);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: session.wasCompleted
                  ? Colors.green.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              session.wasCompleted ? Icons.check_circle : Icons.timelapse,
              color: session.wasCompleted ? Colors.green : Colors.orange,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.wasCompleted ? 'Completed Session' : 'Partial Session',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formattedDate,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${session.completionPercentage.toStringAsFixed(0)}%',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: session.wasCompleted ? Colors.green : Colors.orange,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatDuration(session.durationInSeconds),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildAnalyticsTab(ThemeData theme) {
    // This tab will show more detailed analytics
    return const Center(
      child: Text('Analytics coming soon!'),
    );
  }
  
  Widget _buildHistoryTab(ThemeData theme) {
    // Sort sessions by date (newest first)
    final sortedSessions = List<Session>.from(_sessions)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedSessions.length,
      itemBuilder: (context, index) {
        final session = sortedSessions[index];
        return _buildSessionCard(theme, session);
      },
    );
  }
  
  // Helper methods
  Map<DateTime, List<Session>> _getLast7DaysSessions() {
    final Map<DateTime, List<Session>> sessionsByDay = {};
    
    // Initialize the last 7 days
    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final day = DateTime(
        now.year,
        now.month,
        now.day - i,
      );
      sessionsByDay[day] = [];
    }
    
    // Group sessions by day
    for (final session in _sessions) {
      final sessionDay = DateTime(
        session.timestamp.year,
        session.timestamp.month,
        session.timestamp.day,
      );
      
      // Only include sessions from the last 7 days
      if (now.difference(sessionDay).inDays < 7) {
        sessionsByDay[sessionDay] ??= [];
        sessionsByDay[sessionDay]!.add(session);
      }
    }
    
    return sessionsByDay;
  }
  
  int _calculateStreak() {
    if (_sessions.isEmpty) return 0;
    
    // Sort sessions by date
    final sortedSessions = List<Session>.from(_sessions)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    // Group sessions by day
    final Map<String, bool> sessionsByDay = {};
    for (final session in sortedSessions) {
      final day = DateFormat('yyyy-MM-dd').format(session.timestamp);
      sessionsByDay[day] = true;
    }
    
    // Calculate current streak
    int streak = 0;
    final now = DateTime.now();
    
    for (int i = 0; i < 100; i++) { // Limit to 100 days to avoid infinite loop
      final day = DateFormat('yyyy-MM-dd').format(
        now.subtract(Duration(days: i)),
      );
      
      if (sessionsByDay.containsKey(day)) {
        streak++;
      } else if (i > 0) { // Skip today if no session
        break;
      }
    }
    
    return streak;
  }
  
  int _calculateAverageDuration() {
    if (_sessions.isEmpty) return 0;
    
    final totalDuration = _sessions.fold<int>(
      0,
      (sum, session) => sum + session.durationInSeconds,
    );
    
    return totalDuration ~/ _sessions.length;
  }
  
  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    
    if (minutes > 0) {
      return '${minutes}m ${remainingSeconds}s';
    } else {
      return '${remainingSeconds}s';
    }
  }
}
