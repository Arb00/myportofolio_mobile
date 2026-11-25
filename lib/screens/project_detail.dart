import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/models/project.dart';

class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({super.key, required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(project.title),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (project.projectImageUrl.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                project.projectImageUrl,
                fit: BoxFit.cover,
                semanticLabel: 'Gambar proyek ${project.title}',
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image, size: 48),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text(project.title, style: textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(project.techStack, style: textTheme.labelLarge),
          const SizedBox(height: 16),
          Text(project.description),
          const SizedBox(height: 16),
          SelectableText(project.projectUrl),
        ],
      ),
    );
  }
}
