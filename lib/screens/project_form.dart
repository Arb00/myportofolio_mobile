import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/utils/form_validators.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

class ProjectFormPage extends StatefulWidget {
  const ProjectFormPage({super.key});

  @override
  State<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  // Kunci untuk mengakses state form: validasi dan reset.
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _techStackController = TextEditingController();
  final _projectUrlController = TextEditingController();
  final _imageUrlController = TextEditingController();

  bool _submitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _techStackController.dispose();
    _projectUrlController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  InputDecoration _dekorasi(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
    );
  }

  void _pesan(String teks) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(teks)));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!await ensureLoggedIn(context)) return;
    if (!mounted) return;

    final api = context.read<ApiClient>();
    final auth = context.read<AuthState>();
    final project = Project(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      techStack: _techStackController.text.trim(),
      projectUrl: _projectUrlController.text.trim(),
      projectImageUrl: _imageUrlController.text.trim(),
    );

    setState(() => _submitting = true);
    try {
      final dibuat = await api.createProject(project, token: auth.token!);
      if (!mounted) return;
      // Tidak di-await, supaya tombol Save berhenti loading saat dialog tampil.
      _tampilkanBerhasil(dibuat);
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.statusCode == 401) {
        // Token sudah tidak berlaku di server: logout lalu minta login ulang.
        await auth.logout();
        if (!mounted) return;
        _pesan('Sesi login berakhir, silakan login lagi.');
        await ensureLoggedIn(context);
      } else {
        _pesan('Gagal menyimpan proyek (HTTP ${e.statusCode}).');
      }
    } catch (_) {
      if (!mounted) return;
      _pesan('Tidak bisa terhubung ke server.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _tampilkanBerhasil(Project project) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Proyek berhasil ditambahkan!'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nama Proyek: ${project.title}'),
              Text('Deskripsi: ${project.description}'),
              Text('Teknologi: ${project.techStack}'),
              Text('Tautan: ${project.projectUrl}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.pop(dialogContext);
              for (final controller in [
                _titleController,
                _descriptionController,
                _techStackController,
                _projectUrlController,
                _imageUrlController,
              ]) {
                controller.clear();
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Add Project Form')),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        // SingleChildScrollView agar form tetap bisa digulir di layar kecil.
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: _dekorasi('Nama Proyek'),
                validator: (value) =>
                    FormValidators.wajib(value, 'Nama proyek'),
              ),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: _dekorasi('Deskripsi Proyek'),
                validator: (value) => FormValidators.wajib(
                  value,
                  'Deskripsi proyek',
                  maxLength: 2000,
                ),
              ),
              TextFormField(
                controller: _techStackController,
                decoration: _dekorasi(
                  'Teknologi yang Digunakan',
                  hint: 'Contoh: Flutter, Django, Figma',
                ),
                validator: (value) => FormValidators.wajib(value, 'Teknologi'),
              ),
              TextFormField(
                controller: _projectUrlController,
                keyboardType: TextInputType.url,
                decoration: _dekorasi(
                  'Tautan Proyek',
                  hint: 'https://github.com/...',
                ),
                validator: (value) =>
                    FormValidators.url(value, 'Tautan proyek'),
              ),
              TextFormField(
                controller: _imageUrlController,
                keyboardType: TextInputType.url,
                decoration: _dekorasi('URL Gambar Proyek (opsional)'),
                validator: (value) =>
                    FormValidators.url(value, 'URL gambar', wajibDiisi: false),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
