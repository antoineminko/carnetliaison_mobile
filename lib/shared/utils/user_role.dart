import 'package:flutter/material.dart';

enum UserRole {
  parent,
  teacher,
  student;

  String get label {
    switch (this) {
      case UserRole.parent:
        return 'Espace Parents';
      case UserRole.teacher:
        return 'Espace Enseignants';
      case UserRole.student:
        return 'Espace Élèves';
    }
  }

  Color get color {
    switch (this) {
      case UserRole.parent:
        return const Color(0xFF6750A4); // Purple
      case UserRole.teacher:
        return const Color(0xFF2E7D32); // Green
      case UserRole.student:
        return const Color(0xFF0D47A1); // Blue
    }
  }

  IconData get icon {
    switch (this) {
      case UserRole.parent:
        return Icons.family_restroom;
      case UserRole.teacher:
        return Icons.school;
      case UserRole.student:
        return Icons.backpack;
    }
  }

  bool get hasQrCode {
    return this == UserRole.parent || this == UserRole.teacher;
  }

  String get imagePath {
    switch (this) {
      case UserRole.parent:
        return 'assets/images/parent.png';
      case UserRole.teacher:
        return 'assets/images/teacher.png';
      case UserRole.student:
        return 'assets/images/eleve.png';
    }
  }
}
