import 'package:effulgence26_mobile_app/core/theme/app_colors.dart';
import 'package:effulgence26_mobile_app/core/theme/app_text_styles.dart';
import 'package:effulgence26_mobile_app/features/admin/presentation/cubit/admin_cubit.dart';
import 'package:effulgence26_mobile_app/features/profile/presentation/widgets/id_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdminAllUsersPage  extends StatefulWidget{
  const AdminAllUsersPage ({super.key});

  @override
  State<AdminAllUsersPage> createState() => _AdminAllUsersPageState();
}





class _AdminAllUsersPageState extends State<AdminAllUsersPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _currentFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    context.read<AdminCubit>().getUsers(refresh: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<AdminCubit>().getUsers();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: Text(
          "Manage Users",
          style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.bgSecondary,
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search by name, email, roll no...',
                    hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
                    prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.bgPrimary,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  ),
                  onChanged: (value) {
                    context.read<AdminCubit>().filterUsers(value, filterType: _currentFilter);
                  },
                ),
                const SizedBox(height: 12),
                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', 'ALL'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Internal', 'INTERNAL'),
                      const SizedBox(width: 8),
                      _buildFilterChip('External', 'EXTERNAL'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Admins', 'ADMIN'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Users List
          Expanded(
            child: BlocConsumer<AdminCubit, AdminState>(
              listener: (context, state) {
                if (state is AdminError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is AdminLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }
                if (state is AdminUsersLoaded) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<AdminCubit>().getUsers(refresh: true);
                      // Reset filters on refresh if desired, or keep them
                      // keeping them for better UX:
                      // Future.delayed(Duration(milliseconds: 100), () {
                      //   context.read<AdminCubit>().filterUsers(_searchController.text, filterType: _currentFilter);
                      // });
                    },
                    color: AppColors.primary,
                    backgroundColor: AppColors.bgSecondary,
                    child: ListView.separated(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: state.users.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final user = state.users[index];
                        return _buildUserCard(context, user);
                      },
                    ),
                  );
                }
                return Center(
                  child: Text(
                    'No users found',
                    style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textMuted),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String filterValue) {
    final isSelected = _currentFilter == filterValue;
    return FilterChip(
      label: Text(
        label,
        style: AppTextStyles.labelMedium.copyWith(
          color: isSelected ? Colors.black : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (bool selected) {
        setState(() {
          _currentFilter = filterValue; // Allow reseleting to essentially 'force' update if needed, but standard behavior usually toggles. Here we use radio-button style selection.
        });
        context.read<AdminCubit>().filterUsers(_searchController.text, filterType: _currentFilter);
      },
      backgroundColor: AppColors.bgPrimary,
      selectedColor: AppColors.primary,
      checkmarkColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? Colors.transparent : AppColors.border,
        ),
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, dynamic user) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primary.withValues(alpha: 0.2),
          backgroundImage: user.imageUrl != null ? NetworkImage(user.imageUrl!) : null,
          child: user.imageUrl == null
              ? Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                  style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary),
                )
              : null,
        ),
        title: Text(
          user.name,
          style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _buildDetailRow(Icons.email_outlined, user.email),
            const SizedBox(height: 4),
            _buildDetailRow(Icons.phone_iphone_rounded, user.mobile?.toString() ?? 'N/A'),
            const SizedBox(height: 4),
            _buildDetailRow(Icons.school_outlined, user.collegeName ?? 'N/A'),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getRoleColor(user.role).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                        color: _getRoleColor(user.role).withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    user.role,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: _getRoleColor(user.role),
                      fontSize: 10,
                    ),
                  ),
                ),
                if (user.registrationId != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      user.registrationId,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.badge_outlined, color: AppColors.primary),
          tooltip: 'View ID Card',
          onPressed: () => _showIdCardDialog(context, user),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toUpperCase()) {
      case 'ADMIN':
      case 'SUPER_ADMIN':
        return AppColors.error; // Red-ish for admins
      case 'MEMBER':
        return AppColors.accent; // Yellow/Green for members
      default:
        return AppColors.success; // Green/Blue for users
    }
  }

  void _showIdCardDialog(BuildContext context, dynamic user) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IdCardWidget(
                user: user,
                boundaryKey: GlobalKey(),
              ),
              const SizedBox(height: 16),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, color: Colors.white, size: 32),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 