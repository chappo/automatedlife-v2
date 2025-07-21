import 'package:json_annotation/json_annotation.dart';

part 'building_branding.g.dart';

@JsonSerializable()
class BuildingBranding {
  @JsonKey(name: 'primary_color')
  final String? primaryColor;
  @JsonKey(name: 'secondary_color')
  final String? secondaryColor;
  @JsonKey(name: 'logo_url')
  final String? logoUrl;
  @JsonKey(name: 'banner_url')
  final String? bannerUrl;
  @JsonKey(name: 'welcome_message')
  final String? welcomeMessage;
  @JsonKey(name: 'contact_email')
  final String? contactEmail;
  @JsonKey(name: 'contact_phone')
  final String? contactPhone;
  @JsonKey(name: 'website_url')
  final String? websiteUrl;
  @JsonKey(name: 'app_name')
  final String? appName;

  const BuildingBranding({
    this.primaryColor,
    this.secondaryColor,
    this.logoUrl,
    this.bannerUrl,
    this.welcomeMessage,
    this.contactEmail,
    this.contactPhone,
    this.websiteUrl,
    this.appName,
  });

  factory BuildingBranding.fromJson(Map<String, dynamic> json) =>
      _$BuildingBrandingFromJson(json);
  Map<String, dynamic> toJson() => _$BuildingBrandingToJson(this);

  BuildingBranding copyWith({
    String? primaryColor,
    String? secondaryColor,
    String? logoUrl,
    String? bannerUrl,
    String? welcomeMessage,
    String? contactEmail,
    String? contactPhone,
    String? websiteUrl,
    String? appName,
  }) {
    return BuildingBranding(
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      logoUrl: logoUrl ?? this.logoUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      welcomeMessage: welcomeMessage ?? this.welcomeMessage,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      appName: appName ?? this.appName,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BuildingBranding &&
        other.primaryColor == primaryColor &&
        other.secondaryColor == secondaryColor &&
        other.logoUrl == logoUrl &&
        other.bannerUrl == bannerUrl &&
        other.welcomeMessage == welcomeMessage &&
        other.contactEmail == contactEmail &&
        other.contactPhone == contactPhone &&
        other.websiteUrl == websiteUrl &&
        other.appName == appName;
  }

  @override
  int get hashCode {
    return primaryColor.hashCode ^
        secondaryColor.hashCode ^
        logoUrl.hashCode ^
        bannerUrl.hashCode ^
        welcomeMessage.hashCode ^
        contactEmail.hashCode ^
        contactPhone.hashCode ^
        websiteUrl.hashCode ^
        appName.hashCode;
  }

  @override
  String toString() {
    return 'BuildingBranding(primaryColor: $primaryColor, secondaryColor: $secondaryColor, logoUrl: $logoUrl, bannerUrl: $bannerUrl, welcomeMessage: $welcomeMessage, contactEmail: $contactEmail, contactPhone: $contactPhone, websiteUrl: $websiteUrl, appName: $appName)';
  }
}