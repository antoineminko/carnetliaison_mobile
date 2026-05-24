import 'package:flutter/material.dart';

class BackgroundWrapper extends StatelessWidget {
  final Widget child;
  final bool isSubtle;

  const BackgroundWrapper({
    super.key, 
    required this.child, 
    this.isSubtle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints.expand(), // Étend le fond sur tout l'écran
      decoration: BoxDecoration(
        color: isSubtle ? const Color(0xFFF8F9FB) : const Color(0xFFEFF3F6),
        image: DecorationImage(
          image: const AssetImage('assets/images/font.png'),
          fit: BoxFit.none, // On garde la taille réelle
          repeat: ImageRepeat.repeat, // Effet papier peint répété
          opacity: isSubtle ? 0.30 : 0.70, // Visibilité forte demandée
        ),
      ),
      child: child,
    );
  }
}
