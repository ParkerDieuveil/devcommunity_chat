import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/locale/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../domain/entities/profile.dart';
import '../providers/profile_provider.dart';

/// Bottom sheet d'édition du profil.
class EditProfileSheet extends ConsumerStatefulWidget {
  const EditProfileSheet({
    super.key,
    required this.user,
    required this.profile,
  });

  final AppUser user;
  final ProfileEntity? profile;

  @override
  ConsumerState<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<EditProfileSheet> {
  late final TextEditingController nameController;
  late final TextEditingController titleController;
  late final TextEditingController bioController;
  late final TextEditingController emailController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final profile = widget.profile;
    nameController = TextEditingController(
      text: profile?.displayname.trim().isNotEmpty == true
          ? profile!.displayname
          : (widget.user.displayName ?? ''),
    );
    titleController = TextEditingController(text: profile?.title ?? '');
    bioController = TextEditingController(text: profile?.bio ?? '');
    emailController = TextEditingController(text: widget.user.email);
  }

  @override
  void dispose() {
    nameController.dispose();
    titleController.dispose();
    bioController.dispose();
    emailController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(String label) {
    final borderColor = Theme.of(context).brightness == Brightness.dark
        ? AppColors.borderDark
        : AppColors.borderSubtle;
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Theme.of(context).colorScheme.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.brand, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final s = ref.watch(appStringsProvider);
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.sheetHandle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                s.editProfileTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: onSurface,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                textCapitalization: TextCapitalization.words,
                decoration: _fieldDecoration(s.fieldName),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: _fieldDecoration(s.fieldTitle),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: bioController,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: _fieldDecoration(s.fieldBio),
              ),
              const SizedBox(height: 14),
              TextField(
                enabled: false,
                controller: emailController,
                decoration: _fieldDecoration(s.fieldEmail),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: FilledButton(
                        onPressed:
                            _saving ? null : () => Navigator.of(context).pop(),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.brandSurfaceAlt,
                          foregroundColor: AppColors.headerBlue,
                          shape: const StadiumBorder(),
                        ),
                        child: Text(
                          s.cancel,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: FilledButton(
                        onPressed: _saving ? null : _save,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.brand,
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(),
                        ),
                        child: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                s.save,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
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

  Future<void> _save() async {
    final s = ref.read(appStringsProvider);
    final name = nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.nameRequired)),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(updateProfileProvider).call(
            userId: widget.user.id,
            name: name,
            email: widget.user.email,
            title: titleController.text.trim(),
            bio: bioController.text.trim(),
          );
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s.profileUpdated)),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${s.profileUpdateFailed} : $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}
