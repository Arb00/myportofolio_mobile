import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/screens/menu.dart';

class ItemCard extends StatelessWidget {
  final ItemHomepage item;

  const ItemCard(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      // Warna latar diambil dari model, sehingga tiap tombol punya warna unik.
      color: item.color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        // Aksi ketika kartu ditekan oleh pengguna.
        onTap: () {
          // Menampilkan SnackBar dengan pesan interaktif.
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text("Kamu telah menekan tombol ${item.name}!")),
            );

          // Navigasi ke halaman yang sesuai. push() menumpuk halaman form di atas
          // menu, jadi tombol Back akan kembali ke menu.
          final halamanTujuan = item.halamanTujuan;
          if (halamanTujuan != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: halamanTujuan),
            );
          }

          // Tombol yang berisiko (misalnya Logout) meminta konfirmasi dulu.
          if (item.pesanKonfirmasi != null) {
            _tampilkanKonfirmasi(context);
          }
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          // FittedBox mengecilkan isi kartu jika ruangnya tidak cukup.
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item.icon,
                    color: Colors.white,
                    size: 30.0,
                  ),
                  const Padding(padding: EdgeInsets.all(3)),
                  Text(
                    item.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Dialog konfirmasi: tombol utama memakai warna item, lalu SnackBar
  // memberi tahu hasilnya (dibatalkan atau berhasil).
  Future<void> _tampilkanKonfirmasi(BuildContext context) async {
    final setuju = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(item.icon, color: item.color),
        title: Text(item.name),
        content: Text(item.pesanKonfirmasi!),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text("Batal"),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: item.color),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(item.name),
          ),
        ],
      ),
    );

    // Halaman bisa saja sudah tertutup selama dialog terbuka.
    if (!context.mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            setuju == true ? "${item.name} berhasil." : "${item.name} dibatalkan.",
          ),
        ),
      );
  }
}
