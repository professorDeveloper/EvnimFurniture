import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:evim_furniture/src/core/constants/app_colors.dart';
import 'package:evim_furniture/src/core/constants/app_texts.dart';
import 'package:evim_furniture/src/core/router/pages.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

enum UserType { mijoz, diller, boshqa }

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocus = FocusNode();

  UserType _selectedType = UserType.mijoz;
  String? _avatarPath;
  bool _nameError = false;

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  bool get _isValid => _nameController.text.trim().isNotEmpty;

  final ImagePicker _picker = ImagePicker();

  void _onPickAvatar() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(ctx).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                    color: isDark ? AppColors.darkSurfaceVariant : AppColors.grey100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.camera_alt_rounded, color: cs.primary, size: 22),
                ),
                title: Text(
                  AppTexts.authPickCamera.tr(),
                  style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    color: isDark ? AppColors.darkSurfaceVariant : AppColors.grey100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.photo_library_rounded, color: cs.primary, size: 22),
                ),
                title: Text(
                  AppTexts.authPickGallery.tr(),
                  style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_avatarPath != null) ...[
                const SizedBox(height: 4),
                ListTile(
                  leading: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: cs.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.delete_outline_rounded, color: cs.error, size: 22),
                  ),
                  title: Text(
                    AppTexts.authPickRemove.tr(),
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: cs.error,
                    ),
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() => _avatarPath = null);
                  },
                ),
              ],
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
      setState(() => _avatarPath = image.path);
    }
  }

  void _onComplete() {
    if (!_isValid) {
      setState(() => _nameError = true);
      _nameFocus.requestFocus();
      return;
    }

    // TODO: Call complete profile API with:
    // name: _nameController.text.trim()
    // userType: _selectedType.name
    // picture: _avatarPath

    Navigator.pushNamedAndRemoveUntil(context, Pages.home, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: true,
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
          AppTexts.authCompleteTitle.tr(),
          style: GoogleFonts.dmSans(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 8),

                      // Subtitle
                      Text(
                        AppTexts.authCompleteSubtitle.tr(),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: cs.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Avatar - compact
                      GestureDetector(
                        onTap: _onPickAvatar,
                        child: Stack(
                          children: [
                            Container(
                              width: 76,
                              height: 76,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark
                                    ? AppColors.darkSurfaceVariant
                                    : AppColors.grey100,
                                border: Border.all(
                                  color: isDark
                                      ? AppColors.darkDivider
                                      : AppColors.grey200,
                                  width: 1.5,
                                ),
                              ),
                              child: _avatarPath != null
                                  ? ClipOval(
                                      child: Image.file(
                                        File(_avatarPath!),
                                        width: 76,
                                        height: 76,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Icon(
                                      Icons.person_rounded,
                                      size: 34,
                                      color: cs.onSurfaceVariant.withOpacity(
                                        0.35,
                                      ),
                                    ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: cs.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Theme.of(
                                      context,
                                    ).scaffoldBackgroundColor,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  size: 12,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 4),
                      Text(
                        AppTexts.authAvatarOptional.tr(),
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: cs.onSurfaceVariant.withOpacity(0.5),
                        ),
                      ),

                      const SizedBox(height: 20),

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
                            if (_nameError) {
                              setState(() => _nameError = false);
                            }
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
                              color: _nameError
                                  ? cs.error
                                  : cs.onSurfaceVariant,
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
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: cs.error),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: cs.error, width: 2),
                            ),
                            errorText: _nameError
                                ? AppTexts.authNameRequired.tr()
                                : null,
                            errorStyle: GoogleFonts.dmSans(fontSize: 11),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // User type
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          AppTexts.authUserTypeLabel.tr(),
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          AppTexts.authUserTypeDesc.tr(),
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            color: cs.onSurfaceVariant.withOpacity(0.7),
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // 3 type cards in a row
                      Row(
                        children: [
                          Expanded(
                            child: _UserTypeCard(
                              icon: Icons.person_rounded,
                              label: AppTexts.authTypeMijoz.tr(),
                              subtitle: AppTexts.authTypeMijozDesc.tr(),
                              selected: _selectedType == UserType.mijoz,
                              isDark: isDark,
                              onTap: () => setState(
                                () => _selectedType = UserType.mijoz,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _UserTypeCard(
                              icon: Icons.store_rounded,
                              label: AppTexts.authTypeDiller.tr(),
                              subtitle: AppTexts.authTypeDillerDesc.tr(),
                              selected: _selectedType == UserType.diller,
                              isDark: isDark,
                              onTap: () => setState(
                                () => _selectedType = UserType.diller,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _UserTypeCard(
                              icon: Icons.more_horiz_rounded,
                              label: AppTexts.authTypeBoshqa.tr(),
                              subtitle: AppTexts.authTypeBoshqaDesc.tr(),
                              selected: _selectedType == UserType.boshqa,
                              isDark: isDark,
                              onTap: () => setState(
                                () => _selectedType = UserType.boshqa,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),
                      const SizedBox(height: 24),

                      // Complete button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _onComplete,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            foregroundColor: AppColors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                AppTexts.authCompleteBtn.tr(),
                                style: GoogleFonts.dmSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_rounded, size: 18),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _UserTypeCard extends StatelessWidget {
  const _UserTypeCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final bgColor = selected
        ? (isDark
              ? AppColors.secondary600.withOpacity(0.25)
              : AppColors.secondary50)
        : (isDark ? AppColors.darkSurfaceVariant : AppColors.grey50);

    final accentColor = isDark ? AppColors.secondary200 : AppColors.secondary;

    final borderColor = selected
        ? accentColor
        : (isDark ? AppColors.darkDivider : AppColors.grey200);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: selected ? 2 : 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected
                        ? accentColor.withOpacity(0.15)
                        : (isDark ? AppColors.darkSurface : AppColors.grey100),
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: selected
                        ? accentColor
                        : cs.onSurfaceVariant.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: selected ? accentColor : cs.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    color: cs.onSurfaceVariant.withOpacity(0.7),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                // Selection indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? accentColor : Colors.transparent,
                    border: Border.all(
                      color: selected ? accentColor : cs.outline,
                      width: 1.5,
                    ),
                  ),
                  child: selected
                      ? const Icon(
                          Icons.check,
                          size: 11,
                          color: AppColors.white,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
