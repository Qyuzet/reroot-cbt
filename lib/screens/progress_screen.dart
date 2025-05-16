import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/session.dart';
import '../services/storage_service.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  List<Session> _sessions = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
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
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Dashboard'),
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
          Icon(
            Icons.bar_chart,
            size: 80,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No sessions yet',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Complete your first intervention session\nto start tracking your progress',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProgressDashboard(ThemeData theme) {
    // Calculate statistics
    final completedSessions = _sessions.where((s) => s.wasCompleted).length;
    final totalSessions = _sessions.length;
    final completionRate = totalSessions > 0
        ? (completedSessions / totalSessions) * 100
        : 0.0;
    
    // Get last 7 days of sessions for the chart
    final last7DaysSessions = _getLast7DaysSessions();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary cards
          _buildSummaryCards(theme, completedSessions, totalSessions, completionRate),
          const SizedBox(height: 24),
          
          // Weekly chart
          _buildWeeklyChart(theme, last7DaysSessions),
          const SizedBox(height: 24),
          
          // Session history
          _buildSessionHistory(theme),
        ],
      ),
    );
  }
  
  Widget _buildSummaryCards(
    ThemeData theme,
    int completedSessions,
    int totalSessions,
    double completionRate,
  ) {
    return Row(
      children: [
        // Total sessions card
        Expanded(
          child: _buildSummaryCard(
            theme,
            'Total Sessions',
            totalSessions.toString(),
            Icons.calendar_today,
            theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 16),
        
        // Completion rate card
        Expanded(
          child: _buildSummaryCard(
            theme,
            'Completion Rate',
            '${completionRate.toStringAsFixed(1)}%',
            Icons.check_circle,
            theme.colorScheme.secondary,
          ),
        ),
      ],
    );
  }
  
  Widget _buildSummaryCard(
    ThemeData theme,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildWeeklyChart(ThemeData theme, Map<DateTime, List<Session>> sessionsByDay) {
    final days = sessionsByDay.keys.toList()
      ..sort((a, b) => a.compareTo(b));
    
    // Calculate average completion percentage for each day
    final List<FlSpot> spots = [];
    for (int i = 0; i < days.length; i++) {
      final day = days[i];
      final sessions = sessionsByDay[day] ?? [];
      
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
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
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
                  dotData: const FlDotData(show: true),
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
    );
  }
  
  Widget _buildSessionHistory(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Session History',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _sessions.length,
          itemBuilder: (context, index) {
            final session = _sessions[index];
            return _buildSessionHistoryItem(theme, session);
          },
        ),
      ],
    );
  }
  
  Widget _buildSessionHistoryItem(ThemeData theme, Session session) {
    final dateFormat = DateFormat('MMM d, yyyy - h:mm a');
    final formattedDate = dateFormat.format(session.timestamp);
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(
          session.wasCompleted ? Icons.check_circle : Icons.cancel,
          color: session.wasCompleted ? Colors.green : Colors.red,
        ),
        title: Text(
          session.wasCompleted ? 'Completed Session' : 'Partial Session',
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Text(
          '$formattedDate\nCompletion: ${session.completionPercentage.toStringAsFixed(1)}% • Duration: ${session.durationInSeconds}s',
          style: theme.textTheme.bodySmall,
        ),
        isThreeLine: true,
      ),
    );
  }
  
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
}
