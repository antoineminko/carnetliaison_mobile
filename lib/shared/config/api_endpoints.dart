class ApiEndpoints {
  static const String login = '/login/parent';
  static const String linkQrCode = '/liaison/qr';
  static const String linkSecretCode = '/liaison/code';

  static String parentChildren(int parentId) => '/parents/$parentId/children';
  
  static const String getConversation = '/messages/conversation';
  static const String sendMessage = '/messages';

  // Notifications Push
  static const String registerFcmToken = '/notifications/register-token';
}
