import 'package:json_annotation/json_annotation.dart';

part 'capability.g.dart';

@JsonSerializable()
class Capability {
  final int id;
  final String name;
  final String key;
  final String? description;
  @JsonKey(name: 'is_enabled')
  final bool isEnabled;
  @JsonKey(name: 'config_data')
  final Map<String, dynamic>? configData;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const Capability({
    required this.id,
    required this.name,
    required this.key,
    this.description,
    required this.isEnabled,
    this.configData,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Capability.fromJson(Map<String, dynamic> json) =>
      _$CapabilityFromJson(json);
  Map<String, dynamic> toJson() => _$CapabilityToJson(this);

  Capability copyWith({
    int? id,
    String? name,
    String? key,
    String? description,
    bool? isEnabled,
    Map<String, dynamic>? configData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Capability(
      id: id ?? this.id,
      name: name ?? this.name,
      key: key ?? this.key,
      description: description ?? this.description,
      isEnabled: isEnabled ?? this.isEnabled,
      configData: configData ?? this.configData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
        other.isEnabled == isEnabled &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        key.hashCode ^
        description.hashCode ^
        isEnabled.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }

  @override
  String toString() {
    return 'Capability(id: $id, name: $name, key: $key, description: $description, isEnabled: $isEnabled, configData: $configData, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}