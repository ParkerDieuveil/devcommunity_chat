import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/locale/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../profile/domain/entities/profile.dart';
import '../utils/chat_display.dart';

/// Sheet de sélection multi-membres pour créer un groupe.
class AddMembersSheet extends StatefulWidget {
  const AddMembersSheet({
    super.key,
    required this.candidates,
    required this.initiallySelectedIds,
    required this.strings,
  });

  final List<ProfileEntity> candidates;
  final Set<String> initiallySelectedIds;
  final AppStrings strings;

  @override
  State<AddMembersSheet> createState() => _AddMembersSheetState();
}

class _AddMembersSheetState extends State<AddMembersSheet> {
  late final Set<String> _selectedIds;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedIds = {...widget.initiallySelectedIds};
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.strings;
    final query = _searchController.text.trim().toLowerCase();
    final filtered = widget.candidates.where((p) {
      if (query.isEmpty) return true;
      return p.email.toLowerCase().contains(query) ||
          p.displayname.toLowerCase().contains(query);
    }).toList();

    final height = MediaQuery.sizeOf(context).height * 0.75;

    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.sheetHandle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              s.addMembers,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: s.searchByEmail,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: SvgPicture.asset(
                        'assets/logo/Card Search.svg',
                        width: 160,
                        height: 160,
                      ),
                    )
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final profile = filtered[index];
                        final selected = _selectedIds.contains(profile.id);
                        final name = profile.displayname.trim().isEmpty
                            ? profile.email
                            : profile.displayname;
                        return CheckboxListTile(
                          value: selected,
                          activeColor: AppColors.brand,
                          controlAffinity: ListTileControlAffinity.trailing,
                          secondary: CircleAvatar(
                            backgroundImage: profile.photoUrl.trim().isNotEmpty
                                ? NetworkImage(profile.photoUrl)
                                : null,
                            child: profile.photoUrl.trim().isEmpty
                                ? Text(nameInitial(name))
                                : null,
                          ),
                          title: Text(
                            name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(profile.email),
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                _selectedIds.add(profile.id);
                              } else {
                                _selectedIds.remove(profile.id);
                              }
                            });
                          },
                        );
                      },
                    ),
            ),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.brandSurfaceAlt,
                      foregroundColor: AppColors.headerBlue,
                      shape: const StadiumBorder(),
                    ),
                    child: Text(s.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      final selected = <String, ProfileEntity>{
                        for (final p in widget.candidates)
                          if (_selectedIds.contains(p.id)) p.id: p,
                      };
                      Navigator.pop(context, selected);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.brand,
                      shape: const StadiumBorder(),
                    ),
                    child: Text(s.add),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
