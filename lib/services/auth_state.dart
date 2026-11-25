import 'package:flutter/foundation.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

/// Menyimpan token login dan memberi tahu widget saat status login berubah.
// shortcut: token hanya di memori, jadi hilang saat aplikasi ditutup; pakai
// flutter_secure_storage kalau login perlu bertahan.
class AuthState extends ChangeNotifier {
  AuthState(this._api);

  final ApiClient _api;
  String? _token;

  String? get token => _token;
  bool get isLoggedIn => _token != null;

  Future<void> login(String username, String password) async {
    _token = await _api.obtainToken(username, password);
    notifyListeners();
  }

  Future<void> logout() async {
    final token = _token;
    if (token == null) return;
    try {
      await _api.logout(token);
    } on Exception {
      // Token sudah tidak berlaku atau server tidak terjangkau:
      // logout di sisi aplikasi tetap dilakukan.
    } finally {
      _token = null;
      notifyListeners();
    }
  }
}
