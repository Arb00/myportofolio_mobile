import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/utils/form_validators.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

/// Formulir untuk menambahkan riwayat edukasi ke portofolio.
class EducationFormPage extends StatefulWidget {
  const EducationFormPage({super.key});

  @override
  State<EducationFormPage> createState() => _EducationFormPageState();
}

class _EducationFormPageState extends State<EducationFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _institusiController = TextEditingController();
  final _jurusanController = TextEditingController();
  final _ipkController = TextEditingController();
  final _mulaiController = TextEditingController();
  final _selesaiController = TextEditingController();

  static const List<String> _daftarJenjang = [
    'SMA/SMK',
    'D3',
    'S1',
    'S2',
    'S3',
  ];

  String _jenjang = 'S1';
  DateTime? _tanggalMulai;
  DateTime? _tanggalSelesai;
  bool _masihBerjalan = false;

  // Setelah Simpan pertama gagal, error langsung hilang saat kolom diperbaiki.
  AutovalidateMode _modeValidasi = AutovalidateMode.disabled;

  @override
  void dispose() {
    _institusiController.dispose();
    _jurusanController.dispose();
    _ipkController.dispose();
    _mulaiController.dispose();
    _selesaiController.dispose();
    super.dispose();
  }

  InputDecoration _dekorasi(String label, {String? hint, Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
    );
  }

  Future<void> _pilihTanggalMulai() async {
    final hariIni = DateTime.now();
    final terpilih = await showDatePicker(
      context: context,
      initialDate: _tanggalMulai ?? hariIni,
      firstDate: DateTime(1950),
      lastDate: hariIni,
    );
    if (terpilih == null) return;

    setState(() {
      _tanggalMulai = terpilih;
      _mulaiController.text = FormValidators.formatTanggal(terpilih);
    });
  }

  Future<void> _pilihTanggalSelesai() async {
    final hariIni = DateTime.now();
    final batasAwal = _tanggalMulai ?? DateTime(1950);
    // Tanggal selesai boleh di masa depan, misalnya perkiraan kelulusan.
    final batasAkhir = DateTime(hariIni.year + 10, 12, 31);

    var awal = _tanggalSelesai ?? hariIni;
    if (awal.isBefore(batasAwal)) awal = batasAwal;

    final terpilih = await showDatePicker(
      context: context,
      initialDate: awal,
      firstDate: batasAwal,
      lastDate: batasAkhir,
    );
    if (terpilih == null) return;

    setState(() {
      _tanggalSelesai = terpilih;
      _selesaiController.text = FormValidators.formatTanggal(terpilih);
    });
  }

  void _simpan() {
    if (!_formKey.currentState!.validate()) {
      setState(() => _modeValidasi = AutovalidateMode.onUserInteraction);
      return;
    }

    final ipk = _ipkController.text.trim().replaceAll(',', '.');
    final selesai = _masihBerjalan ? 'Masih berjalan' : _selesaiController.text;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ringkasan Edukasi'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Institusi: ${_institusiController.text.trim()}'),
              Text('Jenjang: $_jenjang'),
              Text('Jurusan: ${_jurusanController.text.trim()}'),
              Text('Tanggal Mulai: ${_mulaiController.text}'),
              Text('Tanggal Selesai: $selesai'),
              Text('IPK: ${ipk.isEmpty ? '-' : ipk}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final warnaUtama = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Education Form',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: warnaUtama,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: _modeValidasi,
          // Form bisa digulir agar tombol Simpan tetap terjangkau saat
          // layar sempit atau papan ketik sedang tampil.
          child: SingleChildScrollView(
            // Ruang bawah ekstra agar Simpan bisa digulir ke atas SnackBar.
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 88.0),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16.0,
              children: [
                TextFormField(
                  controller: _institusiController,
                  maxLength: 100,
                  textInputAction: TextInputAction.next,
                  decoration: _dekorasi(
                    'Nama Institusi',
                    hint: 'Contoh: Universitas Indonesia',
                  ),
                  validator: (value) =>
                      FormValidators.wajib(value, 'Nama institusi'),
                ),
                DropdownButtonFormField<String>(
                  initialValue: _jenjang,
                  decoration: _dekorasi('Jenjang'),
                  items: _daftarJenjang
                      .map(
                        (jenjang) => DropdownMenuItem(
                          value: jenjang,
                          child: Text(jenjang),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _jenjang = value!),
                ),
                TextFormField(
                  controller: _jurusanController,
                  maxLength: 100,
                  textInputAction: TextInputAction.next,
                  decoration: _dekorasi(
                    'Jurusan',
                    hint: 'Contoh: Ilmu Komputer',
                  ),
                  validator: (value) => FormValidators.wajib(value, 'Jurusan'),
                ),
                TextFormField(
                  controller: _mulaiController,
                  readOnly: true,
                  onTap: _pilihTanggalMulai,
                  decoration: _dekorasi(
                    'Tanggal Mulai',
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                  validator: (_) => _tanggalMulai == null
                      ? 'Tanggal mulai tidak boleh kosong!'
                      : null,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Masih berjalan'),
                  value: _masihBerjalan,
                  onChanged: (value) => setState(() => _masihBerjalan = value),
                ),
                // Tanggal selesai hanya relevan jika edukasi sudah berakhir.
                if (!_masihBerjalan)
                  TextFormField(
                    controller: _selesaiController,
                    readOnly: true,
                    onTap: _pilihTanggalSelesai,
                    decoration: _dekorasi(
                      'Tanggal Selesai',
                      suffixIcon: const Icon(Icons.event_available),
                    ),
                    validator: (_) => FormValidators.tanggalSelesai(
                      _tanggalMulai,
                      _tanggalSelesai,
                    ),
                  ),
                TextFormField(
                  controller: _ipkController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.done,
                  decoration: _dekorasi('IPK (opsional)', hint: 'Contoh: 3.75'),
                  validator: FormValidators.ipk,
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: warnaUtama,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _simpan,
                  icon: const Icon(Icons.save),
                  label: const Text('Simpan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
