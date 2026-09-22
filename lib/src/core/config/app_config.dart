abstract final class AppConfig {
  static const appName = 'VastuSign';
  static const tagline = 'Clarity for every direction';
  static const supportEmail = 'support@vastusign.app';
  static const reportTemplateVersion = 'report-v1';
  static const ruleSetVersion = 'starter-rules-2026.09';
  static const apiBaseUrl = String.fromEnvironment('API_BASE_URL');

  static bool get cloudEnabled => apiBaseUrl.trim().isNotEmpty;
}
