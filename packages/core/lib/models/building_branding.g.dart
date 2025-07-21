// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'building_branding.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BuildingBranding _$BuildingBrandingFromJson(Map<String, dynamic> json) =>
    BuildingBranding(
      primaryColor: json['primary_color'] as String?,
      secondaryColor: json['secondary_color'] as String?,
      logoUrl: json['logo_url'] as String?,
      bannerUrl: json['banner_url'] as String?,
      welcomeMessage: json['welcome_message'] as String?,
      contactEmail: json['contact_email'] as String?,
      contactPhone: json['contact_phone'] as String?,
      websiteUrl: json['website_url'] as String?,
      appName: json['app_name'] as String?,
    );

Map<String, dynamic> _$BuildingBrandingToJson(BuildingBranding instance) =>
    <String, dynamic>{
      'primary_color': instance.primaryColor,
      'secondary_color': instance.secondaryColor,
      'logo_url': instance.logoUrl,
      'banner_url': instance.bannerUrl,
      'welcome_message': instance.welcomeMessage,
      'contact_email': instance.contactEmail,
      'contact_phone': instance.contactPhone,
      'website_url': instance.websiteUrl,
      'app_name': instance.appName,
    };
