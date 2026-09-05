import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_mobile/features/appointments/utils/appointment_utils.dart';

void main() {
  group('AppointmentUtils - safeParseDate', () {
    test('devrait parser correctement une date valide ISO 8601', () {
      // Arrange
      const dateString = '2026-09-03T14:30:00.000Z';
      
      // Act
      final result = AppointmentUtils.safeParseDate(dateString);
      
      // Assert
      expect(result, isNotNull);
      expect(result?.year, equals(2026));
      expect(result?.month, equals(9));
      expect(result?.day, equals(3));
    });

    test('devrait renvoyer null si la date est null', () {
      // Act
      final result = AppointmentUtils.safeParseDate(null);
      
      // Assert
      expect(result, isNull);
    });

    test('devrait renvoyer null si la chaîne est vide', () {
      // Act
      final result = AppointmentUtils.safeParseDate('');
      
      // Assert
      expect(result, isNull);
    });

    test('devrait renvoyer null si le format est invalide', () {
      // Arrange
      const dateString = 'ceci n\'est pas une date';
      
      // Act
      final result = AppointmentUtils.safeParseDate(dateString);
      
      // Assert
      expect(result, isNull);
    });

    test('devrait gérer d\'autres types dynamiques (ex: int)', () {
      // Arrange
      const notAString = 12345;
      
      // Act
      final result = AppointmentUtils.safeParseDate(notAString);
      
      // Assert
      expect(result, isNull);
    });
  });

  group('AppointmentUtils - UI Helpers', () {
    test('getModeColor devrait renvoyer la bonne couleur', () {
      expect(AppointmentUtils.getModeColor('video'), equals(Colors.blue));
      expect(AppointmentUtils.getModeColor('vocal'), equals(Colors.orange));
      expect(AppointmentUtils.getModeColor('presentiel'), equals(Colors.green));
      expect(AppointmentUtils.getModeColor('inconnu'), equals(Colors.green)); // Default
    });

    test('getModeLabel devrait renvoyer le bon libellé', () {
      expect(AppointmentUtils.getModeLabel('video'), equals('Appel Vidéo'));
      expect(AppointmentUtils.getModeLabel('vocal'), equals('Appel Vocal'));
      expect(AppointmentUtils.getModeLabel('presentiel'), equals('Rendez-vous Présentiel'));
    });
  });
}
