// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'capability.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Capability _$CapabilityFromJson(Map<String, dynamic> json) => Capability(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  key: json['reference'] as String,
  description: json['description'] as String?,
  type: json['type'] as String,
  category: json['category'] as String?,
  icon: json['icon'] as Map<String, dynamic>?,
  apps: json['apps'] as Map<String, dynamic>?,
  settings: json['settings'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$CapabilityToJson(Capability instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'reference': instance.key,
      'description': instance.description,
      'type': instance.type,
      'category': instance.category,
      'icon': instance.icon,
      'apps': instance.apps,
      'settings': instance.settings,
    };
