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

  testWidgets('Logout meminta konfirmasi dan bisa dibatalkan', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byIcon(Icons.logout));
    await tester.pumpAndSettle();

    // SnackBar wajib tetap muncul, ditambah dialog konfirmasi.
    expect(find.text('Kamu telah menekan tombol Logout!'), findsOneWidget);
    expect(find.text('Yakin ingin keluar dari MyPortfolio?'), findsOneWidget);

    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Logout dibatalkan.'), findsOneWidget);
  });

  testWidgets('Logout yang dikonfirmasi menampilkan pesan berhasil', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byIcon(Icons.logout));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Logout'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Logout berhasil.'), findsOneWidget);
  });

  testWidgets('Tombol tanpa konfirmasi tidak membuka dialog', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byIcon(Icons.add_circle));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Kamu telah menekan tombol Tambah Proyek!'), findsOneWidget);
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
