# Phase 5 — Extended Modules (v0.5.0)

## Context Links
- [Architecture Report](../reports/brainstorm-260409-1103-agentic-base-architecture.md) — Section 6.2
- [Phase 2](./phase-02-feature-and-module-system.md) — Module contract + registry

## Overview
- **Priority**: P2
- **Status**: Completed
- **Effort**: 15h
- **Depends on**: Phase 2

Add remaining 17 built-in modules across 5 categories: Communication & Engagement (5), Monetization (4), Media (4), Location & Maps (2), Device & System (4). Includes module dependency graph and enhanced conflict resolution.

## Requirements

### Functional
- All 17 modules follow AgenticModule contract from Phase 2
- Each module: contract-based (swappable implementations), auto-wired DI, test stubs
- Module dependency graph: some modules depend on others (e.g., social_login needs auth)
- Conflict matrix expanded with all 25 modules

### Non-Functional
- Each module independently installable
- No module exceeds 200 LOC per file
- Install time <30 seconds per module

## Module Catalog

### Communication & Engagement (5)
| Module | Packages | Dependencies | Conflicts |
|--------|----------|-------------|-----------|
| notifications | awesome_notifications | — | — |
| deep_link | app_links, uni_links | — | — |
| in_app_review | in_app_review | — | — |
| share | share_plus | — | — |
| social_login | google_sign_in, sign_in_with_apple | auth | — |

### Monetization (4)
| Module | Packages | Dependencies | Conflicts |
|--------|----------|-------------|-----------|
| ads | google_mobile_ads | — | — |
| payments | purchases_flutter | — | — |
| remote_config | firebase_remote_config | — | — |
| feature_flags | custom | — | — |

### Media (4)
| Module | Packages | Dependencies | Conflicts |
|--------|----------|-------------|-----------|
| image_picker | image_picker, image_cropper | permissions | — |
| camera | camerawesome | permissions | — |
| video_player | media_kit | — | — |
| qr_scanner | mobile_scanner | permissions, camera | — |

### Location & Maps (2)
| Module | Packages | Dependencies | Conflicts |
|--------|----------|-------------|-----------|
| location | geolocator, geocoding | permissions | — |
| maps | google_maps_flutter | location | — |

### Device & System (4)
| Module | Packages | Dependencies | Conflicts |
|--------|----------|-------------|-----------|
| biometric | local_auth | — | — |
| file_manager | open_filex, path_provider | permissions | — |
| app_update | upgrader | — | — |
| webview | flutter_inappwebview | — | — |
| onboarding | custom (PageView-based) | — | — |

## Implementation Steps

### Step 1: Module Dependency Resolution
1. Update `module_registry.dart` with dependency graph
2. `add` command auto-installs required dependencies first
3. `remove` command checks no other module depends on it
4. Display dependency chain to user before install

### Step 2: Communication Modules (5)
For each: create module class + mason brick (contract + impl + DI + tests)
1. notifications (awesome_notifications): NotificationService contract, local+push+scheduled
2. deep_link (app_links + uni_links): DeepLinkService contract, handler setup
3. in_app_review: ReviewService contract, smart trigger logic
4. share: ShareService contract, content sharing
5. social_login: SocialLoginService contract, Google + Apple Sign In (depends on auth module)

### Step 3: Monetization Modules (4)
1. ads (google_mobile_ads): AdService contract, banner/interstitial/rewarded + consent
2. payments (purchases_flutter/RevenueCat): PaymentService contract, IAP + subscriptions
3. remote_config (firebase_remote_config): RemoteConfigService contract
4. feature_flags: FeatureFlagService contract, local SharedPrefs + optional remote

### Step 4: Media Modules (4)
1. image_picker: ImagePickerService contract, pick/crop/compress
2. camera (camerawesome): CameraService contract, photo + video
3. video_player (media_kit): VideoPlayerService contract
4. qr_scanner (mobile_scanner): ScannerService contract

### Step 5: Location & Maps (2)
1. location (geolocator + geocoding): LocationService contract, GPS + address
2. maps (google_maps_flutter): MapService contract, markers + directions

### Step 6: Device & System (4+1)
1. biometric (local_auth): BiometricService contract
2. file_manager (open_filex + path_provider): FileService contract
3. app_update (upgrader): UpdateService contract, force/optional
4. webview (flutter_inappwebview): WebViewService contract
5. onboarding: custom PageView-based template (no external package)

### Step 7: Integration Testing
1. Test installing multiple modules together
2. Test dependency auto-installation (e.g., `add maps` auto-installs `location` + `permissions`)
3. Verify no pubspec conflicts across all module combinations
4. Verify generated project compiles with 5+ modules installed

## Todo List
- [x] Module dependency resolution in registry
- [x] Communication: notifications, deep_link, in_app_review, share, social_login
- [x] Monetization: ads, payments, remote_config, feature_flags
- [x] Media: image_picker, camera, video_player, qr_scanner
- [x] Location: location, maps
- [x] Device: biometric, file_manager, app_update, webview, onboarding
- [x] Integration test: multi-module install + dependency chain
- [x] Update conflict matrix for all 25 modules

## Success Criteria
- [x] All 17 modules installable via `agentic_base add`
- [x] Dependency auto-install works (e.g., `add maps` installs location + permissions)
- [x] Conflict detection covers all 25 modules
- [x] Generated project compiles with 5+ modules
- [x] Each module follows contract pattern (swappable)

## Risk Assessment
| Risk | Impact | Mitigation |
|------|--------|------------|
| 17 modules = large test surface | Missed bugs | Test each module + common combos |
| Package version conflicts across modules | pubspec errors | Test full matrix in CI |
| Module dependency cycles | Infinite loop | Validate DAG in registry |

## Next Steps
→ Phase 6: Multi-State & Bricks
