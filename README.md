# Automated Life Building Manager

A modern Flutter application for comprehensive building management with role-based access, dynamic capabilities, and full accessibility support.

![Flutter](https://img.shields.io/badge/Flutter-3.10+-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)
![Material](https://img.shields.io/badge/Material-3-green.svg)
![License](https://img.shields.io/badge/License-Proprietary-red.svg)

## 🏢 Overview

The Building Manager app provides a unified platform for building administration, resident services, and facility management. Built with a modular architecture, the app adapts to different user roles and building configurations while maintaining accessibility and consistent UX.

## ✨ Key Features

### 🎯 **Role-Based Access Control**
- **Admin Users**: Full building management capabilities
- **Residents**: Building-specific features and services
- **Defect Users**: Specialized interface for maintenance technicians
- **Staff**: Limited access for specific building functions

### 🏗️ **Modular Architecture**
- **UX-Centered Design**: Strict design system enforcement for consistent look and feel
- **Capability Packages**: Dynamically loaded features based on building configuration
- **Building Branding**: Custom themes, colors, and logos per building

### ♿ **Accessibility First**
- **WCAG 2.1 AA Compliant**: Full accessibility compliance
- **Text Scaling**: Support up to 200% text scaling with layout integrity
- **Screen Readers**: Comprehensive VoiceOver and TalkBack support
- **High Contrast**: Automatic high contrast mode support

### 📱 **Cross-Platform**
- **iOS, Android, Web**: Consistent experience across all platforms
- **Responsive Design**: Adaptive layouts for mobile, tablet, and desktop
- **Material Design 3**: Modern, accessible component library

## 🏗️ Architecture

### Package Structure
```
building_manager/
├── packages/
│   ├── design_system/           # 🎨 Central design system (MANDATORY)
│   ├── core/                    # 🔧 Business logic & API client
│   ├── app_shell/               # 🏠 Navigation & role-based UI
│   └── capabilities/            # 📦 Feature packages
│       ├── defects/            # Issue reporting & management
│       ├── messaging/          # Communication system
│       ├── documents/          # Document management
│       ├── calendar_booking/   # Amenity booking system
│       └── intercom/           # VoIP intercom integration
└── apps/
    ├── full_app/               # Complete application
    ├── defects_only/           # Technician-focused app
    └── resident_app/           # Resident-focused app
```

### Core Packages

#### 🎨 **Design System**
- Material 3 components with accessibility enhancements
- Building-specific branding support
- WCAG 2.1 AA compliant color schemes
- Responsive design tokens and utilities

#### 🔧 **Core**
- Laravel Sanctum authentication
- Dio HTTP client with retry logic
- Secure storage with flutter_secure_storage
- Building-specific API endpoints

#### 🏠 **App Shell**
- Role-based navigation shells
- Adaptive UI (bottom nav for mobile, nav rail for tablets)
- Capability-driven navigation
- Building switcher for multi-building users

## 🚀 Getting Started

### Prerequisites
- Flutter 3.10 or higher
- Dart 3.0 or higher
- iOS 12+ / Android API 21+

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/automatedlife/building-manager.git
   cd building-manager
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code (for models)**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the application**
   ```bash
   flutter run
   ```

### Configuration

Update the API endpoint in `lib/main.dart`:
```dart
final apiClient = ApiClient(
  baseUrl: 'https://your-api-domain.com/api/v1',
);
```

## 🔧 Development Status

### ✅ Completed Features

#### **Framework Foundation**
- [x] Modular package architecture with UX-centered design
- [x] Material 3 design system with accessibility support
- [x] Core API client with Laravel Sanctum authentication
- [x] Secure storage and token management
- [x] Role-based navigation system

#### **Authentication Flow**
- [x] Login screen with form validation
- [x] Building selection for multi-building users  
- [x] Splash screen and loading states
- [x] Remember me functionality
- [x] Error handling and user feedback

#### **User Interface**
- [x] Responsive design (mobile, tablet, desktop)
- [x] Building-specific branding and theming
- [x] Accessibility compliance (WCAG 2.1 AA)
- [x] Text scaling up to 200%
- [x] High contrast mode support

#### **Navigation System**
- [x] Adaptive navigation (bottom nav + nav rail)
- [x] Role-based access control
- [x] Capability-driven navigation
- [x] Building switcher for admins

### 🚧 In Development

#### **Capability Packages**
- [ ] **Defects Management**: Issue reporting with photo support
- [ ] **Messaging System**: Real-time communication platform
- [ ] **Document Management**: File sharing and organization
- [ ] **Calendar Booking**: Session-based amenity booking
- [ ] **VoIP Intercom**: Integration with Flexisip/Linphone

#### **Advanced Features**
- [ ] Push notifications with FCM
- [ ] Offline support and data synchronization
- [ ] External app integration support
- [ ] Advanced search and filtering

### 📋 Planned Features

#### **Phase 1: Core Capabilities**
- Session-based amenity booking system
- Defects management with technician workflow
- Basic document management

#### **Phase 2: Communication**
- Real-time messaging with thread support
- Push notification system
- VoIP intercom integration

#### **Phase 3: Advanced Features**
- Advanced search functionality
- Analytics and usage tracking
- White-label app variants

## 👥 User Roles

### 🔑 **Admin Users**
- See only capabilities enabled for current building
- Admin functions handled within capability screens
- Building configuration and user management via frontend UI
- No separate admin navigation - enhanced permissions within screens

### 🏠 **Residents**
- Access to building-specific enabled capabilities
- Profile management and preferences
- Emergency contact information
- Building-specific announcements

### 🔧 **Defect Users (Technicians)**
- Focused interface for defect management
- Work order assignments and updates
- Photo documentation and progress tracking
- Multi-building access for assigned work

## 🎨 Design System

### Components
- Accessible form inputs with validation
- Consistent button styles and interactions
- Card layouts with proper elevation
- Navigation components with semantic labels

### Theming
- Material 3 color schemes with dynamic generation
- Building-specific branding integration
- High contrast mode support
- Custom typography with accessibility scaling

### Accessibility
- Minimum 48dp touch targets
- Semantic labels for screen readers
- Color contrast validation (4.5:1 ratio)
- Keyboard navigation support

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run integration tests
flutter drive --target=test_driver/app.dart
```

## 📝 API Integration

The app integrates with the V1 Capabilities API:

### Authentication
- Laravel Sanctum token-based authentication
- Automatic token refresh
- Secure storage of credentials

### Building Management
- Dynamic capability loading
- Building-specific branding
- User role management

### Key Endpoints
- `POST /auth/login` - User authentication
- `GET /buildings/{id}/capabilities` - Building capabilities
- `GET /buildings/{id}/branding` - Building branding
- `PUT /buildings/{id}/capabilities/{id}` - Toggle capabilities

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines
- Follow the existing code style and architecture
- Use the design system components exclusively
- Ensure accessibility compliance (WCAG 2.1 AA)
- Add tests for new functionality
- Update documentation as needed

## 📄 License

This project is proprietary software owned by Automated Life. All rights reserved.

## 🆘 Support

For support and questions:
- **Email**: support@automatedlife.com.au
- **Website**: https://automatedlife.com.au

---

**Built with ❤️ by Automated Life**
