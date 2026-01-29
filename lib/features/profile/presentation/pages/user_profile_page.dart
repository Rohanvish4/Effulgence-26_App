import 'package:effulgence26_mobile_app/features/profile/presentation/pages/log_out_and_delete_profile_widget.dart';

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
        child: Column(
          children: [
            _buildProfileHeader(profile),
            const SizedBox(height: 24),
            _buildInfoCard(profile),
            const SizedBox(height: 24),
            
            ExpandableShowWidget(
              showMore: Text("Show More", style: TextStyle(color: Colors.white),),
              arrowColor: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                      onTap: (){
                        _showLogoutConfirmation(context);
                      },
                      child: const Text('Logout', style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.white,
                        fontSize: 15
                      ))
                  ),
                   GestureDetector(
                     onTap: (){

                     },
                     child: const Text('Delete account', style: TextStyle(
                       decoration: TextDecoration.underline,
                       color: Colors.white,
                       fontSize: 15
                     ))
                   )

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserProfileEntity profile) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 40),
        Expanded(
          child: Column(
            children: [
              SizedBox(height: 80),
                 SizedBox(
                  height: 150,
                  child: profile.imageUrl == null
                      ? const Icon(Icons.person, size: 150, color: Colors.white54)
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
            ],
          ),
        ),

        Column(
          children: [
            SizedBox(height: 40),
            Container(alignment: Alignment.center, width: 40,
                child: IconButton( onPressed: (){
                  navigateToEditPage();
                }, icon: const Icon(Icons.edit_note_rounded), color: Colors.white,),),
          ],
        ),
      ],
    );
  }
  Future<void> navigateToEditPage() async {
    await context.push<String>('/editUserDetails');
  }

  Widget _buildInfoCard(UserProfileEntity profile) {
    const boxGaps = 3.0;
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            child: Text("Details", style:TextStyle(color: Colors.white, fontSize: 14),),
          ),
          const SizedBox(height: 10),

          _buildInfoRow(Icons.phone, 'Mobile', profile.mobile.toString(), borderRadius: BorderRadius.vertical(top: Radius.circular(14))),
          const SizedBox(height: boxGaps),
          _buildInfoRow(Icons.numbers, 'Roll No', profile.rollNo.toString()),
          const SizedBox(height: boxGaps),
          _buildInfoRow(Icons.golf_course, 'Course', "BTech"),
          const SizedBox(height: boxGaps),
          _buildInfoRow(Icons.school_outlined, 'College', "KNIT", borderRadius: BorderRadius.vertical(bottom: Radius.circular(14))),

        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, { BorderRadius borderRadius = BorderRadius.zero}) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.surfaceVariant,width: 1),
        borderRadius: borderRadius
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Row(
        children: [
          Icon(icon, size: 29, color: Colors.white),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 13, color: Color.fromARGB(255, 205, 205, 205)),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ],
            ),
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
