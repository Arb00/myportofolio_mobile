import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // apiClient bisa diganti saat test, supaya tidak memanggil server sungguhan.
  MyApp({super.key, ApiClient? apiClient})
    : apiClient = apiClient ?? ApiClient();

  final ApiClient apiClient;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: apiClient),
        ChangeNotifierProvider(create: (context) => AuthState(apiClient)),
      ],
      child: _buildApp(),
    );
  }

  Widget _buildApp() {
    return MaterialApp(
      title: 'MyPortfolio',
      theme: ThemeData(
        // Satu set warna Material 3 dari warna dasar indigo,
        // dengan warna sekunder amber untuk kartu tombol aksi.
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          secondary: Colors.amber[700],
        ),
        useMaterial3: true,
      ),
      home: MyHomePage(),
    );
  }
}
