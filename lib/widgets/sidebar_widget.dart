import 'package:app/core/app_theme.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class SidebarWidget extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const SidebarWidget({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
  });

  static const _items = [
    (Icons.dashboard_outlined, Icons.dashboard, 'Dashboard'),
    (Icons.volunteer_activism_outlined, Icons.volunteer_activism, 'Volunteers'),
    (Icons.people_outline, Icons.people, 'Candidates'),
    (Icons.map_outlined, Icons.map, 'Heatmap'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      color: AppTheme.bgSurface,
      child: Column(
        children: [
          // Brand
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.shield_outlined,
                      color: AppTheme.accent, size: 18),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AdminPanel',
                        style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700)),
                    Text('v1.0',
                        style: TextStyle(
                            color: AppTheme.textSecondary, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),

          // Nav items
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  for (int i = 0; i < _items.length; i++)
                    _NavItem(
                      iconOff: _items[i].$1,
                      iconOn: _items[i].$2,
                      label: _items[i].$3,
                      selected: selectedIndex == i,
                      onTap: () => onSelect(i),
                    ),
                ],
              ),
            ),
          ),

          // Divider + Sign out
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppTheme.borderColor)),
            ),
            child: _NavItem(
              iconOff: Icons.logout,
              iconOn: Icons.logout,
              label: 'Sign out',
              selected: false,
              onTap: () => AdminAuthService().signOut(),
              danger: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData iconOff, iconOn;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool danger;

  const _NavItem({
    required this.iconOff,
    required this.iconOn,
    required this.label,
    required this.selected,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger
        ? AppTheme.dangerRed
        : selected
            ? AppTheme.accent
            : AppTheme.textSecondary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: selected
            ? AppTheme.accent.withOpacity(0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(selected ? iconOn : iconOff, color: color, size: 18),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: selected
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
                if (selected) ...[
                  const Spacer(),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                        color: AppTheme.accent,
                        shape: BoxShape.circle),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}