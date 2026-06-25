import 'package:app/core/app_theme.dart';
import 'package:app/models/candidate_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';


class CandidatesScreen extends StatefulWidget {
  const CandidatesScreen({super.key});

  @override
  State<CandidatesScreen> createState() => _CandidatesScreenState();
}

class _CandidatesScreenState extends State<CandidatesScreen> {
  final _col = FirebaseFirestore.instance.collection('users');
  String _search = '';
  CandidateStatus? _filterStatus;

  Stream<List<CandidateModel>> _stream() {
    Query q = _col.where('role', isEqualTo: 'general');
    if (_filterStatus != null) {
      q = q.where('status', isEqualTo: _filterStatus!.name);
    }
    return q
        .orderBy('registeredAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(CandidateModel.fromFirestore).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search + filter
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (v) => setState(() => _search = v.toLowerCase()),
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Search candidates...',
                    hintStyle:
                        const TextStyle(color: AppTheme.textSecondary),
                    prefixIcon: const Icon(Icons.search,
                        color: AppTheme.textSecondary, size: 18),
                    filled: true,
                    fillColor: AppTheme.bgCard,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                            color: AppTheme.borderColor)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                            color: AppTheme.borderColor)),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              for (final s in [null, ...CandidateStatus.values])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      s == null
                          ? 'All'
                          : s.name[0].toUpperCase() + s.name.substring(1),
                      style: TextStyle(
                          fontSize: 12,
                          color: _filterStatus == s
                              ? AppTheme.bgBase
                              : AppTheme.textSecondary),
                    ),
                    selected: _filterStatus == s,
                    onSelected: (_) =>
                        setState(() => _filterStatus = s),
                    backgroundColor: AppTheme.bgCard,
                    selectedColor: AppTheme.candidatePurple,
                    checkmarkColor: AppTheme.bgBase,
                    side:
                        const BorderSide(color: AppTheme.borderColor),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          Expanded(
            child: StreamBuilder<List<CandidateModel>>(
              stream: _stream(),
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: AppTheme.candidatePurple));
                }
                final all = snap.data ?? [];
                final filtered = _search.isEmpty
                    ? all
                    : all
                        .where((c) =>
                            c.name.toLowerCase().contains(_search) ||
                            c.email.toLowerCase().contains(_search))
                        .toList();

                return Container(
                  decoration: BoxDecoration(
                    color: AppTheme.bgCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Column(
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          children: const [
                            Expanded(flex: 3, child: _HeaderCell('NAME')),
                            Expanded(flex: 3, child: _HeaderCell('EMAIL')),
                            Expanded(flex: 2, child: _HeaderCell('PHONE')),
                            Expanded(
                                flex: 2, child: _HeaderCell('STATUS')),
                            Expanded(
                                flex: 2, child: _HeaderCell('REGION')),
                            Expanded(
                                flex: 2,
                                child: _HeaderCell('REGISTERED')),
                            Expanded(
                                flex: 2,
                                child: _HeaderCell('LAST ACTIVE')),
                          ],
                        ),
                      ),
                      const Divider(
                          height: 1, color: AppTheme.borderColor),
                      Expanded(
                        child: ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const Divider(
                              height: 1, color: AppTheme.borderColor),
                          itemBuilder: (_, i) {
                            final c = filtered[i];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 14,
                                          backgroundColor:
                                              AppTheme.candidatePurple
                                                  .withOpacity(0.2),
                                          child: Text(
                                            c.name.isNotEmpty
                                                ? c.name[0].toUpperCase()
                                                : '?',
                                            style: const TextStyle(
                                                color:
                                                    AppTheme.candidatePurple,
                                                fontSize: 12,
                                                fontWeight:
                                                    FontWeight.w600),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            c.name,
                                            style: const TextStyle(
                                                color:
                                                    AppTheme.textPrimary,
                                                fontSize: 13,
                                                fontWeight:
                                                    FontWeight.w500),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                      flex: 3,
                                      child: Text(c.email,
                                          style: const TextStyle(
                                              color:
                                                  AppTheme.textSecondary,
                                              fontSize: 13))),
                                  Expanded(
                                      flex: 2,
                                      child: Text(c.phone,
                                          style: const TextStyle(
                                              color:
                                                  AppTheme.textSecondary,
                                              fontSize: 13))),
                                  Expanded(
                                      flex: 2,
                                      child: _CandidateStatusBadge(
                                          c.status)),
                                  Expanded(
                                      flex: 2,
                                      child: Text(c.region ?? '—',
                                          style: const TextStyle(
                                              color:
                                                  AppTheme.textSecondary,
                                              fontSize: 13))),
                                  Expanded(
                                      flex: 2,
                                      child: Text(
                                          DateFormat('dd MMM yy')
                                              .format(c.registeredAt),
                                          style: const TextStyle(
                                              color:
                                                  AppTheme.textSecondary,
                                              fontSize: 13))),
                                  Expanded(
                                      flex: 2,
                                      child: Text(
                                          c.lastActive != null
                                              ? DateFormat('dd MMM yy')
                                                  .format(c.lastActive!)
                                              : '—',
                                          style: const TextStyle(
                                              color:
                                                  AppTheme.textSecondary,
                                              fontSize: 13))),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: const BoxDecoration(
                            border: Border(
                                top: BorderSide(
                                    color: AppTheme.borderColor))),
                        child: Row(children: [
                          Text('${filtered.length} candidates',
                              style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12)),
                        ]),
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
}

class _HeaderCell extends StatelessWidget {
  final String text;
  const _HeaderCell(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.7));
}

class _CandidateStatusBadge extends StatelessWidget {
  final CandidateStatus status;
  const _CandidateStatusBadge(this.status);

  @override
  Widget build(BuildContext context) {
    final (color, bg) = switch (status) {
      CandidateStatus.active => (
          AppTheme.successGreen,
          AppTheme.successGreen.withOpacity(0.12)
        ),
      CandidateStatus.verified => (
          AppTheme.volunteerBlue,
          AppTheme.volunteerBlue.withOpacity(0.12)
        ),
      CandidateStatus.registered => (
          AppTheme.warningAmber,
          AppTheme.warningAmber.withOpacity(0.12)
        ),
      CandidateStatus.inactive => (
          AppTheme.textSecondary,
          AppTheme.borderColor
        ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(status.name,
          style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600)),
    );
  }
}