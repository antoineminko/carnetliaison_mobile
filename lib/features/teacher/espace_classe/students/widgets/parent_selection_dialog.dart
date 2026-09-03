import 'package:flutter/material.dart';
import 'package:app_mobile/shared/theme/app_theme.dart';

void showParentSelectionDialog({
  required BuildContext context,
  required List<dynamic> parents,
  required Function(List<int>) onConfirm,
}) {
  showDialog(
    context: context,
    builder: (context) => _ParentSelectionDialogContent(
      parents: parents,
      onConfirm: onConfirm,
    ),
  );
}

class _ParentSelectionDialogContent extends StatefulWidget {
  final List<dynamic> parents;
  final Function(List<int>) onConfirm;

  const _ParentSelectionDialogContent({
    required this.parents,
    required this.onConfirm,
  });

  @override
  State<_ParentSelectionDialogContent> createState() => _ParentSelectionDialogContentState();
}

class _ParentSelectionDialogContentState extends State<_ParentSelectionDialogContent> {
  final Set<int> _selectedIds = {};

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Choisir le(s) parent(s)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: widget.parents.map((parent) {
            final int id = parent['id'];
            final String name = "${parent['prenom']} ${parent['nom']}";
            final String relation = parent['relation'] ?? 'Parent';

            return CheckboxListTile(
              title: Text(relation, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(name),
              value: _selectedIds.contains(id),
              activeColor: AppTheme.seaBlue,
              onChanged: (bool? checked) {
                setState(() {
                  if (checked == true) {
                    _selectedIds.add(id);
                  } else {
                    _selectedIds.remove(id);
                  }
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler', style: TextStyle(color: AppTheme.textGrey)),
        ),
        ElevatedButton(
          onPressed: _selectedIds.isNotEmpty
              ? () {
                  Navigator.pop(context);
                  widget.onConfirm(_selectedIds.toList());
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.seaBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Valider'),
        ),
      ],
    );
  }
}
