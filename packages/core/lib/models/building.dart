import 'package:json_annotation/json_annotation.dart';
import 'building_branding.dart';
import 'capability.dart';

part 'building.g.dart';

@JsonSerializable()
class Building {
  final int id;
  final String name;
  final String? description;
  final String? address;
  final String? city;
  final String? state;
  @JsonKey(name: 'zip_code')
  final String? zipCode;
  final String? country;
  @JsonKey(name: 'time_zone')
  final String? timeZone;
  @JsonKey(name: 'is_active')
  final bool isActive;
  final BuildingBranding? branding;
  final List<Capability>? capabilities;

  const Building({
    required this.id,
    required this.name,
    this.description,
    this.address,
    this.city,
    this.state,
    this.zipCode,
    this.country,
    this.timeZone,
    required this.isActive,
    this.branding,
    this.capabilities,
  });

  factory Building.fromJson(Map<String, dynamic> json) =>
      _$BuildingFromJson(json);
  Map<String, dynamic> toJson() => _$BuildingToJson(this);

  Building copyWith({
    int? id,
    String? name,
    String? description,
    String? address,
    String? city,
    String? state,
    String? zipCode,
    String? country,
    String? timeZone,
    bool? isActive,
    BuildingBranding? branding,
    List<Capability>? capabilities,
  }) {
    return Building(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      country: country ?? this.country,
      timeZone: timeZone ?? this.timeZone,
      isActive: isActive ?? this.isActive,
      branding: branding ?? this.branding,
      capabilities: capabilities ?? this.capabilities,
    );
  }

  /// Get the API base URL for this building
  String getApiBaseUrl() {
    // For development, use local server
    return 'http://10.10.0.203:8000/api/v1';
    
    // Production logic (commented out for development):
    // if (apiSubdomain != null && apiSubdomain!.isNotEmpty) {
    //   return 'https://$apiSubdomain.automatedlife.io/api/v1';
    // }
    // return 'https://api.automatedlife.io/api/v1';
  }

  /// Check if a specific capability is enabled
  /// Note: This method is deprecated. Use BuildingCapabilitiesResponse instead.
  bool hasCapability(String capabilityKey) {
    if (capabilities == null) return false;
    return capabilities!.any(
      (capability) => capability.key == capabilityKey,
    );
  }

  /// Get capability configuration data
  /// Note: This method is deprecated. Use BuildingCapabilitiesResponse instead.
  Map<String, dynamic>? getCapabilityConfig(String capabilityKey) {
    if (capabilities == null) return null;
    final capability = capabilities!.firstWhere(
      (cap) => cap.key == capabilityKey,
      orElse: () => throw StateError('Capability $capabilityKey not found'),
    );
    return capability.settings;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Building &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.address == address &&
        other.city == city &&
        other.state == state &&
        other.zipCode == zipCode &&
        other.country == country &&
        other.timeZone == timeZone &&
        other.isActive == isActive &&
        other.branding == branding;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        description.hashCode ^
        address.hashCode ^
        city.hashCode ^
        state.hashCode ^
        zipCode.hashCode ^
        country.hashCode ^
        timeZone.hashCode ^
        isActive.hashCode ^
        branding.hashCode;
  }

  @override
  String toString() {
    return 'Building(id: $id, name: $name, description: $description, address: $address, city: $city, state: $state, zipCode: $zipCode, country: $country, timeZone: $timeZone, isActive: $isActive, branding: $branding)';
  }
}