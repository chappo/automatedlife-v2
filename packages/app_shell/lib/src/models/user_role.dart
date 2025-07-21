enum UserRole {
  /// System administrator with full access to all buildings and capabilities
  admin('admin', 'Administrator'),
  
  /// Building resident with access to building-specific capabilities
  resident('resident', 'Resident'),
  
  /// User with access only to defects functionality
  defectUser('defect_user', 'Defect User'),
  
  /// Manager with administrative access to specific buildings
  buildingManager('building_manager', 'Building Manager'),
  
  /// Staff member with limited access to specific capabilities
  staff('staff', 'Staff');

  const UserRole(this.key, this.displayName);

  final String key;
  final String displayName;

  /// Whether this role has administrative privileges
  bool get isAdmin => this == UserRole.admin;

  /// Whether this role has building management privileges
  bool get canManageBuildings => 
      this == UserRole.admin || this == UserRole.buildingManager;

  /// Whether this role can access multiple buildings
  bool get canAccessMultipleBuildings => 
      this == UserRole.admin || this == UserRole.buildingManager;

  /// Whether this role is restricted to defects only
  bool get isDefectOnly => this == UserRole.defectUser;

  /// Get user role from string key
  static UserRole? fromKey(String key) {
    for (final role in UserRole.values) {
      if (role.key == key) return role;
    }
    return null;
  }

  /// Get capabilities this role can access by default
  List<String> get defaultCapabilities {
    switch (this) {
      case UserRole.admin:
        return [
          'defects',
          'documents', 
          'messaging',
          'intercom',
          'calendar_booking'
        ]; // Admin has access to all building capability types, but still subject to building-specific filtering
      case UserRole.buildingManager:
        return [
          'defects',
          'documents',
          'messaging',
          'intercom',
          'calendar_booking'
        ];
      case UserRole.resident:
        return [
          'defects',
          'documents',
          'messaging',
          'intercom',
          'calendar_booking'
        ];
      case UserRole.defectUser:
        return ['defects'];
      case UserRole.staff:
        return [
          'defects',
          'documents',
          'messaging'
        ];
    }
  }

  /// Check if this role can access a specific capability
  bool canAccessCapability(String capability) {
    final capabilities = defaultCapabilities;
    return capabilities.contains(capability);
  }
}