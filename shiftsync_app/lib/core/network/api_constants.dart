/// ApiConstants — Centralized HTTP and WebSocket endpoints for Shiftak Python FastAPI backend.
class ApiConstants {
  // Base URL pointing to local FastAPI server (works seamlessly for Edge/Windows targets)
  static const String baseUrl = 'http://localhost:8000/api/v1';
  static const String wsBaseUrl = 'ws://localhost:8000/api/v1/ws';

  // Auth & Family Link Endpoints
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String me = '/auth/me';
  static const String familyLinks = '/auth/family-links';

  // Department Endpoints
  static const String departments = '/departments/';

  // Schedule Endpoints
  static const String schedules = '/schedules/';

  // Swap & Marketplace Endpoints
  static const String swaps = '/swaps/';
  static const String marketplace = '/marketplace/';

  // Financial Ledger & EGP Settlement Endpoints
  static const String ledger = '/ledger/';
  static String settleDebt(int ledgerId) => '/ledger/$ledgerId/settle';
}
