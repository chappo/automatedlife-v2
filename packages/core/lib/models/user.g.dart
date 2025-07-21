// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: (json['id'] as num).toInt(),
  firstName: json['first_name'] as String,
  lastName: json['last_name'] as String,
  email: json['email'] as String,
  preferredName: json['preferred_name'] as String?,
  isAdmin: json['is_admin'] as bool,
  isActive: json['is_active'] as bool,
  createdAt: json['lote_created'] == null
      ? null
      : DateTime.parse(json['lote_created'] as String),
  updatedAt: json['lote_updated'] == null
      ? null
      : DateTime.parse(json['lote_updated'] as String),
  buildings: (json['buildings'] as List<dynamic>?)
      ?.map((e) => Building.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'email': instance.email,
  'preferred_name': instance.preferredName,
  'is_admin': instance.isAdmin,
  'is_active': instance.isActive,
  'lote_created': instance.createdAt?.toIso8601String(),
  'lote_updated': instance.updatedAt?.toIso8601String(),
  'buildings': instance.buildings,
};
