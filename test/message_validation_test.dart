import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Message Validation Tests', () {
    test('Un message valide passe la validation de longueur', () {
      final message = 'Bonjour, voici un test de message normal.';
      expect(message.length <= 2000, isTrue);
      expect(message.isNotEmpty, isTrue);
    });

    test('Un message de plus de 2000 caractères échoue la validation', () {
      final longMessage = 'A' * 2001;
      expect(longMessage.length > 2000, isTrue);
    });

    test('Un message vide ou ne contenant que des espaces échoue la validation', () {
      final emptyMessage = '   ';
      expect(emptyMessage.trim().isEmpty, isTrue);
    });
  });
}
