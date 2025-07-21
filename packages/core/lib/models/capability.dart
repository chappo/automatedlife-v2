import 'package:json_annotation/json_annotation.dart';

part 'capability.g.dart';

@JsonSerializable()
class Capability {
  final int id;
  final String name;
  @JsonKey(name: 'reference')
  final String key;
  final String? description;
  final String type;
  final String? category;
  final Map<String, dynamic>? icon;
  final Map<String, dynamic>? apps;
  final Map<String, dynamic>? settings;

  const Capability({
    required this.id,
    required this.name,
    required this.key,
    this.description,
    required this.type,
    this.category,
    this.icon,
    this.apps,
    this.settings,
  });

  factory Capability.fromJson(Map<String, dynamic> json) =>
      _$CapabilityFromJson(json);
  Map<String, dynamic> toJson() => _$CapabilityToJson(this);

  Capability copyWith({
    int? id,
    String? name,
    String? key,
    String? description,
    String? type,
    String? category,
    Map<String, dynamic>? icon,
    Map<String, dynamic>? apps,
    Map<String, dynamic>? settings,
  }) {
    return Capability(
      id: id ?? this.id,
      name: name ?? this.name,
      key: key ?? this.key,
      description: description ?? this.description,
      type: type ?? this.type,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      apps: apps ?? this.apps,
      settings: settings ?? this.settings,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Capability &&
        other.id == id &&
        other.name == name &&
        other.key == key &&
        other.description == description &&
        other.type == type &&
        other.category == category;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        key.hashCode ^
        description.hashCode ^
        type.hashCode ^
        category.hashCode;
  }

  @override
  String toString() {
    return 'Capability(id: $id, name: $name, key: $key, description: $description, type: $type, category: $category, icon: $icon, apps: $apps, settings: $settings)';
  }
}