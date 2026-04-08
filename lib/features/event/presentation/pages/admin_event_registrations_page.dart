import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:excel/excel.dart' hide Border;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../components/components.dart';
import '../../domain/entities/event_entity.dart';
import '../../domain/entities/participation_entity.dart';
import '../cubit/events_cubit.dart';
import '../cubit/events_state.dart';

class AdminEventRegistrationsPage extends StatefulWidget {
  final EventEntity event;

  const AdminEventRegistrationsPage({super.key, required this.event});

  @override
  State<AdminEventRegistrationsPage> createState() =>
      _AdminEventRegistrationsPageState();
}

class _AdminEventRegistrationsPageState
    extends State<AdminEventRegistrationsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final Set<String> _updatingAttendance = <String>{};

  @override
  void initState() {
    super.initState();
    context.read<EventsCubit>().loadEventRegistrations(widget.event.id);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _exportToExcel(List<ParticipationEntity> data) async {
    try {
      final Excel excel = Excel.createExcel();
      final Sheet sheet = excel['Registrations'];

      final bool isTeamEvent = widget.event.eventType == 'TEAM';

      // Add Event Header Row
      _addHeaderRow(sheet, 0, ['EVENT DETAILS']);
      int rowIndex = 1;

      // Event Information
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
        ..value = 'Event Name'
        ..cellStyle = _getHeaderStyle();
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
          .value = widget.event.title;
      rowIndex++;

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
        ..value = 'Event Type'
        ..cellStyle = _getHeaderStyle();
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
          .value = isTeamEvent ? 'Team Event' : 'Individual Event';
      rowIndex++;

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
        ..value = 'Total Registrations'
        ..cellStyle = _getHeaderStyle();
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
          .value = data.length;
      rowIndex++;

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
        ..value = 'Present'
        ..cellStyle = _getHeaderStyle();
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
          .value = data.where((p) => p.isPresent).length;
      rowIndex += 2;

      // Add Registrations Header
      _addHeaderRow(
        sheet,
        rowIndex,
        isTeamEvent ? _getTeamHeaders() : _getIndividualHeaders(),
      );
      rowIndex++;

      // Add Registration Data
      if (isTeamEvent) {
        for (final participation in data) {
          _addTeamRow(sheet, rowIndex, participation);
          rowIndex++;
          for (final member in participation.teamMembers) {
            _addTeamMemberRow(sheet, rowIndex, member, participation.isPresent);
            rowIndex++;
          }
          rowIndex++; // Space between teams
        }
      } else {
        for (final participation in data) {
          _addIndividualRow(sheet, rowIndex, participation);
          rowIndex++;
        }
      }

      // Save file
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          '${widget.event.title}_Registrations_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      final bytes = excel.encode();
      await file.writeAsBytes(bytes!);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Excel exported successfully'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
          showCloseIcon: true,
          actionOverflowThreshold: 0.25,
          action: SnackBarAction(
            label: 'OPEN',
            textColor: Colors.white,
            onPressed: () => _openExcelFile(filePath),
          ),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _openExcelFile(String filePath) async {
    try {
      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open file: ${result.message}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening file: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  List<String> _getTeamHeaders() {
    return [
      'Team Name',
      'Total Members',
      'Member Name',
      'Member Email',
      'Member Mobile',
      'Present',
    ];
  }

  List<String> _getIndividualHeaders() {
    return ['Name', 'Email', 'Mobile', 'Present', 'Registration Time'];
  }

  void _addHeaderRow(Sheet sheet, int rowIndex, List<String> headers) {
    for (int i = 0; i < headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: rowIndex))
        ..value = headers[i]
        ..cellStyle = _getHeaderStyle();
    }
  }

  void _addTeamRow(
    Sheet sheet,
    int rowIndex,
    ParticipationEntity participation,
  ) {
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
        .value = participation.teamName ?? 'Unnamed Team';
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
        .value = participation.teamMembers.length;
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
        .value = participation.isPresent ? 'Yes' : 'No';
  }

  void _addTeamMemberRow(
    Sheet sheet,
    int rowIndex,
    dynamic member,
    bool isPresent,
  ) {
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
        .value = member.name ?? '';
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
        .value = member.email ?? '';
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
        .value = member.mobile ?? '';
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex))
        .value = isPresent ? 'Yes' : 'No';
  }

  void _addIndividualRow(
    Sheet sheet,
    int rowIndex,
    ParticipationEntity participation,
  ) {
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
        .value = participation.userName;
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
        .value = participation.userEmail;
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
        .value = participation.userMobile;
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
        .value = participation.isPresent ? 'Yes' : 'No';
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
        .value = DateTime.now().toString();
  }

  Future<void> _markAttendance(
    ParticipationEntity participation,
    bool isPresent,
  ) async {
    final id = participation.id;
    if (_updatingAttendance.contains(id)) return;

    setState(() => _updatingAttendance.add(id));

    await context.read<EventsCubit>().markParticipationAttendance(
      eventId: widget.event.id,
      participationId: id,
      isPresent: isPresent,
    );

    if (!mounted) return;

    setState(() => _updatingAttendance.remove(id));

    final state = context.read<EventsCubit>().state;
    if (state.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.errorMessage!),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isPresent ? 'Marked present' : 'Marked absent'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _showParticipantDetails(String userId) async {
    if (userId.isEmpty) return;

    final details = await context.read<EventsCubit>().getParticipantFullDetails(
      userId,
    );

    if (!mounted) return;

    if (details == null || details.isEmpty) {
      final state = context.read<EventsCubit>().state;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            state.errorMessage ?? 'Failed to load participant details',
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final user = Map<String, dynamic>.from(details['user'] ?? {});
    final summary = Map<String, dynamic>.from(details['summary'] ?? {});
    final participations = List<Map<String, dynamic>>.from(
      (details['participations'] ?? const []).map(
        (item) => Map<String, dynamic>.from(item as Map),
      ),
    );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  Text('Participant Details', style: AppTextStyles.titleLarge),
                  const SizedBox(height: AppSpacing.md),
                  _buildDetailTile('Name', (user['name'] ?? '-').toString()),
                  _buildDetailTile('Email', (user['email'] ?? '-').toString()),
                  _buildDetailTile(
                    'Mobile',
                    (user['mobile'] ?? '-').toString(),
                  ),
                  _buildDetailTile(
                    'College',
                    (user['collegeName'] ?? '-').toString(),
                  ),
                  _buildDetailTile(
                    'Registration ID',
                    (user['registrationId'] ?? '-').toString(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildMetricChip(
                        'Total Events: ${summary['totalParticipations'] ?? 0}',
                      ),
                      _buildMetricChip(
                        'Present: ${summary['totalPresent'] ?? 0}',
                      ),
                      _buildMetricChip(
                        'Qualified: ${summary['totalQualified'] ?? 0}',
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Participation History',
                    style: AppTextStyles.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      itemCount: participations.length,
                      separatorBuilder:
                          (_, __) => const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final item = participations[index];
                        final eventTitle =
                            (item['eventTitle'] ?? 'Unknown Event').toString();
                        final eventType = (item['eventType'] ?? '-').toString();
                        final participationType =
                            (item['participationType'] ?? '-').toString();
                        final isPresent = item['isPresent'] == true;
                        final isQualified = item['isQualified'] == true;

                        return Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.surface.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusMd,
                            ),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                eventTitle,
                                style: AppTextStyles.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$eventType • $participationType',
                                style: AppTextStyles.bodySmall,
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _buildStatusChip(
                                    isPresent ? 'Present' : 'Absent',
                                    isPresent
                                        ? AppColors.success
                                        : AppColors.error,
                                  ),
                                  _buildStatusChip(
                                    isQualified ? 'Qualified' : 'Not Qualified',
                                    isQualified
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                  ),
                                  if (item['rank'] != null)
                                    _buildStatusChip(
                                      'Rank: ${item['rank']}',
                                      AppColors.primary,
                                    ),
                                  _buildStatusChip(
                                    'Score: ${item['score'] ?? 0}',
                                    AppColors.primary,
                                  ),
                                ],
                              ),
                              if ((item['teamName'] ?? '')
                                  .toString()
                                  .isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    'Team: ${item['teamName']} (${item['teamSize'] ?? 0} members)',
                                    style: AppTextStyles.bodySmall,
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
          },
        );
      },
    );
  }

  Widget _buildDetailTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              '$label:',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(child: Text(value, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }

  Widget _buildMetricChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(label, style: AppTextStyles.labelSmall),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(color: color),
      ),
    );
  }

  CellStyle _getHeaderStyle() {
    return CellStyle(bold: true, horizontalAlign: HorizontalAlign.Center);
  }

  @override
  Widget build(BuildContext context) {
    final bool isTeamEvent = widget.event.eventType == 'TEAM';

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary.withValues(alpha: 0.8),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'REGISTRATIONS',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.primary,
                letterSpacing: 2,
              ),
            ),
            Text(
              widget.event.title,
              style: AppTextStyles.titleMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_all_rounded),
            tooltip: 'Copy all emails',
            onPressed:
                () => _copyAllEmails(
                  context.read<EventsCubit>().state.myParticipations,
                ),
          ),
          IconButton(
            icon: const Icon(Icons.file_download_rounded),
            tooltip: 'Export to Excel',
            onPressed:
                () => _exportToExcel(
                  context.read<EventsCubit>().state.myParticipations,
                ),
          ),
        ],
      ),
      body: BlocBuilder<EventsCubit, EventsState>(
        builder: (context, state) {
          if (state.isOperationLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final registrations = state.myParticipations;
          if (registrations.isEmpty) {
            return const EmptyState(
              icon: Icons.people_outline,
              title: 'No registrations',
            );
          }

          // Filter logic for 2G optimization (Local filtering)
          final filtered =
              registrations.where((p) {
                final query = _searchQuery.toLowerCase();
                if (isTeamEvent) {
                  return (p.teamName?.toLowerCase().contains(query) ?? false) ||
                      p.teamMembers.any(
                        (m) => m.name.toLowerCase().contains(query),
                      );
                }
                return p.userName.toLowerCase().contains(query) ||
                    p.userEmail.toLowerCase().contains(query);
              }).toList();

          return Column(
            children: [
              _buildValidationBanner(registrations, isTeamEvent),
              _buildSummaryHeader(registrations, isTeamEvent),
              _buildSearchBox(),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: filtered.length,
                  separatorBuilder:
                      (_, __) => const SizedBox(height: AppSpacing.md),
                  itemBuilder:
                      (context, index) =>
                          _buildAdaptiveCard(filtered[index], isTeamEvent),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // VALIDATION BANNER: Anomalies surfaced immediately
  Widget _buildValidationBanner(List<ParticipationEntity> data, bool isTeam) {
    int anomalies = 0;
    if (isTeam) {
      anomalies =
          data
              .where(
                (p) =>
                    p.teamMembers.length <
                    (widget.event.teamConfig?.minSize ?? 1),
              )
              .length;
    }

    if (anomalies == 0) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: AppColors.error.withValues(alpha: 0.2),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.error,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            '$anomalies ${isTeam ? "Teams" : "Entries"} violate event rules',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.error,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryHeader(List<ParticipationEntity> data, bool isTeam) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      margin: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat(isTeam ? 'Teams' : 'Players', data.length.toString()),
          _buildStat(
            'Present',
            data.where((p) => p.isPresent).length.toString(),
          ),
          if (isTeam) _buildStat('Avg Size', _calculateAvgTeamSize(data)),
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    return AppGlassSearchBar(
      controller: _searchController,
      hintText: 'Quick search name, team or email...',
      onChanged: (val) => setState(() => _searchQuery = val),
      onClear: () => setState(() => _searchQuery = ''),
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
    );
  }

  Widget _buildAdaptiveCard(ParticipationEntity p, bool isTeam) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: isTeam ? _buildTeamCard(p) : _buildIndividualCard(p),
      ),
    );
  }

  Widget _buildTeamCard(ParticipationEntity p) {
    final bool isInvalid =
        p.teamMembers.length < (widget.event.teamConfig?.minSize ?? 1);

    return ExpansionTile(
      shape: const RoundedRectangleBorder(side: BorderSide.none),
      leading: CircleAvatar(
        backgroundColor:
            isInvalid
                ? AppColors.error.withValues(alpha: 0.1)
                : AppColors.primary.withValues(alpha: 0.1),
        child: Icon(
          Icons.groups,
          color: isInvalid ? AppColors.error : AppColors.primary,
        ),
      ),
      title: Text(
        p.teamName ?? 'Unnamed Team',
        style: AppTextStyles.titleMedium,
      ),
      subtitle: Text(
        '${p.teamMembers.length} Members',
        style: AppTextStyles.bodySmall,
      ),
      trailing: Switch(
        value: p.isPresent,
        activeTrackColor: AppColors.success,
        onChanged:
            _updatingAttendance.contains(p.id)
                ? null
                : (val) => _markAttendance(p, val),
      ),
      children:
          p.teamMembers
              .map(
                (m) => ListTile(
                  onTap: () => _showParticipantDetails(m.id),
                  title: Text(m.name, style: AppTextStyles.bodyMedium),
                  subtitle: Text(
                    m.mobile.isNotEmpty ? '${m.email}\n${m.mobile}' : m.email,
                    style: AppTextStyles.bodySmall,
                  ),
                  isThreeLine: m.mobile.isNotEmpty,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.info_outline, size: 18),
                        tooltip: 'View full details',
                        onPressed: () => _showParticipantDetails(m.id),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 16),
                        onPressed: () => _copyToClipboard(m.email),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
    );
  }

  Widget _buildIndividualCard(ParticipationEntity p) {
    return ListTile(
      onTap: () => _showParticipantDetails(p.userId),
      contentPadding: const EdgeInsets.all(AppSpacing.md),
      leading: CircleAvatar(child: Text(p.userName[0])),
      title: Text(p.userName, style: AppTextStyles.titleMedium),
      subtitle: Text(
        p.userMobile.isNotEmpty
            ? '${p.userEmail}\n${p.userMobile}'
            : p.userEmail,
        style: AppTextStyles.bodySmall,
      ),
      isThreeLine: p.userMobile.isNotEmpty,
      trailing: Switch(
        value: p.isPresent,
        activeTrackColor: AppColors.success,
        onChanged:
            _updatingAttendance.contains(p.id)
                ? null
                : (val) => _markAttendance(p, val),
      ),
    );
  }

  // HELPER METHODS
  String _calculateAvgTeamSize(List<ParticipationEntity> data) {
    if (data.isEmpty) return '0';
    double avg = data.expand((p) => p.teamMembers).length / data.length;
    return avg.toStringAsFixed(1);
  }

  void _copyAllEmails(List<ParticipationEntity> data) {
    final emails = data
        .expand((p) => p.teamMembers)
        .map((m) => m.email)
        .join(', ');
    _copyToClipboard(emails);
  }

  Future<void> _copyToClipboard(String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label.toUpperCase(),
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
