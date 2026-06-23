class AppSettings {
  final bool isDarkMode;
  final String currency;
  final bool notificationsEnabled;

  AppSettings({
    this.isDarkMode = false,
    this.currency = 'Bs.',
    this.notificationsEnabled = true,
  });

  AppSettings copyWith({
    bool? isDarkMode,
    String? currency,
    bool? notificationsEnabled,
  }) {
    return AppSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      currency: currency ?? this.currency,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}
