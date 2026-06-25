import 'package:app/core/app_theme.dart';
import 'package:app/services/analytics_service.dart';
import 'package:app/widgets/stat_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class OverviewTab extends StatefulWidget {
  const OverviewTab({super.key});

  @override
  State<OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<OverviewTab> {
  final _analytics = AnalyticsService();
  Map<String, dynamic>? _stats;
  List<Map<String, dynamic>> _trend = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final stats = await _analytics.getDashboardStats();
    final trend = await _analytics.getRegistrationTrend();
    if (mounted) {
      setState(() {
        _stats = stats;
        _trend = trend;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.accent));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stat cards row
          LayoutBuilder(builder: (ctx, c) {
            final cols = c.maxWidth > 900 ? 4 : 2;
            return GridView.count(
              crossAxisCount: cols,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.7,
              children: [
                StatCard(
                  label: 'Total Users',
                  value: '${_stats!['totalUsers']}',
                  icon: Icons.people_outline,
                  color: AppTheme.accent,
                  delta: '+12 this week',
                ),
                StatCard(
                  label: 'Active Volunteers',
                  value: '${_stats!['activeVolunteers']}',
                  icon: Icons.volunteer_activism_outlined,
                  color: AppTheme.volunteerBlue,
                  delta: '+3 this week',
                ),
                StatCard(
                  label: 'Pending Approvals',
                  value: '${_stats!['pendingApprovals']}',
                  icon: Icons.pending_actions_outlined,
                  color: AppTheme.warningAmber,
                ),
                StatCard(
                  label: 'General Users',
                  value: '${_stats!['generalUsers']}',
                  icon: Icons.person_outline,
                  color: AppTheme.candidatePurple,
                  delta: '+9 this week',
                ),
              ],
            );
          }),

          const SizedBox(height: 28),

          // Chart
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('User Registrations — Last 7 Days',
                    style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 15)),
                const SizedBox(height: 24),
                SizedBox(
                  height: 220,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) => const FlLine(
                          color: AppTheme.borderColor,
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 32,
                            getTitlesWidget: (v, _) => Text('${v.toInt()}',
                                style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 11)),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, _) {
                              final i = v.toInt();
                              if (i < 0 || i >= _trend.length) {
                                return const SizedBox();
                              }
                              final d =
                                  _trend[i]['date'] as DateTime;
                              return Text('${d.day}/${d.month}',
                                  style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 11));
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _trend
                              .asMap()
                              .entries
                              .map((e) => FlSpot(
                                  e.key.toDouble(),
                                  (e.value['count'] as int)
                                      .toDouble()))
                              .toList(),
                          isCurved: true,
                          color: AppTheme.accent,
                          barWidth: 2.5,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppTheme.accent.withOpacity(0.08),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Role distribution
          _RoleDistributionCard(
            volunteers: _stats!['activeVolunteers'] as int,
            general: _stats!['generalUsers'] as int,
          ),
        ],
      ),
    );
  }
}

class _RoleDistributionCard extends StatelessWidget {
  final int volunteers, general;
  const _RoleDistributionCard(
      {required this.volunteers, required this.general});

  @override
  Widget build(BuildContext context) {
    final total = volunteers + general;
    final vRatio = total == 0 ? 0.0 : volunteers / total;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Role Distribution',
              style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 15)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: vRatio,
                        minHeight: 8,
                        backgroundColor: AppTheme.borderColor,
                        valueColor: const AlwaysStoppedAnimation(
                            AppTheme.volunteerBlue),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _Dot(
                            color: AppTheme.volunteerBlue,
                            label: 'Volunteers',
                            count: volunteers),
                        _Dot(
                            color: AppTheme.candidatePurple,
                            label: 'General',
                            count: general),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  final String label;
  final int count;
  const _Dot(
      {required this.color, required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 8,
            height: 8,
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text('$label ($count)',
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 12)),
      ],
    );
  }
}