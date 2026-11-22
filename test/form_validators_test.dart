import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/utils/form_validators.dart';

void main() {
  group('wajib', () {
    test('menolak kosong, spasi saja, dan terlalu panjang', () {
      expect(FormValidators.wajib(null, 'Jurusan'), isNotNull);
      expect(FormValidators.wajib('   ', 'Jurusan'), isNotNull);
      expect(FormValidators.wajib('a' * 101, 'Jurusan'), isNotNull);
    });

    test('menerima isian normal dan tepat di batas panjang', () {
      expect(FormValidators.wajib('Ilmu Komputer', 'Jurusan'), isNull);
      expect(FormValidators.wajib('a' * 100, 'Jurusan'), isNull);
    });
  });

  group('ipk', () {
    test('menerima kosong dan nilai 0 sampai 4', () {
      for (final nilai in ['', '0', '3.75', '3,75', '4', '4.00']) {
        expect(FormValidators.ipk(nilai), isNull, reason: nilai);
      }
    });

    test('menolak nilai di luar rentang atau bukan angka', () {
      for (final nilai in ['4.01', '5', '-1', 'abc', '3.755', '1e0', '10']) {
        expect(FormValidators.ipk(nilai), isNotNull, reason: nilai);
      }
    });
  });

  group('tanggalSelesai', () {
    final mulai = DateTime(2025, 8, 1);

    test('menolak kosong, tanggal sama, dan sebelum tanggal mulai', () {
      expect(FormValidators.tanggalSelesai(mulai, null), isNotNull);
      expect(FormValidators.tanggalSelesai(mulai, mulai), isNotNull);
      expect(
        FormValidators.tanggalSelesai(mulai, DateTime(2025, 7, 31)),
        isNotNull,
      );
    });

    test('menerima tanggal setelah tanggal mulai', () {
      expect(
        FormValidators.tanggalSelesai(mulai, DateTime(2029, 7, 1)),
        isNull,
      );
    });
  });

  test('formatTanggal memakai dd/mm/yyyy', () {
    expect(FormValidators.formatTanggal(DateTime(2025, 8, 1)), '01/08/2025');
  });
}
