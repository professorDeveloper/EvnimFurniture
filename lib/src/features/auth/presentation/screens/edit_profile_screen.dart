import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:evim_furniture/src/core/constants/app_colors.dart';
import 'package:evim_furniture/src/core/constants/app_texts.dart';
import 'package:evim_furniture/src/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/model/user_model.dart';
import '../bloc/auth_bloc.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.user});

  final UserModel user;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocus = FocusNode();
  final ImagePicker _picker = ImagePicker();
  late AuthBloc _authBloc;

  String? _newAvatarPath;
  bool _nameError = false;

  @override
  void initState() {
    super.initState();
    _authBloc = sl<AuthBloc>();
    _nameController.text = widget.user.name ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocus.dispose();
    _authBloc.close();
    super.dispose();
  }

  bool get _hasChanges {
    final nameChanged = _nameController.text.trim() != (widget.user.name ?? '');
    return nameChanged || _newAvatarPath != null;
  }

  void _onSave() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = true);
      _nameFocus.requestFocus();
      return;
    }

    final nameChanged = name != (widget.user.name ?? '');
    _authBloc.add(EditProfileEvent(
      name: nameChanged ? name : null,
      picturePath: _newAvatarPath,
    ));
  }

  void _onPickAvatar() {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(ctx).scaffoldBackgroundColor,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                AppTexts.authPickPhoto.tr(),
                style: GoogleFonts.dmSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurfaceVariant
                        : AppColors.grey100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.camera_alt_rounded,
                      color: cs.primary, size: 22),
                ),
                title: Text(
                  AppTexts.authPickCamera.tr(),
                  style: GoogleFonts.dmSans(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              const SizedBox(height: 4),
              ListTile(
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurfaceVariant
                        : AppColors.grey100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.photo_library_rounded,
                      color: cs.primary, size: 22),
                ),
                title: Text(
                  AppTexts.authPickGallery.tr(),
                  style: GoogleFonts.dmSans(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    if (image != null) {
      setState(() => _newAvatarPath = image.path);
    }
  }

  Widget _buildAvatar(bool isDark) {
    final cs = Theme.of(context).colorScheme;
    Widget imageWidget;

    if (_newAvatarPath != null) {
      imageWidget = ClipOval(
        child: Image.file(
          File(_newAvatarPath!),
          width: 90,
          height: 90,
          fit: BoxFit.cover,
        ),
      );
    } else if (widget.user.picture != null && widget.user.picture!.isNotEmpty) {
      imageWidget = ClipOval(
        child: CachedNetworkImage(
          imageUrl: widget.user.picture!,
          width: 90,
          height: 90,
          fit: BoxFit.cover,
          placeholder: (_, __) => Icon(
            Icons.person_rounded,
            size: 40,
            color: cs.onSurfaceVariant.withOpacity(0.35),
          ),
          errorWidget: (_, __, ___) => Icon(
            Icons.person_rounded,
            size: 40,
            color: cs.onSurfaceVariant.withOpacity(0.35),
          ),
        ),
      );
    } else {
      imageWidget = Icon(
        Icons.person_rounded,
        size: 40,
        color: cs.onSurfaceVariant.withOpacity(0.35),
      );
    }

    return GestureDetector(
      onTap: _onPickAvatar,
      child: Stack(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? AppColors.darkSurfaceVariant : AppColors.grey100,
              border: Border.all(
                color: isDark ? AppColors.darkDivider : AppColors.grey200,
                width: 1.5,
              ),
            ),
            child: imageWidget,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: cs.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                size: 14,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider.value(
      value: _authBloc,
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is ProfileSaved) {
            Navigator.pop(context, state.user);
          } else if (state is ProfileSaveError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: cs.error,
              ),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: cs.onSurface,
              ),
            ),
            centerTitle: true,
            title: Text(
              'editProfile'.tr(),
              style: GoogleFonts.dmSans(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 24),

                  // Avatar
                  _buildAvatar(isDark),

                  const SizedBox(height: 28),

                  // Name field
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      AppTexts.authNameLabel.tr(),
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: _nameError ? null : 48,
                    child: TextField(
                      controller: _nameController,
                      focusNode: _nameFocus,
                      textCapitalization: TextCapitalization.words,
                      onChanged: (_) {
                        if (_nameError) setState(() => _nameError = false);
                        setState(() {}); // rebuild for hasChanges
                      },
                      style: GoogleFonts.dmSans(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: AppTexts.authNameHint.tr(),
                        hintStyle: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: cs.onSurfaceVariant.withOpacity(0.5),
                        ),
                        prefixIcon: Icon(
                          Icons.person_outline_rounded,
                          size: 20,
                          color:
                              _nameError ? cs.error : cs.onSurfaceVariant,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: _nameError
                                ? cs.error
                                : (isDark
                                    ? AppColors.darkDivider
                                    : AppColors.grey200),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: _nameError ? cs.error : cs.primary,
                            width: 2,
                          ),
                        ),
                        errorText: _nameError
                            ? AppTexts.authNameRequired.tr()
                            : null,
                        errorStyle: GoogleFonts.dmSans(fontSize: 11),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Save button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is ProfileSaving;
                      return SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed:
                              (_hasChanges && !isLoading) ? _onSave : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            foregroundColor: AppColors.white,
                            disabledBackgroundColor:
                                AppColors.secondary.withOpacity(0.3),
                            disabledForegroundColor:
                                AppColors.white.withOpacity(0.5),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: AppColors.white,
                                  ),
                                )
                              : Text(
                                  'save'.tr(),
                                  style: GoogleFonts.dmSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
