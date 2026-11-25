/// Alamat backend Django. Default `10.0.2.2` adalah alias `localhost` komputer
/// dari dalam emulator Android. Untuk Chrome atau backend yang sudah di-deploy:
/// `flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000`.
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:8000',
);
