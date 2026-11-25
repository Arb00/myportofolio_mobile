import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/screens/project_detail.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:provider/provider.dart';

/// Daftar proyek dari Django. Bisa dilihat tanpa login.
class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  // Dibuat di initState, bukan di build(), supaya request tidak diulang
  // setiap kali widget di-rebuild.
  late Future<List<Project>> _projects;

  @override
  void initState() {
    super.initState();
    _projects = context.read<ApiClient>().getProjects();
  }

  Future<void> _refresh() async {
    final future = context.read<ApiClient>().getProjects();
    setState(() {
      _projects = future;
    });
    try {
      await future;
    } catch (_) {
      // Error sudah ditampilkan oleh FutureBuilder.
    }
  }

  // ListView agar RefreshIndicator tetap bisa ditarik walau isinya sedikit.
  Widget _pesan(List<Widget> children) => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: const EdgeInsets.all(32),
    children: children,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Proyek'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Project>>(
          future: _projects,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return _pesan([
                const Icon(Icons.cloud_off, size: 48),
                const SizedBox(height: 8),
                const Text('Gagal memuat proyek.', textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Center(
                  child: FilledButton(
                    onPressed: _refresh,
                    child: const Text('Retry'),
                  ),
                ),
              ]);
            }
            final projects = snapshot.data!;
            if (projects.isEmpty) {
              return _pesan([
                const Text('No projects found.', textAlign: TextAlign.center),
              ]);
            }
            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(8),
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final project = projects[index];
                return Card(
                  child: ListTile(
                    title: Text(project.title),
                    subtitle: Text(
                      '${project.techStack}\n${project.description}',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProjectDetailScreen(project: project),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
