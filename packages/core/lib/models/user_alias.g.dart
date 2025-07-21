// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_alias.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserAlias _$UserAliasFromJson(Map<String, dynamic> json) => UserAlias(
  id: json['id'] as String,
  alias: json['alias'] as String,
  type: json['type'] as String,
  isPublic: json['is_public'] as bool,
  isPrimary: json['is_primary'] as bool,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$UserAliasToJson(UserAlias instance) => <String, dynamic>{
  'id': instance.id,
  'alias': instance.alias,
  'type': instance.type,
  'is_public': instance.isPublic,
  'is_primary': instance.isPrimary,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};
