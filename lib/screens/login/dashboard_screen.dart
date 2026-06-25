import 'package:app/core/app_theme.dart';
import 'package:app/screens/login/dashboard/volunteers/candidates/candidates_screen.dart';
import 'package:app/screens/login/dashboard/volunteers/candidates/overview_tab.dart';
import 'package:app/screens/login/volunteers_screen.dart';
import 'package:flutter/material.dart';

import '../../widgets/sidebar_widget.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  static const _titles = ['Dashboard', 'Volunteer Management', 'Candidate Management'];
  static const _screens = [OverviewTab(), VolunteersScreen(), CandidatesScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgBase,
      body: Row(
        children: [
          SidebarWidget(
            selectedIndex: _selectedIndex,
            onSelect: (i) => setState(() => _selectedIndex = i),
          ),
          // Vertical divider
          Container(width: 1, color: AppTheme.borderColor),
          // Main content
          Expanded(
            child: Column(
              children: [
                // Top bar
                Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  decoration: const BoxDecoration(
                    color: AppTheme.bgSurface,
                    border: Border(
                        bottom: BorderSide(color: AppTheme.borderColor)),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _titles[_selectedIndex],
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      // Live indicator
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.successGreen.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppTheme.successGreen.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                  color: AppTheme.successGreen,
                                  shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 6),
                            const Text('Live',
                                style: TextStyle(
                                    color: AppTheme.successGreen,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Page content
                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: _screens,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}