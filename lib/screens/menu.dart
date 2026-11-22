import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/screens/education_form.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:myportofolio_mobile/widgets/project_card.dart';

class MyHomePage extends StatelessWidget {
  MyHomePage({super.key});

  final String npm = "2506623793";
  final String nama = "Muhammad Sabri";
  final String kelas = "PBP C";

  // Setiap tombol membawa warnanya sendiri, jadi ItemCard tidak perlu if-else.
  final List<ItemHomepage> items = [
    ItemHomepage("Lihat Proyek", Icons.folder, Colors.blue),
    ItemHomepage(
      "Tambah Proyek",
      Icons.add_circle,
      Colors.green,
      halamanTujuan: (context) => const ProjectFormPage(),
    ),
    ItemHomepage(
      "Tambah Edukasi",
      Icons.school,
      Colors.deepPurple,
      halamanTujuan: (context) => const EducationFormPage(),
    ),
    ItemHomepage(
      "Logout",
      Icons.logout,
      Colors.red,
      pesanKonfirmasi: "Yakin ingin keluar dari MyPortfolio?",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Scaffold menyediakan struktur visual dasar halaman (AppBar, Body, SnackBar).
    return Scaffold(
      // AppBar menampilkan bar bagian atas halaman aplikasi.
      appBar: AppBar(
        title: const Text(
          'MyPortfolio',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        // Ikon hamburger drawer dibuat putih agar kontras dengan AppBar.
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // Drawer menu navigasi dari sisi kiri layar.
      drawer: const LeftDrawer(),
      // Body halaman utama dengan padding di sekelilingnya.
      // Halaman bisa digulir agar semua kartu terjangkau di layar kecil.
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Baris horizontal untuk menampilkan 3 InfoCard secara sejajar.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Expanded membagi lebar sama rata agar tidak meluap di layar sempit.
                Expanded(child: InfoCard(title: 'NPM', content: npm)),
                Expanded(child: InfoCard(title: 'Name', content: nama)),
                Expanded(child: InfoCard(title: 'Class', content: kelas)),
              ],
            ),

            const SizedBox(height: 16.0),

            // Bagian tengah: pesan sambutan dan kisi tombol menu portofolio.
            Center(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: Text(
                      'Selamat datang di MyPortfolio Mobile!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                  ),

                  // GridView menampilkan kartu tombol dalam tata letak kisi 3 kolom.
                  GridView.count(
                    // Pengguliran ditangani oleh SingleChildScrollView di luar.
                    primary: false,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    crossAxisCount: 3,
                    // shrinkWrap agar ukuran kisi menyesuaikan tinggi konten anak.
                    shrinkWrap: true,
                    children: items.map((ItemHomepage item) {
                      return ItemCard(item);
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  // Kartu informasi yang menampilkan judul (title) dan isi (content).
  final String title;
  final String content;

  const InfoCard({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      // Memberikan efek bayangan kartu elevasi 2 unit.
      elevation: 2.0,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        // Menyusun teks title dan content secara vertikal.
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            // Teks panjang seperti NPM diperkecil agar tetap satu baris.
            FittedBox(fit: BoxFit.scaleDown, child: Text(content)),
          ],
        ),
      ),
    );
  }
}

// Model data satu tombol menu: teks, ikon, dan warna latar kartunya.
class ItemHomepage {
  final String name;
  final IconData icon;
  final Color color;

  // Jika diisi, aksi tombol harus dikonfirmasi lewat dialog berisi pesan ini.
  final String? pesanKonfirmasi;

  // Jika diisi, tombol membuka halaman ini dengan Navigator.push().
  final WidgetBuilder? halamanTujuan;

  ItemHomepage(
    this.name,
    this.icon,
    this.color, {
    this.pesanKonfirmasi,
    this.halamanTujuan,
  });
}
