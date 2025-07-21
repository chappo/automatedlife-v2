// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'capability.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Capability _$CapabilityFromJson(Map<String, dynamic> json) => Capability(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  key: json['key'] as String,
  description: json['description'] as String?,
  isEnabled: json['is_enabled'] as bool,
  configData: json['config_data'] as Map<String, dynamic>?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$CapabilityToJson(Capability instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'key': instance.key,
      'description': instance.description,
      'is_enabled': instance.isEnabled,
      'config_data': instance.configData,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
