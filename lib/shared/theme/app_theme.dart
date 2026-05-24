import 'package:flutter/material.dart';

class AppTheme {
  // Palette de couleurs harmonisée
  static const Color forestGreen = Color(0xFF2596be); // Bleu Logo #2596be
  static const Color sunYellow = Color(0xFFFBC02D); // Jaune soleil soft
  static const Color seaBlue = Color(0xFF0077B6); // Bleu mer stylé

  static const Color primaryBlue = Color(0xFF2596be);
  static const Color background = Color(0xFFF8F9FB);
  static const Color loginBackground = Color(
    0xFFEFF3F6,
  ); // Soft off-white for login
  static const Color textDark = Color(0xFF2D3748);
  static const Color textGrey = Color(0xFF718096);

  // Style des cartes (basé sur l'accueil)
  static BoxDecoration cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.04),
        blurRadius: 15,
        offset: const Offset(0, 8),
      ),
    ],
  );

  // Style des boutons de validation
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: forestGreen,
    foregroundColor: Colors.white,
    elevation: 2,
    shadowColor: forestGreen.withOpacity(0.3),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    padding: const EdgeInsets.symmetric(vertical: 16),
  );

  // Style des boutons secondaires
  static ButtonStyle secondaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: seaBlue,
    foregroundColor: Colors.white,
    elevation: 2,
    shadowColor: seaBlue.withOpacity(0.3),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    padding: const EdgeInsets.symmetric(vertical: 16),
  );
}
