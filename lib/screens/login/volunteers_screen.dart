import 'package:app/core/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/volunteer_model.dart';
import '../../services/volunteer_service.dart';

class VolunteersScreen extends StatefulWidget {
  const VolunteersScreen({super.key});

  @override
  State<VolunteersScreen> createState() => _VolunteersScreenState();
}

class _VolunteersScreenState extends State<VolunteersScreen> {
  final _svc = VolunteerService();
  VolunteerStatus? _filterStatus;
  String _search = '';

  // ✅ REMOVED: stray `BuildContext? get _ => null;` getter — was shadowing
  //    the wildcard `_` used in builder callbacks and causing Navigator.pop(_)
  //    to receive null, crashing the dialog dismiss.

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (v) => setState(() => _search = v.toLowerCase()),
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Search volunteers...',
                    hintStyle:
                        const TextStyle(color: AppTheme.textSecondary),
                    prefixIcon: const Icon(Icons.search,
                        color: AppTheme.textSecondary, size: 18),
                    filled: true,
                    fillColor: AppTheme.bgCard,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: AppTheme.borderColor)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: AppTheme.borderColor)),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              for (final s in [null, ...VolunteerStatus.values])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      s == null ? 'All' : _statusLabel(s),
                      style: TextStyle(
                        fontSize: 12,
                        color: _filterStatus == s
                            ? AppTheme.bgBase
                            : AppTheme.textSecondary,
                      ),
                    ),
                    selected: _filterStatus == s,
                    onSelected: (_) => setState(() => _filterStatus = s),
                    backgroundColor: AppTheme.bgCard,
                    selectedColor: AppTheme.accent,
                    checkmarkColor: AppTheme.bgBase,
                    side: const BorderSide(color: AppTheme.borderColor),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          Expanded(
            child: StreamBuilder<List<VolunteerModel>>(
              stream: _filterStatus == null
                  ? _svc.watchAll()
                  : _svc.watchByStatus(_filterStatus!),
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: AppTheme.accent));
                }
                final all = snap.data ?? [];
                final filtered = _search.isEmpty
                    ? all
                    : all
                        .where((v) =>
                            v.name.toLowerCase().contains(_search) ||
                            v.email.toLowerCase().contains(_search))
                        .toList();

                return Container(
                  decoration: BoxDecoration(
                    color: AppTheme.bgCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Column(
                    children: [
                      _TableRow(
                        cells: const [
                          'NAME', 'EMAIL', 'PHONE', 'STATUS',
                          'ZONE', 'JOINED', 'ACTIONS'
                        ],
                        isHeader: true,
                      ),
                      const Divider(height: 1, color: AppTheme.borderColor),
                      Expanded(
                        child: ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const Divider(
                              height: 1, color: AppTheme.borderColor),
                          itemBuilder: (ctx, i) {
                            final v = filtered[i];
                            return _VolunteerRow(
                              volunteer: v,
                              onApprove: () => _svc.updateStatus(
                                  v.uid, VolunteerStatus.approved),
                              onReject: () => _svc.updateStatus(
                                  v.uid, VolunteerStatus.rejected),
                              onSuspend: () => _svc.updateStatus(
                                  v.uid, VolunteerStatus.suspended),
                              // ✅ FIX: pass the ListView's `ctx` so the dialog
                              //    has a valid BuildContext to Navigator.pop from
                              onDelete: () => _confirmDelete(ctx, v),
                            );
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: const BoxDecoration(
                          border: Border(
                              top: BorderSide(color: AppTheme.borderColor)),
                        ),
                        child: Row(
                          children: [
                            Text(
                              '${filtered.length} volunteer${filtered.length == 1 ? '' : 's'}',
                              style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext ctx, VolunteerModel v) {
    showDialog(
      context: ctx,
      // ✅ FIX: renamed builder param from `_` to `dialogCtx` — the old name
      //    was resolving to the broken null getter instead of the dialog's
      //    BuildContext, so Navigator.pop() was receiving null and crashing.
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        title: const Text('Delete Volunteer',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: Text('Remove ${v.name} permanently?',
            style: const TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx), // ✅ uses real context
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              _svc.deleteVolunteer(v.uid);
              Navigator.pop(dialogCtx); // ✅ uses real context
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.dangerRed),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _statusLabel(VolunteerStatus s) =>
      s.name[0].toUpperCase() + s.name.substring(1);
}

// ─── Table header/row shell ───────────────────────────────────────────────
class _TableRow extends StatelessWidget {
  final List<String> cells;
  final bool isHeader;
  const _TableRow({required this.cells, this.isHeader = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: cells.map((c) {
          final flex = c == 'ACTIONS' ? 1 : (c == 'EMAIL' ? 3 : 2);
          return Expanded(
            flex: flex,
            child: Text(
              c,
              style: TextStyle(
                color: isHeader
                    ? AppTheme.textSecondary
                    : AppTheme.textPrimary,
                fontSize: isHeader ? 11 : 13,
                fontWeight:
                    isHeader ? FontWeight.w600 : FontWeight.w400,
                letterSpacing: isHeader ? 0.7 : 0,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Single volunteer row ─────────────────────────────────────────────────
class _VolunteerRow extends StatelessWidget {
  final VolunteerModel volunteer;
  final VoidCallback onApprove, onReject, onSuspend, onDelete;

  const _VolunteerRow({
    required this.volunteer,
    required this.onApprove,
    required this.onReject,
    required this.onSuspend,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final v = volunteer;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
              flex: 2,
              child: Text(v.name,
                  style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500))),
          Expanded(
              flex: 3,
              child: Text(v.email,
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13))),
          Expanded(
              flex: 2,
              child: Text(v.phone,
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13))),
          Expanded(flex: 2, child: _StatusBadge(v.status)),
          Expanded(
              flex: 2,
              child: Text(v.assignedZone ?? '—',
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13))),
          Expanded(
              flex: 2,
              child: Text(
                  DateFormat('dd MMM yy').format(v.createdAt),
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13))),
          Expanded(
            flex: 1,
            child: Row(
              children: [
                if (v.status == VolunteerStatus.pending)
                  _ActionBtn(
                      icon: Icons.check,
                      color: AppTheme.successGreen,
                      onTap: onApprove),
                if (v.status == VolunteerStatus.pending ||
                    v.status == VolunteerStatus.approved)
                  _ActionBtn(
                      icon: Icons.block,
                      color: AppTheme.warningAmber,
                      onTap: v.status == VolunteerStatus.pending
                          ? onReject
                          : onSuspend),
                _ActionBtn(
                    icon: Icons.delete_outline,
                    color: AppTheme.dangerRed,
                    onTap: onDelete),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final VolunteerStatus status;
  const _StatusBadge(this.status);

  @override
  Widget build(BuildContext context) {
    final (color, bg) = switch (status) {
      VolunteerStatus.approved => (
          AppTheme.successGreen,
          AppTheme.successGreen.withOpacity(0.12)
        ),
      VolunteerStatus.pending => (
          AppTheme.warningAmber,
          AppTheme.warningAmber.withOpacity(0.12)
        ),
      VolunteerStatus.rejected => (
          AppTheme.dangerRed,
          AppTheme.dangerRed.withOpacity(0.12)
        ),
      VolunteerStatus.suspended => (
          AppTheme.textSecondary,
          AppTheme.borderColor
        ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        status.name,
        style: TextStyle(
            color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, size: 16, color: color),
      tooltip: '',
      style: IconButton.styleFrom(
        minimumSize: const Size(28, 28),
        padding: EdgeInsets.zero,
      ),
    );
  }
}