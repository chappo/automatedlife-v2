import 'package:json_annotation/json_annotation.dart';
import 'capability.dart';

part 'building_capabilities_response.g.dart';

/// Helper function to handle data field that can be either Map or empty List
Map<String, dynamic>? _dataFromJson(dynamic json) {
  if (json == null) return null;
  if (json is Map<String, dynamic>) return json;
  if (json is List && json.isEmpty) return null;
  return null;
}

/// Response from /api/v1/buildings/{building_id}/capabilities
/// Contains everything needed to render capability tiles for a building
@JsonSerializable()
class BuildingCapabilitiesResponse {
  /// Capabilities currently enabled for this building
  /// Includes dynamic data, sort order, and building-specific configuration
  final List<EnabledCapability> enabled;
  
  /// Capabilities that can be enabled but aren't currently active
  final List<AvailableCapability> available;

  const BuildingCapabilitiesResponse({
    required this.enabled,
    required this.available,
  });

  factory BuildingCapabilitiesResponse.fromJson(Map<String, dynamic> json) =>
      _$BuildingCapabilitiesResponseFromJson(json);
  Map<String, dynamic> toJson() => _$BuildingCapabilitiesResponseToJson(this);

  /// Get all capabilities (enabled + available) sorted by sort order
  List<CapabilityTile> getAllCapabilitiesSorted() {
    final allCapabilities = <CapabilityTile>[
      ...enabled.map((e) => CapabilityTile.fromEnabled(e)),
      ...available.map((a) => CapabilityTile.fromAvailable(a)),
    ];
    
    allCapabilities.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return allCapabilities;
  }

  /// Get only enabled capabilities sorted by sort order
  List<CapabilityTile> getEnabledCapabilitiesSorted() {
    final tiles = enabled.map((e) => CapabilityTile.fromEnabled(e)).toList();
    tiles.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return tiles;
  }
}

/// Capability that is currently enabled for the building
@JsonSerializable()
class EnabledCapability extends Capability {
  /// Sort order for UI display
  @JsonKey(name: 'sortOrder')
  final int sortOrder;
  
  /// Building-specific capability link ID
  @JsonKey(name: 'linkId')
  final int? linkId;
  
  /// Dynamic data for badges/counts (e.g., messagesCount, openCount)
  @JsonKey(fromJson: _dataFromJson)
  final Map<String, dynamic>? data;

  const EnabledCapability({
    required super.id,
    required super.name,
    required super.key,
    super.description,
    required super.type,
    super.category,
    super.icon,
    super.apps,
    super.settings,
    required this.sortOrder,
    this.linkId,
    this.data,
  });

  factory EnabledCapability.fromJson(Map<String, dynamic> json) =>
      _$EnabledCapabilityFromJson(json);
  
  @override
  Map<String, dynamic> toJson() => _$EnabledCapabilityToJson(this);
}

/// Capability that is available but not currently enabled
@JsonSerializable()
class AvailableCapability extends Capability {
  const AvailableCapability({
    required super.id,
    required super.name,
    required super.key,
    super.description,
    required super.type,
    super.category,
    super.icon,
    super.apps,
    super.settings,
  });

  factory AvailableCapability.fromJson(Map<String, dynamic> json) =>
      _$AvailableCapabilityFromJson(json);
  
  @override
  Map<String, dynamic> toJson() => _$AvailableCapabilityToJson(this);
}

/// Unified capability tile for UI rendering
class CapabilityTile {
  final Capability capability;
  final bool isEnabled;
  final int sortOrder;
  final int? linkId;
  final Map<String, dynamic>? data;

  const CapabilityTile({
    required this.capability,
    required this.isEnabled,
    required this.sortOrder,
    this.linkId,
    this.data,
  });

  factory CapabilityTile.fromEnabled(EnabledCapability enabled) {
    return CapabilityTile(
      capability: enabled,
      isEnabled: true,
      sortOrder: enabled.sortOrder,
      linkId: enabled.linkId,
      data: enabled.data,
    );
  }

  factory CapabilityTile.fromAvailable(AvailableCapability available) {
    return CapabilityTile(
      capability: available,
      isEnabled: false,
      sortOrder: 999, // Available capabilities go at the end
      linkId: null,
      data: null,
    );
  }

  /// Get badge count from dynamic data
  int? getBadgeCount(String key) {
    return data?[key] as int?;
  }

  /// Check if this is an external app capability
  bool get isExternalApp => capability.type == 'external_app';

  /// Get the app info for external capabilities
  Map<String, dynamic>? get appInfo => capability.apps;
}