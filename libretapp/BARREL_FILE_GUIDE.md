# LibretApp Code Refactoring - Best Practices Guide

## Barrel File Usage Guidelines

### What are Barrel Files?
Barrel files (also called index files or star files) are files that re-export public APIs from a folder. They simplify imports and create clean boundaries between modules.

### Structure

```
lib/
├── core/
│   ├── core.dart              ← Master barrel (exports all submodules)
│   ├── services/
│   │   ├── services.dart      ← Module barrel (exports all services)
│   │   ├── logger_service.dart
│   │   └── shared_prefs_service.dart
│   └── widgets/
│       ├── widgets.dart       ← Module barrel
│       └── responsive_scaler.dart
├── app/
│   ├── app_index.dart         ← Master barrel
│   ├── app.dart               ← Implementation
│   └── widgets/
│       ├── widgets.dart       ← Module barrel
│       └── shell_fab.dart
└── features/
    ├── directorio/
    │   ├── directorio.dart    ← Feature barrel
    │   ├── animales/
    │   │   ├── animales.dart  ← Subfeature barrel
    │   │   └── bloc/
    │   │       └── animales_bloc.dart
    │   └── lotes/
    │       └── lotes_barrel.dart
```

## Import Patterns

### ✅ DO: Use barrel files for imports

```dart
// Good
import 'package:libretapp/core/core.dart';
import 'package:libretapp/features/directorio/directorio.dart';

// This provides:
// - Cleaner imports
// - Single entry point per module
// - Easier refactoring
```

### ❌ DON'T: Deep path imports when barrel files exist

```dart
// Avoid
import 'package:libretapp/core/services/logger_service.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/core/widgets/responsive_scaler.dart';

// Better
import 'package:libretapp/core/core.dart';
```

## Creating New Modules

When adding a new feature or module:

1. **Create folder structure**
   ```
   lib/features/new_feature/
   ├── bloc/
   ├── data/
   ├── domain/
   ├── view/
   ├── widgets/
   └── new_feature.dart  ← Create this barrel file
   ```

2. **Create barrel file**
   ```dart
   // lib/features/new_feature/new_feature.dart
   export 'bloc/new_feature_bloc.dart';
   export 'bloc/new_feature_event.dart';
   export 'bloc/new_feature_state.dart';
   export 'data/new_feature_repository.dart';
   export 'view/view.dart';
   export 'widgets/widgets.dart';
   ```

3. **Use in imports**
   ```dart
   import 'package:libretapp/features/new_feature/new_feature.dart';
   ```

## Handling Import Conflicts

When two modules export classes with the same name, use `hide` directive:

```dart
// lib/features/directorio/directorio.dart
export 'animales/animales.dart' hide ClearSearch;
export 'bloc/directorio_event.dart';  // Has ClearSearch
```

## Circular Dependency Prevention

Never circular-import barrel files:

```dart
// ❌ AVOID
// lib/core/core.dart
export 'services/services.dart';

// lib/core/services/services.dart  
import 'package:libretapp/core/core.dart';  // CIRCULAR!

// ✅ DO - Keep barrel files as exports only
// lib/core/services/services.dart has no imports from parent barrels
```

## When NOT to Use Barrel Files

Small utility files that are only used in one place don't need barrels:

```dart
// lib/core/utils/string_extensions.dart can be imported directly
import 'package:libretapp/core/utils/string_extensions.dart';
```

## Barrel File Checklist

When creating a new barrel file:

- [ ] File named `module_name.dart` or `index.dart` in the folder
- [ ] Export all public APIs from the module
- [ ] DO NOT import code from parent barrels (avoid circular dependencies)
- [ ] DO NOT include private implementations (_prefixed files)
- [ ] Handle name conflicts with `hide` where necessary
- [ ] Document the barrel file purpose with comments if complex
- [ ] Update parent barrel to export the new module barrel

## Common Patterns

### Exporting a sub-barrel with hiding
```dart
export 'animales/animales.dart' hide ClearSearch;
export 'bloc/directorio_event.dart';  // Re-export the conflicting class
```

### Exporting only specific items
```dart
// Instead of exporting everything
export 'bloc/bloc.dart' show MyBloc, MyEvent;

export 'widgets/widgets.dart';
```

### Organizing by layer
```dart
// Core module organization
export 'database/database.dart';      // Data layer
export 'services/services.dart';      // Service layer
export 'di/di.dart';                  // Dependency injection
export 'widgets/widgets.dart';        // Presentation utilities
```

## Maintenance Guidelines

### When updating module contents
1. Update the module's barrel file
2. Update parent barrel files if needed
3. No changes needed in files importing through barrels

### When moving files
1. Update barrel file export paths
2. Files importing through barrels are unaffected
3. Only direct imports need updating

### When splitting modules
1. Create new barrel file for split module
2. Update parent barrel to export both
3. Existing imports continue to work if using parent barrel

## IDE Integration

Most IDEs can auto-organize imports:
- VS Code: Format Document (`Shift+Alt+F`)
- Android Studio: Code → Optimize Imports
- Works best when barrel files are properly configured

## Build and Analysis

Run validation:

```bash
# Check for errors
flutter analyze

# Build validation
flutter pub run build_runner build --delete-conflicting-outputs

# Test compilation
flutter build apk --analyze-size (or flutter build web)
```

## Summary

The barrel file pattern in LibretApp:

1. **Simplifies imports**: Replace 5+ imports with 1-2 barrel imports
2. **Protects from refactoring**: Internal changes don't break external code
3. **Clarifies module boundaries**: Clear public API per module
4. **Improves scalability**: Easier to add and maintain new features
5. **Reduces cognitive load**: Developers see clear structure

By following these guidelines, the codebase will remain clean, maintainable, and scalable as it grows.
