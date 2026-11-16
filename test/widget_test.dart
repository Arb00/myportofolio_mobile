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

  testWidgets('Setiap tombol aksi punya warna latar berbeda', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    Color warnaTombol(String nama) {
      final material = tester.widget<Material>(
        find.ancestor(of: find.text(nama), matching: find.byType(Material)).first,
      );
      return material.color!;
    }

    expect(warnaTombol('Lihat Proyek'), Colors.blue);
    expect(warnaTombol('Tambah Proyek'), Colors.green);
    expect(warnaTombol('Logout'), Colors.red);
  });
}
