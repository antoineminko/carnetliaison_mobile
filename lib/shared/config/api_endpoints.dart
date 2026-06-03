class ApiEndpoints {
  static const String login = '/login/parent';
  static const String loginTeacher = '/login/teacher';
  static const String linkQrCode = '/liaison/qr';
  static const String linkSecretCode = '/liaison/code';

  static String parentChildren(int parentId) => '/parents/$parentId/children';
  
  static String teacherDashboard(int teacherId) => '/enseignants/$teacherId/dashboard';
  static String classDetails(int teacherId, int classId) => '/enseignants/$teacherId/classes/$classId';
  static String studentInfo(int studentId) => '/enseignants/student/$studentId/info';

  static const String getConversation = '/messages/conversation';
  static const String sendMessage = '/messages';
  static String parentConversations(int parentId) => '/parents/$parentId/conversations';
  static String teacherConversations(int teacherId) => '/enseignants/$teacherId/conversations';

  // Notifications Push
  static const String registerFcmToken = '/notifications/register-token';
  static String userNotifications(String role, int userId) => '/users/$role/$userId/notifications';
  static String markNotificationRead(int notificationId) => '/notifications/$notificationId/read';
}
