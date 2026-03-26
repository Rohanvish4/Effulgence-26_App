import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/event_entity.dart';
import '../../domain/entities/participation_entity.dart';
import '../../domain/entities/public_team_entity.dart';
import '../cubit/events_cubit.dart';

class JoinTeamPage extends StatefulWidget {
  final String eventId;
  final String teamId;

  const JoinTeamPage({
    super.key,
    required this.eventId,
    required this.teamId,
  });

  @override
  State<JoinTeamPage> createState() => _JoinTeamPageState();
}

class _JoinTeamPageState extends State<JoinTeamPage> {
  bool _isLoading = true;
  bool _joining = false;
  bool _success = false;
  String? _errorMessage;
  String? _successMessage;

  EventEntity? _eventData;
  ParticipationEntity? _teamData;
  PublicTeamEntity? _publicTeamData;
  String? _fallbackTeamName;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final cubit = context.read<EventsCubit>();
    final repository = cubit.eventsRepository;

    try {
      // 1. Fetch event details
      final eventResult = await repository.getEventById(widget.eventId);
      eventResult.fold(
        (failure) => throw Exception(failure.message),
        (event) => _eventData = event,
      );

      // 2. Fetch team details
      // Try direct fetch
      final teamResult = await repository.getTeamDetails(widget.eventId, widget.teamId);
      teamResult.fold(
        (failure) async {
          // Direct fetch failed, try getting from public teams
          final publicTeamsResult = await repository.getPublicTeams(widget.eventId);
          publicTeamsResult.fold(
            (fallbackFailure) {
              // Both failed, use fallback
              _fallbackTeamName = 'Team';
            },
            (teams) {
              try {
                _publicTeamData = teams.firstWhere((t) => t.id == widget.teamId);
              } catch (_) {
                _fallbackTeamName = 'Team';
              }
            },
          );
        },
        (team) {
          _teamData = team;
        },
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleConfirmJoin() async {
    setState(() {
      _joining = true;
      _errorMessage = null;
    });

    final cubit = context.read<EventsCubit>();
    final repository = cubit.eventsRepository;

    try {
      // Try direct join
      final joinResult = await repository.joinTeam(widget.eventId, widget.teamId);
      joinResult.fold(
        (failure) async {
          // Direct join failed (no invitation), try requesting to join
          final reqResult = await repository.requestToJoinTeam(widget.eventId, widget.teamId);
          reqResult.fold(
            (reqFailure) {
              if (mounted) {
                setState(() {
                  _errorMessage = reqFailure.message;
                  _joining = false;
                });
              }
            },
            (_) {
              _showSuccessAndRedirect('Join request sent! The team leader will review your request.');
            },
          );
        },
        (_) {
          _showSuccessAndRedirect('You\'ve been added to the team successfully');
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _joining = false;
        });
      }
    }
  }

  void _showSuccessAndRedirect(String message) {
    if (mounted) {
      setState(() {
        _success = true;
        _successMessage = message;
        _joining = false;
      });
    }

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.go('/events/${widget.eventId}');
      }
    });
  }

  void _handleCancel() {
    context.go('/events/${widget.eventId}');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('JOIN TEAM', style: AppTextStyles.headlineLarge.copyWith(fontFamily: 'Oxanium')),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: _buildContent(theme),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (_isLoading) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 24),
          Text(
            'LOADING',
            style: AppTextStyles.headlineLarge.copyWith(fontFamily: 'Oxanium', color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Getting team details...',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
        ],
      );
    }

    if (_success) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline, size: 64, color: AppColors.primary),
          const SizedBox(height: 24),
          Text(
            'SUCCESS!',
            style: AppTextStyles.headlineLarge.copyWith(fontFamily: 'Oxanium', color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(
            _successMessage ?? 'Success!',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          Text(
            'Redirecting you to the event...',
            style: AppTextStyles.labelMedium.copyWith(color: Colors.grey),
          ),
        ],
      );
    }

    if (_errorMessage != null && _eventData == null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 24),
          Text(
            'OOPS!',
            style: AppTextStyles.headlineLarge.copyWith(fontFamily: 'Oxanium', color: AppColors.error),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.go('/events'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('BROWSE EVENTS', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      );
    }

    final teamName = _teamData?.teamName ?? _publicTeamData?.teamName ?? _fallbackTeamName ?? 'Team';
    final memberCount = _teamData?.teamMembers.length ?? _publicTeamData?.members.length ?? 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'JOIN TEAM?',
            textAlign: TextAlign.center,
            style: AppTextStyles.headlineLarge.copyWith(
              fontFamily: 'Oxanium',
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.error.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: AppColors.error, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TEAM NAME', style: AppTextStyles.labelMedium.copyWith(color: Colors.grey)),
                const SizedBox(height: 4),
                Text(teamName, style: AppTextStyles.titleLarge.copyWith(color: AppColors.primary)),
                const SizedBox(height: 20),
                
                Row(
                  children: [
                    const Icon(Icons.people_outline, size: 20, color: Colors.cyan),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('MEMBERS', style: AppTextStyles.labelMedium.copyWith(color: Colors.grey)),
                        Text('$memberCount', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 20, color: Colors.purpleAccent),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('EVENT', style: AppTextStyles.labelMedium.copyWith(color: Colors.grey)),
                          Text(
                            _eventData?.title ?? 'Unknown Event',
                            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _joining ? null : _handleCancel,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.grey.shade800),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'CANCEL',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _joining ? null : _handleConfirmJoin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _joining
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'CONFIRM',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
