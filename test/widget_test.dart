import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myportofolio_mobile/main.dart';

void main() {
  testWidgets('Halaman menu menampilkan identitas dan tombol aksi', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Tiga InfoCard berisi identitas pemilik portofolio
    expect(find.text('2506623793'), findsOneWidget);
    expect(find.text('Muhammad Sabri'), findsOneWidget);
    expect(find.text('PBP C'), findsOneWidget);

    // Tiga ItemCard tombol aksi
    expect(find.text('Lihat Proyek'), findsOneWidget);
    expect(find.text('Tambah Proyek'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);
  });

  testWidgets('Menekan tombol aksi memunculkan SnackBar', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byIcon(Icons.folder));
    await tester.pump();

    expect(find.text('Kamu telah menekan tombol Lihat Proyek!'), findsOneWidget);
  });
}
