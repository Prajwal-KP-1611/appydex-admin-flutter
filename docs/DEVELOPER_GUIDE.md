# AppyDex Admin Panel - Developer Quick Start

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.9.2 or higher
- Dart SDK 3.9.2 or higher
- VS Code or Android Studio
- Backend API running (default: https://api.appydex.co)

### Installation

1. **Clone the repository** (if not already done)
   ```bash
   cd /home/devin/Desktop/APPYDEX/appydex-admin
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   # For web (recommended for admin panel)
   flutter run -d chrome
   
   # For desktop (Linux)
   flutter run -d linux
   
   # For desktop (macOS)
   flutter run -d macos
   
   # For desktop (Windows)
   flutter run -d windows
   ```

### Default Login Credentials

```
Email: root@appydex.com
Password: Admin@123
Role: super_admin
```

---

## 🏗️ Architecture Overview

### State Management
- **Provider:** Riverpod
- **Authentication:** `adminSessionProvider`
- **API Client:** `apiClientProvider`

### Key Components

#### Authentication Flow
```dart
// Login
await ref.read(adminSessionProvider.notifier).login(
  email: 'root@appydex.com',
  password: 'Admin@123',
);

// Check if authenticated
final isAuth = ref.watch(isAuthenticatedProvider);

// Get current role
final role = ref.watch(currentAdminRoleProvider);

// Logout
await ref.read(adminSessionProvider.notifier).logout();
```

#### API Calls
```dart
// Get API client
final apiClient = ref.read(apiClientProvider);

// Make admin requests
final response = await apiClient.requestAdmin(
  '/admin/vendors',
  method: 'GET',
  queryParameters: {'status': 'pending'},
);

// Handle response
final data = response.data;
```

#### Using AdminLayout
```dart
import 'package:appydex_admin/features/shared/admin_layout.dart';
import 'package:appydex_admin/routes.dart';

class MyAdminScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AdminLayout(
      currentRoute: AppRoute.myRoute,
      child: YourContentWidget(),
    );
  }
}
```

---

## 🎨 Theme & Styling

### AppyDex Colors

```dart
import 'package:appydex_admin/core/theme.dart';

// Primary colors
AppTheme.primaryDeepBlue    // #1E3A8A - Main brand color
AppTheme.secondarySkyBlue   // #38BDF8 - Secondary actions
AppTheme.accentEmerald      // #10B981 - Success states

// Semantic colors
AppTheme.dangerRed          // #DC2626 - Errors, delete
AppTheme.warningAmber       // #F59E0B - Warnings
AppTheme.successGreen       // #22C55E - Success messages

// Neutrals
AppTheme.backgroundNeutralGray  // #F9FAFB - Page background
AppTheme.surface            // #FFFFFF - Cards, surfaces
AppTheme.textDarkSlate      // #111827 - Text color
AppTheme.borderGray         // #D1D5DB - Borders, dividers
```

### Using Theme in Widgets

```dart
final theme = Theme.of(context);
final textTheme = theme.textTheme;

// Typography
Text('Heading', style: textTheme.displayLarge);
Text('Subheading', style: textTheme.headlineMedium);
Text('Body', style: textTheme.bodyMedium);
Text('Label', style: textTheme.labelMedium);

// Colors
Container(
  color: AppTheme.primaryDeepBlue,
  child: Text(
    'White text',
    style: textTheme.bodyMedium?.copyWith(
      color: AppTheme.surface,
    ),
  ),
);
```

---

## 🔐 Role-Based Access Control (RBAC)

### Available Roles

```dart
enum AdminRole {
  superAdmin,      // Full platform access
  vendorAdmin,     // Vendor management
  accountsAdmin,   // Finance & subscriptions
  supportAdmin,    // User support
  reviewAdmin,     // Review moderation
}
```

### Checking Permissions

```dart
import 'package:appydex_admin/models/admin_role.dart';

// Get current session
final session = ref.watch(adminSessionProvider);
final role = session?.activeRole;

// Check permissions
if (role?.hasPermission('vendors', 'create') ?? false) {
  // Show create vendor button
}

// Alternative: use specific methods
if (role?.canCreate('vendors') ?? false) {
  // Can create vendors
}

if (role?.canDelete('users') ?? false) {
  // Can delete users
}
```

### Conditionally Show UI

```dart
// In navigation
if (role?.hasPermission('admins', 'read') ?? false)
  _buildNavItem(
    icon: Icons.shield_outlined,
    label: 'Admin Users',
    route: AppRoute.admins,
  ),

// In buttons
if (role?.canCreate('vendors') ?? false)
  ElevatedButton(
    onPressed: () => _createVendor(),
    child: Text('Add Vendor'),
  ),
```

---

## 📡 API Integration

### Configuration

```dart
// Default API base URL
const kDefaultApiBaseUrl = 'https://api.appydex.co';

// Override for development
// In diagnostics screen or environment config
await ref.read(apiBaseUrlProvider.notifier)
  .updateBaseUrl('http://localhost:8000');
```

### Making Requests

```dart
// GET request
final response = await apiClient.requestAdmin<List<dynamic>>(
  '/admin/vendors',
  queryParameters: {
    'status': 'verified',
    'limit': 20,
    'offset': 0,
  },
);

// POST request
final response = await apiClient.requestAdmin<Map<String, dynamic>>(
  '/admin/vendors/{id}/verify',
  method: 'POST',
  data: {
    'verified': true,
    'notes': 'All documents verified',
  },
);

// PATCH request
final response = await apiClient.requestAdmin(
  '/admin/users/{id}',
  method: 'PATCH',
  data: {
    'active': false,
  },
);

// DELETE request
final response = await apiClient.requestAdmin(
  '/admin/services/{id}',
  method: 'DELETE',
);
```

### Error Handling

```dart
try {
  final response = await apiClient.requestAdmin('/admin/vendors');
  // Process response
} on DioException catch (e) {
  final error = e.error;
  if (error is AppHttpException) {
    // Show user-friendly error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error.message)),
    );
  }
}
```

---

## 🧪 Testing

### Run Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/auth_test.dart

# Run with coverage
flutter test --coverage
```

### Writing Tests

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  group('AdminSession', () {
    test('should parse valid JSON', () {
      final json = {
        'access_token': 'token123',
        'refresh_token': 'refresh123',
        'roles': ['super_admin'],
        'active_role': 'super_admin',
      };
      
      final session = AdminSession.fromJson(json);
      
      expect(session.isValid, true);
      expect(session.activeRole, AdminRole.superAdmin);
    });
  });
}
```

---

## 📝 Creating New Features

### Step-by-Step Guide

1. **Create the model** (if needed)
   ```dart
   // lib/models/my_entity.dart
   class MyEntity {
     final String id;
     final String name;
     
     MyEntity({required this.id, required this.name});
     
     factory MyEntity.fromJson(Map<String, dynamic> json) {
       return MyEntity(
         id: json['id'] as String,
         name: json['name'] as String,
       );
     }
   }
   ```

2. **Create the repository**
   ```dart
   // lib/repositories/my_entity_repo.dart
   class MyEntityRepository {
     final ApiClient _apiClient;
     
     MyEntityRepository(this._apiClient);
     
     Future<List<MyEntity>> list() async {
       final response = await _apiClient.requestAdmin('/admin/entities');
       return (response.data as List)
         .map((json) => MyEntity.fromJson(json))
         .toList();
     }
   }
   ```

3. **Create the provider**
   ```dart
   // lib/providers/my_entity_provider.dart
   final myEntityRepoProvider = Provider((ref) {
     return MyEntityRepository(ref.watch(apiClientProvider));
   });
   
   final myEntitiesProvider = FutureProvider((ref) {
     return ref.watch(myEntityRepoProvider).list();
   });
   ```

4. **Create the screen**
   ```dart
   // lib/features/my_module/my_entity_screen.dart
   class MyEntityScreen extends ConsumerWidget {
     @override
     Widget build(BuildContext context, WidgetRef ref) {
       final entitiesAsync = ref.watch(myEntitiesProvider);
       
       return AdminLayout(
         currentRoute: AppRoute.myRoute,
         child: entitiesAsync.when(
           loading: () => CircularProgressIndicator(),
           error: (e, st) => Text('Error: $e'),
           data: (entities) => ListView.builder(
             itemCount: entities.length,
             itemBuilder: (context, index) {
               return ListTile(
                 title: Text(entities[index].name),
               );
             },
           ),
         ),
       );
     }
   }
   ```

5. **Add route**
   ```dart
   // lib/routes.dart
   enum AppRoute {
     // ... existing routes
     myRoute('/my-route'),
   }
   
   // lib/main.dart - Add to onGenerateRoute
   case '/my-route':
     return MaterialPageRoute(
       settings: settings,
       builder: (_) => MyEntityScreen(),
     );
   ```

---

## 🐛 Debugging Tips

### Enable Verbose Logging

```dart
// In api_client.dart, Dio is configured with interceptors
// Add logging interceptor for development
dio.interceptors.add(LogInterceptor(
  requestBody: true,
  responseBody: true,
));
```

### View Last Failed Request

```dart
// In diagnostics screen
final lastFailure = ref.watch(lastRequestFailureProvider);
if (lastFailure != null) {
  print(lastFailure.toCurl()); // Get curl command
}
```

### Check Auth State

```dart
// Anywhere in your widget
final session = ref.read(adminSessionProvider);
print('Authenticated: ${session?.isValid}');
print('Role: ${session?.activeRole}');
print('Email: ${session?.email}');
```

---

## 🔄 Common Workflows

### Refresh Data

```dart
// Invalidate provider to refetch
ref.invalidate(myEntitiesProvider);

// Or use RefreshIndicator
RefreshIndicator(
  onRefresh: () async {
    ref.invalidate(myEntitiesProvider);
    await ref.read(myEntitiesProvider.future);
  },
  child: ListView(...),
);
```

### Show Loading State

```dart
final asyncValue = ref.watch(myProvider);

asyncValue.when(
  loading: () => CircularProgressIndicator(),
  error: (e, st) => Text('Error: $e'),
  data: (data) => MyWidget(data: data),
);

// Or use maybeWhen for partial handling
final data = asyncValue.maybeWhen(
  data: (value) => value,
  orElse: () => <MyType>[],
);
```

### Navigate with Arguments

```dart
// Navigate with arguments
Navigator.of(context).pushNamed(
  AppRoute.vendorDetail.path,
  arguments: VendorDetailArgs(vendorId: 'vendor-123'),
);

// Receive arguments
final args = ModalRoute.of(context)?.settings.arguments as MyArgs?;
```

---

## 📚 Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Riverpod Documentation](https://riverpod.dev)
- [Material Design 3](https://m3.material.io)
- [AppyDex Backend API Docs](https://api.appydex.co/docs) (when available)

---

## 🤝 Contributing

1. Create a feature branch from `main`
2. Follow the existing code structure and naming conventions
3. Write tests for new features
4. Update documentation as needed
5. Submit a pull request with clear description

---

## ⚡ Performance Tips

1. **Use const constructors** where possible
2. **Avoid rebuilds** with proper provider scoping
3. **Lazy load** data with pagination
4. **Cache images** and API responses when appropriate
5. **Profile** with Flutter DevTools to identify bottlenecks

---

**Happy Coding! 🎉**

For issues or questions, refer to IMPLEMENTATION_STATUS.md or contact the dev team.
