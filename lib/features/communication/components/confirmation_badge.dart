import 'package:flutter/material.dart';

class ConfirmationBadge extends StatelessWidget {
  const ConfirmationBadge({super.key});
  @override
  Widget build(BuildContext context) {
    return const Chip(label: Text('Confirmed'));
  }
}
