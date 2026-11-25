import 'package:json_annotation/json_annotation.dart';

part 'project.g.dart';

/// Satu proyek portofolio, sesuai serializer DRF di `/api/v1/projects/`.
/// `fieldRename.snake` memetakan `techStack` <-> `tech_stack`, dan seterusnya.
@JsonSerializable(fieldRename: FieldRename.snake)
class Project {
  // id dibuat oleh server, jadi tidak ikut dikirim saat POST.
  @JsonKey(includeToJson: false)
  final int? id;
  final String title;
  final String description;
  final String techStack;
  final String projectUrl;
  @JsonKey(defaultValue: '')
  final String projectImageUrl;

  const Project({
    this.id,
    required this.title,
    required this.description,
    required this.techStack,
    required this.projectUrl,
    this.projectImageUrl = '',
  });

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectToJson(this);
}
