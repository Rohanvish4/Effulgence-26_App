import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../components/loading/loading_indicators.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,

      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is ProfileLoggedOut) {
            // Navigate to login or initial route after logout
            context.go('/login');
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: AppLoadingIndicator());
          } else if (state is ProfileLoaded) {
            return _buildProfileContent(context, state.profile);
          } else if (state is ProfileError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Failed to load profile',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<ProfileCubit>().loadProfile(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, UserProfileEntity profile) {
    return RefreshIndicator(
      onRefresh: () => context.read<ProfileCubit>().loadProfile(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),

        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 80),
            _buildProfileHeader(profile),
            const SizedBox(height: 24),
            _buildInfoCard(profile),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.1),
                  foregroundColor: Colors.red,
                  side: BorderSide(color: Colors.red.withOpacity(0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  _showLogoutConfirmation(context);
                },
                child: const Text('Logout'),
              ),
            ),
            SizedBox(height: 2.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.1),
                  foregroundColor: Colors.red,
                  side: BorderSide(color: Colors.red.withOpacity(0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {},
                child: const Text('Delete account'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserProfileEntity profile) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 2),
            image: profile.imageUrl != null
                ? DecorationImage(
                    image: NetworkImage(profile.imageUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: profile.imageUrl == null
              ? const Icon(Icons.person, size: 50, color: Colors.white54)
              : null,
        ),
        const SizedBox(height: 16),
        Text(
          profile.name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          profile.email,
          style: const TextStyle(fontSize: 14, color: Colors.white54),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(profile.approvalStatus).withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _getStatusColor(profile.approvalStatus)),
          ),
          child: Text(
            profile.approvalStatus.toUpperCase(),
            style: TextStyle(
              color: _getStatusColor(profile.approvalStatus),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(UserProfileEntity profile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            Icons.badge,
            'User ID',
            profile.id,
          ), // Using ID as EffulgenceID fallback
          const Divider(color: AppColors.surfaceVariant),
          _buildInfoRow(Icons.phone, 'Mobile', profile.mobile.toString()),
          const Divider(color: AppColors.surfaceVariant),
          _buildInfoRow(Icons.numbers, 'Roll No', profile.rollNo.toString()),
          const Divider(color: AppColors.surfaceVariant),
          _buildInfoRow(Icons.school, 'Role', profile.role),
          const Divider(color: AppColors.surfaceVariant),
          _buildInfoRow(
            Icons.verified,
            'Email Verified',
            profile.isEmailVerified ? 'Yes' : 'No',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.white54),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgSecondary,
        title: const Text('Logout', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ProfileCubit>().logout();
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
