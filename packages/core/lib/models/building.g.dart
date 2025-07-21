// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'building.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Building _$BuildingFromJson(Map<String, dynamic> json) => Building(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  description: json['description'] as String?,
  address: json['address'] as String?,
  city: json['city'] as String?,
  state: json['state'] as String?,
  zipCode: json['zip_code'] as String?,
  country: json['country'] as String?,
  timeZone: json['time_zone'] as String?,
  isActive: json['is_active'] as bool,
  branding: json['branding'] == null
      ? null
      : BuildingBranding.fromJson(json['branding'] as Map<String, dynamic>),
  capabilities: (json['capabilities'] as List<dynamic>?)
      ?.map((e) => Capability.fromJson(e as Map<String, dynamic>))
      .toList(),
  apiSubdomain: json['api_subdomain'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$BuildingToJson(Building instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'address': instance.address,
  'city': instance.city,
  'state': instance.state,
  'zip_code': instance.zipCode,
  'country': instance.country,
  'time_zone': instance.timeZone,
  'is_active': instance.isActive,
  'branding': instance.branding,
  'capabilities': instance.capabilities,
  'api_subdomain': instance.apiSubdomain,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};
