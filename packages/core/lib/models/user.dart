import 'package:json_annotation/json_annotation.dart';
import 'building.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final int id;
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'last_name')
  final String lastName;
  final String email;
  @JsonKey(name: 'preferred_name')
  final String? preferredName;
  @JsonKey(name: 'is_admin')
  final bool isAdmin;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'lote_created')
  final DateTime? createdAt;
  @JsonKey(name: 'lote_updated')
  final DateTime? updatedAt;
  final List<Building>? buildings;

  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.preferredName,
    required this.isAdmin,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
    this.buildings,
  });
  
  /// Get display name (preferred name or first name)
  String get displayName => preferredName?.isNotEmpty == true ? preferredName! : firstName;
  
  /// Get full name
  String get fullName => '$firstName $lastName';

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? email,
    String? preferredName,
    bool? isAdmin,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Building>? buildings,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      preferredName: preferredName ?? this.preferredName,
      isAdmin: isAdmin ?? this.isAdmin,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      buildings: buildings ?? this.buildings,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.email == email &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        firstName.hashCode ^
        lastName.hashCode ^
        email.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }

  @override
  String toString() {
    return 'User(id: $id, firstName: $firstName, lastName: $lastName, email: $email, isAdmin: $isAdmin, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}