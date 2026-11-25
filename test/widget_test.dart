import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

// Backend Django palsu, supaya test tidak butuh server sungguhan.
const tokenValid = 'abc123';
late List<http.Request> permintaan;
late bool gagalGetProyek;
late bool tokenDitolak;

MockClient backendPalsu() => MockClient((request) async {
  permintaan.add(request);
  final token = request.headers['Authorization'];
  switch ('${request.method} ${request.url.path}') {
    case 'GET /api/v1/projects/':
      if (gagalGetProyek) return http.Response('error', 500);
      return http.Response(
        jsonEncode([
          {
            'id': 1,
            'title': 'Proyek Django',
            'description': 'Backend portofolio',
            'tech_stack': 'Django, DRF',
            'project_url': 'https://github.com/contoh/django',
            'project_image_url': '',
          },
        ]),
        200,
      );
    case 'POST /api/v1/auth/token/':
      final body = jsonDecode(request.body);
      if (body['username'] == 'sabri' && body['password'] == 'rahasia') {
        return http.Response(jsonEncode({'token': tokenValid}), 200);
      }
      return http.Response('{}', 400);
    case 'POST /api/v1/projects/':
      if (tokenDitolak || token != 'Token $tokenValid') {
        return http.Response('{}', 401);
      }
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      return http.Response(jsonEncode({...body, 'id': 2}), 201);
    case 'POST /api/v1/auth/logout/':
      return http.Response('', 204);
  }
  return http.Response('', 404);
});

MyApp buatApp() => MyApp(
  apiClient: ApiClient(client: backendPalsu(), baseUrl: 'http://tes'),
);

Future<void> isiLogin(
  WidgetTester tester, {
  String password = 'rahasia',
}) async {
  expect(find.widgetWithText(FilledButton, 'Login'), findsOneWidget);
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Username'),
    'sabri',
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Password'),
    password,
  );
  await tester.tap(find.widgetWithText(FilledButton, 'Login'));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    permintaan = [];
    gagalGetProyek = false;
    tokenDitolak = false;
  });

  testWidgets('Halaman menu menampilkan identitas dan tombol aksi', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buatApp());

    // Tiga InfoCard berisi identitas pemilik portofolio
    expect(find.text('2506623793'), findsOneWidget);
    expect(find.text('Muhammad Sabri'), findsOneWidget);
    expect(find.text('PBP C'), findsOneWidget);

    // Tiga ItemCard tombol aksi
    expect(find.text('Lihat Proyek'), findsOneWidget);
    expect(find.text('Tambah Proyek'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);
  });

  testWidgets('Menekan tombol aksi memunculkan SnackBar', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buatApp());

    await tester.tap(find.byIcon(Icons.folder));
    await tester.pump();

    expect(
      find.text('Kamu telah menekan tombol Lihat Proyek!'),
      findsOneWidget,
    );
  });

  testWidgets('Logout meminta konfirmasi dan bisa dibatalkan', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buatApp());

    await tester.ensureVisible(find.byIcon(Icons.logout));
    await tester.pumpAndSettle();
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

  testWidgets('Logout yang dikonfirmasi menampilkan pesan berhasil', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buatApp());

    await tester.ensureVisible(find.byIcon(Icons.logout));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.logout));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Logout'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Logout berhasil.'), findsOneWidget);
  });

  testWidgets('Tombol tanpa konfirmasi tidak membuka dialog', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buatApp());

    await tester.tap(find.byIcon(Icons.add_circle));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(
      find.text('Kamu telah menekan tombol Tambah Proyek!'),
      findsOneWidget,
    );
  });

  testWidgets('Setiap tombol aksi punya warna latar berbeda', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buatApp());

    Color warnaTombol(String nama) {
      final material = tester.widget<Material>(
        find
            .ancestor(of: find.text(nama), matching: find.byType(Material))
            .first,
      );
      return material.color!;
    }

    expect(warnaTombol('Lihat Proyek'), Colors.blue);
    expect(warnaTombol('Tambah Proyek'), Colors.green);
    expect(warnaTombol('Logout'), Colors.red);
  });

  testWidgets('Tombol Tambah Proyek meminta login, lalu membuka form', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buatApp());

    await tester.tap(find.byIcon(Icons.add_circle));
    await tester.pumpAndSettle();
    await isiLogin(tester);
    expect(find.text('Add Project Form'), findsOneWidget);

    // push() menumpuk halaman, jadi pop() kembali ke menu.
    final NavigatorState navigator = tester.state(find.byType(Navigator));
    navigator.pop();
    await tester.pumpAndSettle();
    expect(find.text('Selamat datang di MyPortfolio Mobile!'), findsOneWidget);
  });

  testWidgets('Drawer berpindah antara Home dan Add Project', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buatApp());

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    expect(
      find.text('Explore personal projects and experiences!'),
      findsOneWidget,
    );

    await tester.tap(find.text('Add Project'));
    await tester.pumpAndSettle();
    await isiLogin(tester);
    expect(find.text('Add Project Form'), findsOneWidget);

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Selamat datang di MyPortfolio Mobile!'), findsOneWidget);
  });

  Future<void> bukaFormProyek(WidgetTester tester) async {
    await tester.pumpWidget(buatApp());
    await tester.tap(find.byIcon(Icons.add_circle));
    await tester.pumpAndSettle();
    await isiLogin(tester);
  }

  Future<void> isiFormProyek(WidgetTester tester) async {
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nama Proyek'),
      'MyPortfolio',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Deskripsi Proyek'),
      'Aplikasi portofolio',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Teknologi yang Digunakan'),
      'Flutter, Django',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Tautan Proyek'),
      'https://github.com/contoh/app',
    );
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
  }

  testWidgets('Batal login tidak membuka form proyek', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buatApp());
    await tester.tap(find.byIcon(Icons.add_circle));
    await tester.pumpAndSettle();

    final NavigatorState navigator = tester.state(find.byType(Navigator));
    navigator.pop();
    await tester.pumpAndSettle();

    expect(find.text('Add Project Form'), findsNothing);
    expect(find.text('Selamat datang di MyPortfolio Mobile!'), findsOneWidget);
  });

  testWidgets('Password salah menampilkan pesan dan tetap di halaman login', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buatApp());
    await tester.tap(find.byIcon(Icons.add_circle));
    await tester.pumpAndSettle();
    await isiLogin(tester, password: 'salah');

    expect(
      find.text('Login gagal (HTTP 400): username atau password salah.'),
      findsOneWidget,
    );
    expect(find.widgetWithText(FilledButton, 'Login'), findsOneWidget);
  });

  testWidgets('Form menolak isian kosong dan URL tidak valid', (
    WidgetTester tester,
  ) async {
    await bukaFormProyek(tester);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Tautan Proyek'),
      'bukan-url',
    );
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Nama proyek tidak boleh kosong!'), findsOneWidget);
    expect(find.text('Deskripsi proyek tidak boleh kosong!'), findsOneWidget);
    expect(
      find.text('Tautan proyek harus berupa URL, misalnya https://contoh.com!'),
      findsOneWidget,
    );
    expect(find.byType(AlertDialog), findsNothing);
    expect(permintaan.where((r) => r.url.path == '/api/v1/projects/'), isEmpty);
  });

  testWidgets('Form valid dikirim dengan token lalu direset', (
    WidgetTester tester,
  ) async {
    await bukaFormProyek(tester);
    await isiFormProyek(tester);

    final post = permintaan.last;
    expect(post.method, 'POST');
    expect(post.url.path, '/api/v1/projects/');
    expect(post.headers['Authorization'], 'Token $tokenValid');
    expect(jsonDecode(post.body), {
      'title': 'MyPortfolio',
      'description': 'Aplikasi portofolio',
      'tech_stack': 'Flutter, Django',
      'project_url': 'https://github.com/contoh/app',
      'project_image_url': '',
    });

    expect(find.text('Proyek berhasil ditambahkan!'), findsOneWidget);
    expect(find.text('Nama Proyek: MyPortfolio'), findsOneWidget);
    expect(find.text('Teknologi: Flutter, Django'), findsOneWidget);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('MyPortfolio'), findsNothing);
  });

  testWidgets('Token ditolak (401) membuat logout dan meminta login lagi', (
    WidgetTester tester,
  ) async {
    await bukaFormProyek(tester);
    tokenDitolak = true;
    await isiFormProyek(tester);

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.widgetWithText(FilledButton, 'Login'), findsOneWidget);
    expect(permintaan.last.url.path, '/api/v1/auth/logout/');
  });

  testWidgets('Lihat Proyek menampilkan data dari API dan detailnya', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buatApp());
    await tester.tap(find.byIcon(Icons.folder));
    await tester.pumpAndSettle();

    expect(find.text('Proyek Django'), findsOneWidget);
    await tester.tap(find.text('Proyek Django'));
    await tester.pumpAndSettle();
    expect(find.text('Backend portofolio'), findsOneWidget);
    expect(find.text('https://github.com/contoh/django'), findsOneWidget);
  });

  testWidgets('Daftar proyek menampilkan error dan Retry memuat ulang', (
    WidgetTester tester,
  ) async {
    gagalGetProyek = true;
    await tester.pumpWidget(buatApp());
    await tester.tap(find.byIcon(Icons.folder));
    await tester.pumpAndSettle();
    expect(find.text('Gagal memuat proyek.'), findsOneWidget);

    gagalGetProyek = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Proyek Django'), findsOneWidget);
  });

  testWidgets('Logout lewat kartu memanggil API dan drawer kembali ke Login', (
    WidgetTester tester,
  ) async {
    await bukaFormProyek(tester);
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    expect(find.text('Logout'), findsOneWidget);
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byIcon(Icons.logout));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.logout));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Logout'));
    await tester.pumpAndSettle();

    expect(permintaan.last.url.path, '/api/v1/auth/logout/');
    expect(permintaan.last.headers['Authorization'], 'Token $tokenValid');

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    expect(find.text('Login'), findsOneWidget);
  });

  group('Formulir Edukasi', () {
    // Ukuran layar ponsel, untuk memastikan tombol Simpan tetap terjangkau.
    void pakaiLayarPonsel(WidgetTester tester) {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
    }

    Future<void> bukaDariKartu(WidgetTester tester) async {
      await tester.pumpWidget(buatApp());
      await tester.ensureVisible(find.byIcon(Icons.school));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.school));
      await tester.pumpAndSettle();
    }

    Future<void> tekanSimpan(WidgetTester tester) async {
      // Gulir sampai bawah seperti pengguna, supaya Simpan berada di atas SnackBar.
      // Lepas fokus dulu, karena kolom yang fokus menarik gulir kembali ke dirinya.
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump();
      final ScrollableState scrollForm = tester.state(
        find
            .descendant(
              of: find.byType(Form),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      scrollForm.position.jumpTo(scrollForm.position.maxScrollExtent);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();
    }

    testWidgets('Bisa dibuka dari drawer dan Home kembali ke menu', (
      tester,
    ) async {
      await tester.pumpWidget(buatApp());

      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add Education'));
      await tester.pumpAndSettle();
      expect(find.text('Add Education Form'), findsOneWidget);

      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(
        find.text('Selamat datang di MyPortfolio Mobile!'),
        findsOneWidget,
      );
    });

    testWidgets(
      'Home dari form yang dibuka lewat kartu tidak menumpuk halaman',
      (tester) async {
        await bukaDariKartu(tester);

        await tester.tap(find.byTooltip('Open navigation menu'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Home'));
        await tester.pumpAndSettle();

        final NavigatorState navigator = tester.state(find.byType(Navigator));
        expect(navigator.canPop(), isFalse);
      },
    );

    testWidgets(
      'Input tidak valid memunculkan error dan tidak membuka dialog',
      (tester) async {
        pakaiLayarPonsel(tester);
        await bukaDariKartu(tester);

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Nama Institusi'),
          '   ',
        );
        await tekanSimpan(tester);

        expect(find.byType(AlertDialog), findsNothing);
        await tester.dragUntilVisible(
          find.text('Nama institusi tidak boleh kosong!'),
          find.byType(SingleChildScrollView),
          const Offset(0, 100),
        );
        expect(find.text('Nama institusi tidak boleh kosong!'), findsOneWidget);
      },
    );

    testWidgets('Input valid menampilkan semua isian di dialog', (
      tester,
    ) async {
      pakaiLayarPonsel(tester);
      await bukaDariKartu(tester);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nama Institusi'),
        'Universitas Indonesia',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Jurusan'),
        'Ilmu Komputer',
      );

      await tester.ensureVisible(
        find.widgetWithText(TextFormField, 'Tanggal Mulai'),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextFormField, 'Tanggal Mulai'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('1'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byType(SwitchListTile));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();
      expect(
        find.widgetWithText(TextFormField, 'Tanggal Selesai'),
        findsNothing,
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'IPK (opsional)'),
        '3,75',
      );
      await tekanSimpan(tester);

      expect(find.text('Ringkasan Edukasi'), findsOneWidget);
      expect(find.text('Institusi: Universitas Indonesia'), findsOneWidget);
      expect(find.text('Jenjang: S1'), findsOneWidget);
      expect(find.text('Jurusan: Ilmu Komputer'), findsOneWidget);
      expect(find.text('Tanggal Selesai: Masih berjalan'), findsOneWidget);
      expect(find.text('IPK: 3.75'), findsOneWidget);

      await tester.tap(find.text('Tutup'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('Add Education Form'), findsOneWidget);
    });
  });
}
