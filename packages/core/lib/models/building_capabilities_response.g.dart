// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'building_capabilities_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BuildingCapabilitiesResponse _$BuildingCapabilitiesResponseFromJson(
  Map<String, dynamic> json,
) => BuildingCapabilitiesResponse(
  enabled: (json['enabled'] as List<dynamic>)
      .map((e) => EnabledCapability.fromJson(e as Map<String, dynamic>))
      .toList(),
  available: (json['available'] as List<dynamic>)
      .map((e) => AvailableCapability.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$BuildingCapabilitiesResponseToJson(
  BuildingCapabilitiesResponse instance,
) => <String, dynamic>{
  'enabled': instance.enabled,
  'available': instance.available,
};

EnabledCapability _$EnabledCapabilityFromJson(Map<String, dynamic> json) =>
    EnabledCapability(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      key: json['reference'] as String,
      description: json['description'] as String?,
      type: json['type'] as String,
      category: json['category'] as String?,
      icon: json['icon'] as Map<String, dynamic>?,
      apps: json['apps'] as Map<String, dynamic>?,
      settings: json['settings'] as Map<String, dynamic>?,
      sortOrder: (json['sortOrder'] as num).toInt(),
      linkId: (json['linkId'] as num?)?.toInt(),
      data: _dataFromJson(json['data']),
    );

Map<String, dynamic> _$EnabledCapabilityToJson(EnabledCapability instance) =>
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
      'sortOrder': instance.sortOrder,
      'linkId': instance.linkId,
      'data': instance.data,
    };

AvailableCapability _$AvailableCapabilityFromJson(Map<String, dynamic> json) =>
    AvailableCapability(
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

Map<String, dynamic> _$AvailableCapabilityToJson(
  AvailableCapability instance,
) => <String, dynamic>{
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
