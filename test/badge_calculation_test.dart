import 'package:flutter_test/flutter_test.dart';
import 'package:app_mobile/features/teacher/messages/chat_page.dart';

void main() {
  group('Badge Calculation Logic Tests', () {
    test('Calcul des badges en ignorant la conversation active', () {
      // Mock de 3 conversations
      final conversations = [
        {'id': 1, 'unread_count': 1},
        {'id': 2, 'unread_count': 2},
        {'id': 3, 'unread_count': 3},
      ];

      // Fonction simulant le getter _totalUnreadMessages
      int calculateTotalUnread() {
        int total = 0;
        for (var c in conversations) {
          if (ChatPage.activeConversationId != null && c['id'] == ChatPage.activeConversationId) {
            continue;
          }
          final val = c['unread_count'];
          total += (val is int) ? val : (int.tryParse(val?.toString() ?? '0') ?? 0);
        }
        return total;
      }

      // Test sans conversation active (devrait être 1 + 2 + 3 = 6)
      ChatPage.activeConversationId = null;
      expect(calculateTotalUnread(), 6);

      // Test avec la conversation 2 active (devrait ignorer la conv 2 -> 1 + 3 = 4)
      ChatPage.activeConversationId = 2;
      expect(calculateTotalUnread(), 4);
    });
  });
}
