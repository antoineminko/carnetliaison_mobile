import 'package:flutter/material.dart';

class AppointmentUtils {
  /// Parse de façon sécurisée une date. Renvoie null en cas d'erreur.
  static DateTime? safeParseDate(dynamic dateString) {
    if (dateString == null || dateString.toString().isEmpty) {
      return null;
    }
    try {
      return DateTime.parse(dateString.toString());
    } catch (e) {
      return null;
    }
  }

  static Color getModeColor(String mode) {
    switch (mode) {
      case 'video': 
        return Colors.blue;
      case 'vocal':
        return Colors.orange;
      case 'presentiel':
      default:
        return Colors.green;
    }
  }

  static IconData getModeIcon(String mode) {
    switch (mode) {
      case 'video':
        return Icons.videocam;
      case 'vocal':
        return Icons.phone;
      case 'presentiel':
      default:
        return Icons.location_on;
    }
  }

  static String getModeLabel(String mode) {
    switch (mode) {
      case 'video':
        return 'Appel Vidéo';
      case 'vocal':
        return 'Appel Vocal';
      case 'presentiel':
      default:
        return 'Rendez-vous Présentiel';
    }
  }

  static Widget buildStatusBadge(String status) {
    Color bgColor;
    Color textColor = Colors.white;
    String label;

    switch (status) {
      case 'accepte':
        bgColor = Colors.green;
        label = 'Accepté';
        break;
      case 'refuse':
        bgColor = Colors.red[400]!;
        label = 'Refusé';
        break;
      case 'reporte':
        bgColor = Colors.orange;
        label = 'Reporté';
        break;
      case 'cancelled':
        bgColor = Colors.grey[500]!;
        label = 'Annulé';
        break;
      default:
        bgColor = Colors.blue;
        label = 'En attente';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
