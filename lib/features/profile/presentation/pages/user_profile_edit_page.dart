import 'package:effulgence26_mobile_app/core/theme/app_spacing.dart';
import 'package:effulgence26_mobile_app/core/theme/app_text_styles.dart';
import 'package:effulgence26_mobile_app/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:effulgence26_mobile_app/features/profile/presentation/cubit/profile_state.dart';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:effulgence26_mobile_app/core/utils/url_utils.dart';
import 'package:effulgence26_mobile_app/features/profile/domain/entities/user_profile_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../components/loading/loading_indicators.dart';
import '../../../../core/theme/app_colors.dart';

void showCustomSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Colors.transparent.withValues(
        alpha: 0.4,
      ), // Required for custom styling
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, 0),
      duration: const Duration(seconds: 20),
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          // Glassmorphic background
          color: isError
              ? AppColors.error.withValues(alpha: 0.15)
              : AppColors.bgSecondary.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isError
                ? AppColors.error.withValues(alpha: 0.5)
                : AppColors.primary.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              isError ? Icons.gpp_bad_rounded : Icons.verified_rounded,
              color: isError ? AppColors.error : AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message.toUpperCase(),
                style: AppTextStyles.labelSmall.copyWith(
                  color: Colors.white,
                  letterSpacing: 1,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class UserProfileEditPage extends StatefulWidget {
  const UserProfileEditPage({super.key});

  @override
  State<UserProfileEditPage> createState() => _UserProfileEditPageState();
}

class _UserProfileEditPageState extends State<UserProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _mobileController;
  late TextEditingController _collegeNameController;

  String? _currentImageUrl;
  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _mobileController = TextEditingController();
    _collegeNameController = TextEditingController();
    // Load profile if not already loaded or check current state
    final state = context.read<ProfileCubit>().state;
    if (state is ProfileLoaded) {
      _populateFields(state.profile);
    } else {
      context.read<ProfileCubit>().loadProfile();
    }
  }

  void _populateFields(UserProfileEntity profile) {
    _nameController.text = profile.name;
    _mobileController.text = profile.mobile.toString();
    _collegeNameController.text = profile.collegeName ?? '';
    setState(() {
      _currentImageUrl = profile.imageUrl;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _collegeNameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final croppedFile = await _cropImage(File(image.path));
        
        if (croppedFile != null && mounted) {
          setState(() {
            _pickedImage = croppedFile;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to pick image: $e")));
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
            dimmedLayerColor: Colors.black.withValues(alpha: 0.8),
            cropFrameColor: AppColors.primary,
            cropGridColor: AppColors.primary.withValues(alpha: 0.5),
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

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final collegeNameText = _collegeNameController.text.trim();
      context.read<ProfileCubit>().updateProfile(
        name: _nameController.text.trim(),
        mobile: int.tryParse(_mobileController.text.trim()),
        imageFile: _pickedImage,
        collegeName: collegeNameText.isEmpty ? null : collegeNameText,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.bgPrimary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Profile updated successfully!"),
                backgroundColor: AppColors.primary,
              ),
            );
            context.pop();
          } else if (state is ProfileLoaded) {
            // Only populate if controllers are empty (first load)
            // to avoid overwriting user edits if re-emitted
            if (_nameController.text.isEmpty &&
                _mobileController.text.isEmpty) {
              _populateFields(state.profile);
            }
          } else if (state is ProfileUpdateError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: AppLoadingIndicator());
          } else if (state is ProfileLoaded ||
              state is ProfileUpdateLoading ||
              state is ProfileUpdateError) {
            // Show form even during update loading or error (to fix retry)
            // We need to access the profile data.
            // If state is Loaded, we use it.
            // If UpdateLoading/Error, we rely on controllers.
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildImagePicker(currentImageUrl: _currentImageUrl),
                    const SizedBox(height: 24),
                    _buildTextField(
                      label: "Name",
                      controller: _nameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your name";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: "Mobile Number",
                      controller: _mobileController,
                      keyboardType: TextInputType.phone,
                      formatter: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter mobile number";
                        }
                        if (value.length < 10) {
                          return "Please enter valid mobile number";
                        }
                        return null;
                      },
                    ),
                    // const SizedBox(height: 16),
                    // _buildTextField(
                    //   label: "College Name",
                    //   controller: _collegeNameController,
                    //   validator: (value) {
                    //     if (value == null || value.isEmpty) {
                    //       return "Please enter college name";
                    //     }
                    //     return null;
                    //   },
                    // ),
                    // const SizedBox(height: 16),
                    const SizedBox(height: 16),
                    if (state is ProfileLoaded) ...[
                      _buildReadOnlyField("Email", state.profile.email),
                      const SizedBox(height: 16),
                      _buildReadOnlyField(
                        "College",
                        state.profile.collegeName ?? "-",
                      ),
                      const SizedBox(height: 32),
                    ],

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: (state is ProfileUpdateLoading)
                            ? null
                            : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: (state is ProfileUpdateLoading)
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Save Changes",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? formatter,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          inputFormatters: formatter,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            errorStyle: const TextStyle(color: Colors.redAccent),
          ),
        ),
      ],
    );
  }
  
  Widget _buildImagePicker({String? currentImageUrl}) {
    ImageProvider? imageProvider;
    if (_pickedImage != null) {
      imageProvider = FileImage(_pickedImage!);
    } else if (UrlUtils.isValidUrl(currentImageUrl)) {
      imageProvider = CachedNetworkImageProvider(currentImageUrl!);
    }

    return Center(
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface,
              border: Border.all(color: AppColors.primary, width: 2),
              image: imageProvider != null
                  ? DecorationImage(image: imageProvider, fit: BoxFit.cover)
                  : null,
            ),
            child: imageProvider == null
                ? const Icon(Icons.person, size: 60, color: Colors.white54)
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: const TextStyle(color: Colors.white54, fontSize: 16),
          ),
        ),
      ],
    );
  }
}
