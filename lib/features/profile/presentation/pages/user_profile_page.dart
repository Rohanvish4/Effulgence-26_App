import 'package:effulgence26_mobile_app/core/services/remote_config_service.dart';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:effulgence26_mobile_app/components/buttons/app_button.dart';
import 'package:effulgence26_mobile_app/components/common/effulgence_background_elements.dart';
import 'package:effulgence26_mobile_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:effulgence26_mobile_app/components/common/particle_background.dart';
import 'package:effulgence26_mobile_app/core/theme/app_spacing.dart';
import 'package:effulgence26_mobile_app/core/theme/app_text_styles.dart';

import 'package:effulgence26_mobile_app/core/utils/url_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../components/loading/loading_indicators.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../../../auth/domain/entity/user_entity.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../../../../core/services/widget_to_pdf_service.dart';
import '../widgets/id_card_widget.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final ImagePicker _picker = ImagePicker();



  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().loadProfile();
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final croppedFile = await _cropImage(File(image.path));
        
        if (croppedFile != null && mounted) {
          _showSnackBar("Uploading image...", AppColors.primary);
          context.read<ProfileCubit>().updateProfile(
            imageFile: croppedFile,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar("Failed to pick image: $e", AppColors.error);
      }
    }
  }

  Future<File?> _cropImage(File imageFile) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Edit Photo',
            toolbarColor: AppColors.bgPrimary,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            backgroundColor: AppColors.bgSecondary,
            activeControlsWidgetColor: AppColors.primary,
            dimmedLayerColor: Colors.black.withOpacity(0.8),
            cropFrameColor: AppColors.primary,
            cropGridColor: AppColors.primary.withOpacity(0.5),
            hideBottomControls: false,
          ),
          IOSUiSettings(
            title: 'Edit Photo',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
            aspectRatioPickerButtonHidden: true,
            rectX: 0.0,
            rectY: 0.0,
            rectWidth: 1080.0,
            rectHeight: 1080.0,
            minimumAspectRatio: 1.0,
          ),
        ],
      );
      
      if (croppedFile != null) {
        return File(croppedFile.path);
      }
    } catch (e) {
      debugPrint('Error cropping image: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ParticleBackground(
        floatingElements: EffulgenceBackgroundElements.getElementsForDay(context.read<RemoteConfigService>().techfestDay),
        child: BlocConsumer<ProfileCubit, ProfileState>(
          // Don't rebuild the profile page when referral states change
          // (those are handled in MyReferralsPage)
          buildWhen: (prev, curr) =>
              curr is! ProfileReferralsLoading &&
              curr is! ProfileReferralsLoaded &&
              curr is! ProfileReferralsError,
          listener: (context, state) {
            if (state is ProfileError) {
              _showSnackBar(state.message, AppColors.error);
            } else if (state is ProfileLoggedOut) {
              context.go('/login');
            } else if (state is ProfileUpdateSuccess) {
              context.read<ProfileCubit>().loadProfile();
            }
          },
          builder: (context, state) {
            if (state is ProfileLoading) {
              return _buildShimmerLoading();
            } else if (state is ProfileUpdateLoading || state is ProfilePaymentSubmitting) {
              return const Center(child: AppLoadingIndicator());
            } else if (state is ProfileLoaded) {
              return _buildProfileContent(context, state.profile);
            }
            return _buildErrorState();
          },
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, UserProfileEntity profile) {
    return RefreshIndicator(
      onRefresh: () => context.read<ProfileCubit>().loadProfile(),
      color: AppColors.primary,
      backgroundColor: AppColors.bgSecondary,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          _buildSliverAppBar(profile),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  _buildStatsRow(profile),
                  const SizedBox(height: AppSpacing.sm),
                  if (profile.approvalStatus == 'NOT_APPROVED') ...[
                    _buildPaymentCard(profile),
                    const SizedBox(height: AppSpacing.sm),
                  ] else if (profile.approvalStatus == 'PENDING') ...[
                    _buildVerificationPendingCard(),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  _buildEventsButton(context),
                  const SizedBox(height: AppSpacing.sm),
                  _buildQrCodeButton(context),
                  const SizedBox(height: AppSpacing.sm),

                  // _buildIdCardButton(context, profile),
                  // const SizedBox(height: AppSpacing.md),
                  _buildInfoCard(profile),
                  const SizedBox(height: AppSpacing.sm),
                  if (profile.registrationId != null)
                    _buildReferralCard(profile),
                  const SizedBox(height: AppSpacing.sm),
                  if (profile.isSuperAdmin) ...[
                    const SizedBox(height: AppSpacing.md),
                    _buildAdminButton(context),
                  ],
                  // const SizedBox(height: AppSpacing.xxl),
                  // _buildAccountActions(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(UserProfileEntity profile) {
    return SliverAppBar(
      expandedHeight: 210,
      pinned: true,
      backgroundColor: AppColors.bgPrimary.withValues(alpha: 0.8),
      actions: [

        if(profile.isSuperAdmin ) ...[
        IconButton(
          icon: const Icon(Icons.campaign_outlined), // Broadcast Icon
          tooltip: 'Send Broadcast',
          onPressed: () => context.push('/admin/broadcast'),
        ),
        IconButton(
          icon: const Icon(Icons.person), // Broadcast Icon
          tooltip: 'Users',
          onPressed: () => context.push('/admin/users'),
        ),
        ],


        IconButton(
          onPressed: () => context.push('/editUserDetails'),
          icon: const Icon(Icons.tune_rounded, color: AppColors.primary),
        ),
        IconButton(
          onPressed: () => {_showLogoutConfirmation(context)},
          icon: const Icon(Icons.logout_rounded, color: AppColors.error),
        ),
        SizedBox(width: 10),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            _buildAvatar(profile),
            const SizedBox(height: 16),
            Text(
              profile.name.toUpperCase(),
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            // Text(
            //   profile.email,
            //   style: AppTextStyles.bodySmall.copyWith(
            //     color: AppColors.textSecondary,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(UserProfileEntity profile) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Stack(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.surface,
            backgroundImage: UrlUtils.isValidUrl(profile.imageUrl)
                ? CachedNetworkImageProvider(profile.imageUrl!)
                : null,
            child: UrlUtils.isValidUrl(profile.imageUrl)
                ? null
                : Icon(
                    Icons.person_rounded,
                    size: 50,
                    color: AppColors.textMuted,
                  ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: _pickAndUploadImage,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(UserProfileEntity profile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildMiniStat(
          "STATUS",
          profile.approvalStatus,
          _getStatusColor(profile.approvalStatus),
        ),
        _buildMiniStat("ID", profile.registrationId!, AppColors.primary),
      ],
    );
  }





  Widget _buildMiniStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textPrimary,
              fontSize: 9,
            ),
          ),
          Text(
            value.toUpperCase(),
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(UserProfileEntity profile) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.2)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            children: [
              _buildInfoRow(
                Icons.phone_iphone_rounded,
                'Mobile',
                profile.mobile.toString(),
              ),
              _buildInfoRow(
                Icons.school_rounded,
                'College',
                profile.collegeName ?? '-',
              ),
              _buildInfoRow(
                Icons.verified_user_rounded,
                'Email',
                profile.email,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: AppColors.border.withValues(alpha: 0.1),
                ),
              ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 16),
          Text(
            label,
            maxLines: 1,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildQrCodeButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: AppButton(
        text: "SHOW ENTRY QR CODE",
        onPressed: () => context.push('/qrcode'),
        icon: Icons.qr_code_rounded,
        backgroundColor: AppColors.primary,
        textColor: Colors.black,
      ),
    );
  }

  Widget _buildEventsButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: AppButton(
        text: "REGISTERED EVENTS",
        onPressed: () => context.push('/my-events'),
        icon: Icons.radar_rounded,
        isOutlined: true,
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildAdminButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: AppButton(
        text: "ADMIN CONSOLE",
        onPressed: () => context.push('/admin'),
        icon: Icons.admin_panel_settings_rounded,
        backgroundColor: AppColors.error.withValues(alpha: 0.1),
        textColor: AppColors.error,
        isOutlined: true,
      ),
    );
  }

  Widget _buildIdCardButton(BuildContext context, UserProfileEntity profile) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: AppButton(
        text: "SHOW ID CARD",
        onPressed: () => _showIdCardDialog(context, profile),
        icon: Icons.badge_outlined,
        backgroundColor: AppColors.bgSecondary,
        textColor: AppColors.textPrimary,
        isOutlined: true,
      ),
    );
  }

  void _showIdCardDialog(BuildContext context, UserProfileEntity user) {
    final GlobalKey idCardKey = GlobalKey();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IdCardWidget(
                user: UserEntity(
                  id: user.id,
                  name: user.name,
                  email: user.email,
                  mobile: user.mobile,
                  rollNo: user.rollNo,
                  role: user.role,
                  imageUrl: user.imageUrl,
                  isEmailVerified: user.isEmailVerified,
                  isInternalUser: user.isInternalUser,
                  approvalStatus: user.approvalStatus,
                  collegeName: user.collegeName,
                  effulgenceId: user.qrcode, // Mapping qrcode to effulgenceId
                  registrationId: user.registrationId,
                ),
                boundaryKey: idCardKey,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 24),
                  ElevatedButton.icon(
                    onPressed: () => _downloadIdCard(idCardKey),
                    icon: const Icon(Icons.download_rounded),
                    label: const Text("Download PDF"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _downloadIdCard(GlobalKey key) async {
    try {
      _showSnackBar("Generating PDF...", AppColors.primary);
      
      final pdfBytes = await WidgetToPdfService().captureAndGeneratePdf(key);
      
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/effulgence_id_card.pdf');
      await file.writeAsBytes(pdfBytes);

      _showSnackBar("ID Card saved successfully!", AppColors.success);
      
      await OpenFile.open(file.path);
      
    } catch (e) {
      _showSnackBar("Failed to download ID card: $e", AppColors.error);
    }
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          // AppBar Shimmer
          Container(
            height: 250,
            width: double.infinity,
            padding: const EdgeInsets.only(top: 40),
            decoration: BoxDecoration(
              color: AppColors.bgPrimary.withValues(alpha: 0.8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const ShimmerCard(
                  height: 100,
                  width: 100,
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                ),
                const SizedBox(height: 16),
                const ShimmerCard(height: 24, width: 150),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                // Stats Row Shimmer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    ShimmerCard(height: 60, width: 100, borderRadius: BorderRadius.all(Radius.circular(12))),
                    ShimmerCard(height: 60, width: 100, borderRadius: BorderRadius.all(Radius.circular(12))),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                
                // Buttons Shimmer
                const ShimmerCard(height: 50, borderRadius: BorderRadius.all(Radius.circular(8))),
                const SizedBox(height: AppSpacing.sm),
                const ShimmerCard(height: 50, borderRadius: BorderRadius.all(Radius.circular(8))),
                const SizedBox(height: AppSpacing.md),

                // Info Card Shimmer
                Container(
                  padding: const EdgeInsets.all(16),
                   decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    children: [
                      _buildShimmerInfoRow(),
                      const SizedBox(height: 16),
                      _buildShimmerInfoRow(),
                      const SizedBox(height: 16),
                      _buildShimmerInfoRow(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerInfoRow() {
    return Row(
      children: const [
        ShimmerCard(height: 24, width: 24, borderRadius: BorderRadius.all(Radius.circular(4))),
        SizedBox(width: 16),
        ShimmerCard(height: 16, width: 80),
        Spacer(),
        ShimmerCard(height: 16, width: 120),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.terminal_rounded, color: AppColors.error, size: 48),
          const SizedBox(height: 16),
          Text(
            'SYSTEM_LOAD_FAILURE',
            style: AppTextStyles.titleMedium.copyWith(color: AppColors.error),
          ),
          TextButton(
            onPressed: () => context.read<ProfileCubit>().loadProfile(),
            child: const Text('RETRY_SYNC'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return AppColors.success;
      case 'PENDING':
        return AppColors.warning;
      case 'REJECTED':
        return AppColors.error;
      default:
        return AppColors.error;
    }
  }

  Widget _buildReferralCard(UserProfileEntity profile) {
    final referralCode = profile.registrationId ?? '';
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.15),
            AppColors.primary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.card_giftcard_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'YOUR REFERRAL CODE',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Share your registration ID with friends to refer them to Effulgence\'26.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    referralCode,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      fontFamily: 'Monospace',
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: referralCode));
                    _showSnackBar('Referral code copied!', AppColors.primary);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.copy_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          GestureDetector(
            onTap: () => context.push('/my-referrals'),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.group_rounded,
                    color: AppColors.primary,
                    size: 16,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'VIEW MY REFERRALS',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColors.primary,
                    size: 12,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgSecondary,
        title: Text('TERMINATE SESSION', style: AppTextStyles.titleMedium),
        content: const Text('Confirm secure logout from Effulgence system?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ABORT'),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthCubit>().logout();
              Navigator.pop(context);
            },
            child: const Text(
              'CONFIRM',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(UserProfileEntity profile) {
    return Card(
      color: AppColors.error.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.payment_rounded, color: AppColors.error, size: 20),
                const SizedBox(width: 8),
                Text(
                  "ACTION REQUIRED",
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Complete your registration for accommodation  and night passes by submitting the fee (₹1499).",
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Bank Details",
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildCopyRow("Name", "Effulgence 2026"),
                  _buildCopyRow("Acc No", "45850200000365"),
                  _buildCopyRow("IFSC", "BARB0KNISUL"),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _PaymentForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildCopyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(
              "$label:",
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ),
          SelectableText(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primary,
              fontFamily: 'Monospace',
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationPendingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.pending_actions_rounded, color: AppColors.warning),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "VERIFICATION PENDING",
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Your payment details are under review.",
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
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

class _PaymentForm extends StatefulWidget {
  @override
  State<_PaymentForm> createState() => _PaymentFormState();
}

class _PaymentFormState extends State<_PaymentForm> {
  final TextEditingController _utrController = TextEditingController();
  File? _receiptFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickReceipt() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _receiptFile = File(image.path);
      });
    }
  }

  void _submit() {
    if (_utrController.text.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid UTR number")),
      );
      return;
    }
    if (_receiptFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please upload payment receipt")),
      );
      return;
    }

    context.read<ProfileCubit>().submitPayment(
      receiptImage: _receiptFile!,
      utrNumber: _utrController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _utrController,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            labelText: "UTR / Transaction ID",
            labelStyle: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.border.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary),
            ),
            isDense: true,
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: _pickReceipt,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(
                color: _receiptFile != null
                    ? AppColors.success
                    : AppColors.border.withValues(alpha: 0.3),
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _receiptFile != null ? Icons.check_circle : Icons.upload_file,
                  color: _receiptFile != null
                      ? AppColors.success
                      : AppColors.textPrimary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  _receiptFile != null
                      ? "Receipt Selected"
                      : "Upload Receipt Screenshot",
                  style: TextStyle(
                    color: _receiptFile != null
                        ? AppColors.success
                        : AppColors.textPrimary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, state) {
            if (state is ProfilePaymentSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Payment submitted successfully!"),
                ),
              );
            } else if (state is ProfilePaymentError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is ProfilePaymentSubmitting) {
              return const AppLoadingIndicator();
            }
            return AppButton(
              text: "SUBMIT PAYMENT",
              onPressed: _submit,
              backgroundColor: AppColors.error,
              textColor: Colors.black,
              height: 40,
            );
          },
        ),
      ],
    );
  }
}
