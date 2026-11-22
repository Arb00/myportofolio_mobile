/// Aturan validasi formulir. Dipisah dari tampilan agar mudah dibaca dan diuji.
/// Setiap fungsi mengembalikan pesan error, atau `null` jika nilainya valid.
class FormValidators {
  const FormValidators._();

  /// Menolak isian kosong, isian berisi spasi saja, dan isian yang terlalu panjang.
  static String? wajib(String? value, String label, {int maxLength = 100}) {
    final teks = value?.trim() ?? '';
    if (teks.isEmpty) return '$label tidak boleh kosong!';
    if (teks.length > maxLength) {
      return '$label maksimal $maxLength karakter!';
    }
    return null;
  }

  /// IPK bersifat opsional. Jika diisi, harus angka 0 sampai 4 (maksimal 2 desimal).
  /// Koma diterima karena lazim dipakai di Indonesia, misalnya `3,75`.
  static String? ipk(String? value) {
    final teks = value?.trim().replaceAll(',', '.') ?? '';
    if (teks.isEmpty) return null;

    if (!RegExp(r'^\d(\.\d{1,2})?$').hasMatch(teks)) {
      return 'IPK harus berupa angka, misalnya 3.75!';
    }
    if (double.parse(teks) > 4) return 'IPK harus di antara 0 dan 4!';
    return null;
  }

  /// Tanggal selesai wajib ada dan harus setelah tanggal mulai.
  static String? tanggalSelesai(DateTime? mulai, DateTime? selesai) {
    if (selesai == null) return 'Tanggal selesai tidak boleh kosong!';
    if (mulai != null && !selesai.isAfter(mulai)) {
      return 'Tanggal selesai harus setelah tanggal mulai!';
    }
    return null;
  }

  /// Mengubah tanggal menjadi format `dd/mm/yyyy` untuk ditampilkan.
  static String formatTanggal(DateTime tanggal) {
    final hari = tanggal.day.toString().padLeft(2, '0');
    final bulan = tanggal.month.toString().padLeft(2, '0');
    return '$hari/$bulan/${tanggal.year}';
  }
}
