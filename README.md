# MyPortfolio Mobile

Aplikasi mobile Flutter untuk portofolio pribadi, bagian dari Proyek Individu mata kuliah Pemrograman Berbasis Platform (PBP) Fasilkom UI, Gasal 2026/2027. Aplikasi ini adalah klien mobile dari website portofolio Django (`myportofolio`) dan nantinya akan terhubung ke API DRF di backend tersebut.

| | |
|---|---|
| **Nama** | Muhammad Sabri |
| **NPM** | 2506623793 |
| **Kelas** | PBP C |

## Fitur Saat Ini

- Halaman utama `MyHomePage` (StatelessWidget) di `lib/screens/menu.dart`, terpisah dari `lib/main.dart`.
- Drawer menu (`lib/widgets/left_drawer.dart`) untuk berpindah ke Home dan Add Project.
- Halaman form tambah proyek (`lib/screens/project_form.dart`) dengan validasi; data yang valid ditampilkan di pop-up.
- Tiga `InfoCard` berisi NPM, nama, dan kelas.
- Tiga tombol aksi `ItemCard` dengan warna latar berbeda: **Lihat Proyek** (biru), **Tambah Proyek** (hijau), dan **Logout** (merah).
- Setiap tombol memunculkan SnackBar "Kamu telah menekan tombol [Nama Tombol]!".
- **Fitur tambahan:** tombol Logout membuka dialog konfirmasi (Batal / Logout). Setelah memilih, SnackBar menampilkan "Logout berhasil." atau "Logout dibatalkan.". Konfirmasi diatur lewat atribut opsional `pesanKonfirmasi` di model `ItemHomepage`, jadi tombol lain bisa memakainya tanpa mengubah `ItemCard`.
- Widget test untuk identitas, SnackBar, warna tombol, dan alur konfirmasi Logout (`test/widget_test.dart`).

## Cara Menjalankan

Prasyarat: Flutter SDK (Dart sudah termasuk) dan Google Chrome atau Android emulator. Pastikan `flutter doctor` tidak menunjukkan error untuk target yang dipakai.

```bash
git clone https://github.com/Arb00/myportofolio_mobile.git
cd myportofolio_mobile
flutter pub get
flutter run -d chrome    # atau `flutter run` untuk emulator/HP Android
```

Pemeriksaan kualitas kode:

```bash
flutter analyze   # harus "No issues found!"
flutter test
```

## Progres Mingguan

| Minggu | Pekerjaan |
|---|---|
| Tutorial 08 | Inisialisasi proyek, pemisahan `menu.dart`, `MyHomePage` jadi Stateless, `InfoCard`, `ItemCard`, SnackBar |
| Tugas 7 | Atribut `color` pada `ItemHomepage` agar tiap tombol punya warna sendiri, dialog konfirmasi Logout, widget test, README |
| Tutorial 09 | Drawer menu (`LeftDrawer`), form tambah proyek dengan validasi (`ProjectFormPage`), navigasi tombol Tambah Proyek, refactor ke `lib/screens/` dan `lib/widgets/` |

---

### Tugas 7

1. **Widget tree dan hubungan parent-child**

   Di Flutter, seluruh UI dibangun dari widget yang tersusun bertingkat seperti pohon. Widget paling atas (root) membungkus widget lain sebagai anak (`child` untuk satu anak, `children` untuk banyak anak), dan anak-anak itu bisa membungkus widget lain lagi. Di aplikasi ini urutannya kira-kira `MyApp → MaterialApp → MyHomePage → Scaffold → Padding → Column → Row/GridView → InfoCard/ItemCard → ...`.

   Hubungan parent-child bekerja dua arah:
   - **Parent memberi batasan dan data ke child.** Parent menentukan batas ukuran (constraints) yang boleh dipakai child, lalu menentukan posisinya. Contohnya `Padding` memberi jarak, `Column` menyusun anak secara vertikal, dan `Row` secara horizontal. Data juga diteruskan lewat konstruktor, seperti `InfoCard(title: 'NPM', content: npm)`.
   - **Child melaporkan ukurannya ke parent.** Prinsip layout Flutter: *constraints go down, sizes go up, parent sets position*.
   - **Child bisa membaca data dari leluhurnya** lewat `BuildContext`, misalnya `Theme.of(context)` mengambil tema dari `MaterialApp` di atasnya.

2. **Widget yang digunakan dan fungsinya**

   | Widget | Fungsi |
   |---|---|
   | `MyApp` | Root widget aplikasi (StatelessWidget) yang mengembalikan `MaterialApp`. |
   | `MaterialApp` | Menyediakan tema, navigasi, dan konfigurasi Material Design untuk seluruh aplikasi. |
   | `MyHomePage` | Halaman menu utama (StatelessWidget) yang berisi identitas dan tombol aksi. |
   | `Scaffold` | Kerangka halaman Material: tempat `AppBar`, `body`, dan tampilan SnackBar. |
   | `AppBar` | Bar judul "MyPortfolio" di bagian atas halaman. |
   | `Text` | Menampilkan teks (judul, isi kartu, pesan sambutan, label tombol). |
   | `Padding` | Memberi jarak di sekeliling widget anaknya. |
   | `Column` | Menyusun anak-anaknya secara vertikal. |
   | `Row` | Menyusun tiga `InfoCard` secara horizontal. |
   | `Center` | Menempatkan anaknya di tengah ruang yang tersedia. |
   | `SizedBox` | Memberi ruang kosong dengan ukuran tetap di antara widget. |
   | `InfoCard` | Widget buatan sendiri: kartu berisi judul dan isi (NPM, Name, Class). |
   | `Card` | Kartu Material dengan bayangan (elevation), dipakai di `InfoCard`. |
   | `Container` | Mengatur lebar dan padding isi kartu. |
   | `GridView.count` | Menyusun tombol aksi dalam grid 3 kolom. |
   | `ItemCard` | Widget buatan sendiri: tombol kartu berikon yang warnanya diambil dari model `ItemHomepage`. |
   | `Material` | Memberi warna latar dan sudut membulat pada `ItemCard`, sekaligus permukaan untuk efek ripple. |
   | `InkWell` | Membuat area kartu bisa ditekan (`onTap`) dengan efek ripple. |
   | `Icon` | Menampilkan ikon tombol (folder, add_circle, logout). |
   | `ScaffoldMessenger` | Mengelola SnackBar: menyembunyikan yang lama lalu menampilkan yang baru. |
   | `SnackBar` | Notifikasi singkat di bawah layar setelah tombol ditekan. |
   | `AlertDialog` | Dialog konfirmasi yang muncul saat tombol Logout ditekan. |
   | `TextButton` | Tombol "Batal" di dialog konfirmasi. |
   | `FilledButton` | Tombol "Logout" di dialog konfirmasi, berwarna sama dengan kartu Logout. |

   `ItemHomepage` bukan widget, melainkan kelas model data biasa (nama, ikon, warna) yang dipakai untuk membangun `ItemCard`.

3. **Fungsi `MaterialApp` dan alasannya dipakai sebagai root**

   `MaterialApp` adalah widget pembungkus aplikasi bergaya Material Design. Widget ini menyediakan:
   - tema global (`theme`, `ColorScheme`) yang bisa dibaca semua widget di bawahnya lewat `Theme.of(context)`;
   - sistem navigasi (`Navigator`, routes, halaman `home`);
   - lokalisasi, arah teks, judul aplikasi, dan konfigurasi dasar lain.

   Widget ini diletakkan di root karena banyak widget Material (`Scaffold`, `AppBar`, `SnackBar`, `InkWell`) membutuhkan data yang hanya disediakan leluhur seperti `MaterialApp`. Kalau dipasang di root, semua halaman otomatis mendapat tema dan navigasi yang sama.

4. **`StatelessWidget` vs `StatefulWidget`**

   - **`StatelessWidget`** tidak punya state yang berubah. Tampilannya hanya bergantung pada data dari konstruktor dan dari leluhurnya. Widget ini dibangun ulang hanya ketika parent-nya membangun ulang dengan data baru.
   - **`StatefulWidget`** dipasangkan dengan objek `State` yang menyimpan data yang bisa berubah selama widget hidup. Memanggil `setState()` memberi tahu Flutter agar menjalankan `build` lagi dengan data terbaru.

   Pilih `StatelessWidget` untuk tampilan statis yang hanya menampilkan data, seperti halaman menu ini (identitas dan tombol tidak berubah). Pilih `StatefulWidget` ketika widget harus mengingat dan mengubah data sendiri, misalnya counter, input form, checkbox, animasi, atau data hasil fetch API yang awalnya kosong lalu terisi.

5. **`BuildContext`**

   `BuildContext` adalah penanda posisi sebuah widget di dalam widget tree. Lewat context, sebuah widget bisa mencari data atau layanan dari leluhurnya. Inilah yang membuat widget bisa memakai tema, ukuran layar, atau Scaffold tanpa perlu dikirim manual lewat konstruktor.

   Di dalam `build(BuildContext context)`, context dipakai misalnya untuk:
   - `Theme.of(context).colorScheme.primary` untuk warna `AppBar`;
   - `MediaQuery.of(context).size.width` untuk lebar `InfoCard`;
   - `ScaffoldMessenger.of(context).showSnackBar(...)` untuk SnackBar di `ItemCard`.

   Context harus berada *di bawah* widget yang dicari. Contohnya `ScaffoldMessenger.of(context)` hanya bekerja jika context-nya berasal dari widget di dalam `MaterialApp`/`Scaffold`.

6. **Hot reload vs hot restart**

   - **Hot reload** (`r` di terminal) menyuntikkan kode Dart yang diubah ke Dart VM yang sedang berjalan, lalu membangun ulang widget tree. **State aplikasi tetap dipertahankan**, sehingga perubahan UI terlihat dalam hitungan milidetik.
   - **Hot restart** (`R`) memuat ulang seluruh kode dan menjalankan aplikasi dari `main()` lagi. **Semua state hilang**, tapi prosesnya tetap lebih cepat daripada build ulang penuh.

   Hot reload tidak cukup ketika perubahan tidak dijalankan ulang oleh `build`, misalnya:
   - mengubah fungsi `main()` atau isi `initState()`;
   - mengubah nilai awal variabel global/static atau field `final` yang sudah terinisialisasi;
   - mengubah struktur kelas, misalnya StatelessWidget menjadi StatefulWidget, atau mengubah tipe generic/enum.

   Dalam kasus tersebut perlu **hot restart**. **Full restart** (hentikan lalu jalankan ulang `flutter run`) diperlukan untuk perubahan di luar kode Dart, seperti menambah package di `pubspec.yaml`, menambah aset, atau mengubah kode native Android/iOS.

---

## AI Disclosure

- **Tools:** Claude Code (ekstensi VS Code, model Claude Opus).
- **Bagian yang dibantu AI:**
  - Mencocokkan kode Tutorial 08 dengan instruksi di PDF tutorial.
  - Menambahkan atribut `color` pada model `ItemHomepage` dan memakainya di `ItemCard` sesuai petunjuk implementasi di soal.
  - Menambahkan widget test untuk warna tombol.
  - Menambahkan dialog konfirmasi Logout (`AlertDialog`) beserta test-nya.
  - Menyusun draf README ini, termasuk draf jawaban pertanyaan reflektif.
- **Strategi prompting:** saya memberikan PDF tutorial dan soal tugas kepada AI, lalu meminta pengecekan checklist dan implementasi bagian yang belum ada. Hasilnya saya cek dengan `flutter analyze`, `flutter test`, dan menjalankan aplikasi.
- **Log chat AI:** [docs/ai-chat-log.md](docs/ai-chat-log.md) berisi ekspor percakapan lengkap dengan Claude Code (pesan saya, jawaban AI, dan aksi yang dijalankan AI).
- **Yang tetap saya kerjakan sendiri:** setup Flutter SDK dan environment, mengikuti Tutorial 08, serta semua commit dan push ke GitHub.
- **Keterbatasan AI:** AI tidak bisa menjalankan aplikasi di emulator/Chrome untuk saya, jadi tampilan akhir tetap saya periksa sendiri. Jawaban reflektif dari AI saya baca ulang dan sesuaikan dengan pemahaman saya.
