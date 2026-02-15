/// API Constants for Effulgence'26 App
class ApiConstants {
  ApiConstants._();

  // Base URL - Change this based on environment
  static const String baseUrl = 'https://api.effulgence26.in/';

  // API Endpoints
  static const String health = '/health';

  // Auth Endpoints
  static const String signup = '/user/signup';
  static const String verifyOtp = '/user/verify-otp';
  static const String resendOtp = '/user/resend-otp';

  static const String login = '/user/login';
  static const String logout = '/user/logout';

  // Profile Endpoints
  static const String profile = '/user/profile';
  static const String profileEdit = '/user/profile/edit';

  // QR Code
  static const String qrCode = '/user/qrcode';
  static const String verifyQrCode = '/user/qrcode/verify';

  // Events Endpoints
  // GET /events - Get all events (public)
  static const String events = '/events';

  // POST /events/create - Create new event (admin only)
  static const String createEvent = '/events/create';

  // PATCH /events/{eventId}/edit - Update event (admin only)
  static const String editEvent = '/events/'; // + eventId + '/edit'

  // PATCH /events/{eventId}/delete - Soft delete event (admin only)
  static const String deleteEvent = '/events/'; // + eventId + '/delete'

  // PATCH /events/{eventId}/restore-event - Restore deleted event (admin only)
  static const String restoreEvent = '/events/'; // + eventId + '/restore-event'

  // GET /events/{eventId} - Get event details (public)
  static const String eventDetails = '/events/'; // + eventId

  // POST /events/register - Register for event (authenticated users)
  static const String registerEvent = '/events/register';

  // GET /events/registrations/{eventId} - Get event registrations (admin/member)
  static const String eventRegistrations =
      '/events/registrations/'; // + eventId

  // POST /events/{eventId}/create-team - Create team for team event (users)
  static const String createTeam = '/events/'; // + eventId + '/create-team'

  // GET /events/{eventId}/get-public-teams - Get public teams (public)
  static const String getPublicTeams =
      '/events/'; // + eventId + '/get-public-teams'

  // Domains Endpoints
  static const String domains = '/domains';
  static const String domainDetails = '/domains/'; // + domainId

  // Users Endpoints (Admin)
  static const String users = '/user/users';
  static const String externalUsers = '/user/users/external';
  static const String updateRole = '/user/update-role';
  static const String approveStatus = '/user/approveStatus';
  static const String userRegisteredEvents =
      '/user/'; // + userId + '/registered-events'

  // Notifications Endpoints
  static const String updateFcmToken = '/notifications/update-token';
  static const String notifications = '/notifications';
  static const String markNotificationRead = '/notifications/'; // + notificationId + '/read'
  static const String markAllNotificationsRead = '/notifications/read-all';
  static const String broadcastNotification = '/notifications/broadcast';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
