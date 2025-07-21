import 'package:json_annotation/json_annotation.dart';

part 'user_alias.g.dart';

@JsonSerializable()
class UserAlias {
  final String id;
  final String alias;
  final String type;
  @JsonKey(name: 'is_public')
  final bool isPublic;
  @JsonKey(name: 'is_primary')
  final bool isPrimary;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  const UserAlias({
    required this.id,
    required this.alias,
    required this.type,
    required this.isPublic,
    required this.isPrimary,
    this.createdAt,
    this.updatedAt,
  });

  /// Display name for the alias type
  String get typeDisplayName {
    switch (type) {
      case 'username':
        return 'Username';
      case 'display_name':
        return 'Display Name';
      case 'nickname':
        return 'Nickname';
      default:
        return type.replaceAll('_', ' ').split(' ')
            .map((word) => word.isNotEmpty 
                ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
                : '')
            .join(' ');
    }
  }

  /// Icon for the alias type
  String get typeIcon {
    switch (type) {
      case 'username':
        return 'person';
      case 'display_name':
        return 'badge';
      case 'nickname':
        return 'tag';
      default:
        return 'label';
    }
  }

  factory UserAlias.fromJson(Map<String, dynamic> json) => _$UserAliasFromJson(json);
  Map<String, dynamic> toJson() => _$UserAliasToJson(this);

  UserAlias copyWith({
    String? id,
    String? alias,
    String? type,
    bool? isPublic,
    bool? isPrimary,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserAlias(
      id: id ?? this.id,
      alias: alias ?? this.alias,
      type: type ?? this.type,
      isPublic: isPublic ?? this.isPublic,
      isPrimary: isPrimary ?? this.isPrimary,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserAlias &&
        other.id == id &&
        other.alias == alias &&
        other.type == type &&
        other.isPublic == isPublic &&
        other.isPrimary == isPrimary;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        alias.hashCode ^
        type.hashCode ^
        isPublic.hashCode ^
        isPrimary.hashCode;
  }

  @override
  String toString() {
    return 'UserAlias(id: $id, alias: $alias, type: $type, isPublic: $isPublic, isPrimary: $isPrimary)';
  }
}