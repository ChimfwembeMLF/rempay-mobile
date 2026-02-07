# Rempay MVP Constitution (Flutter/Dart)

## Core Principles
1. **Clean architecture, strict boundaries**
	- Presentation (UI/state) depends on Domain (business rules) only.
	- Data (API/DB/DTO) depends on Domain, never the other way.
2. **Repository pattern**
	- Domain defines repository interfaces; Data implements them.
3. **Typed, validated models**
	- DTOs are validated on parse; Domain models enforce invariants.
4. **Predictable state & navigation**
	- Single state management approach (Provider/ChangeNotifier) and go_router.
5. **Testability first**
	- Unit/widget/integration tests are required for meaningful changes.

## Architecture & Layer Rules
### MUST
- Keep Domain pure: no Flutter imports, no HTTP, no persistence code.
- Keep Data isolated: only Data touches APIs, DTOs, services in [lib/data](lib/data).
- Keep UI in Presentation: pages/widgets in [lib/pages](lib/pages) and [lib/widgets](lib/widgets).
- Define repository interfaces in Domain (e.g., `PaymentRepository`) and implement in Data.
- Map DTO → Domain model before exposing to UI.
- Validate DTOs when decoding (null/format checks) and Domain models on construction.
- Use go_router via [lib/nav.dart](lib/nav.dart) for navigation.
- Keep error handling consistent: return domain failures or throw typed errors, not strings.

### SHOULD
- Keep use-cases/business logic in Domain, not in widgets.
- Use immutable state objects and notify via ChangeNotifier only.
- Add simple mapping helpers in Data (e.g., `PaymentDto.toDomain()`).

### MUST NOT
- Presentation must not call APIs/services directly.
- Domain must not import Flutter or `dart:io`.
- DTOs must not leak into UI widgets.
- Widgets must not contain business rules beyond formatting.

## State Management & Routing
- MUST keep all app navigation in `AppRouter` and only use `context.go()`/`context.push()`.
- MUST keep state objects in Presentation and expose only view models to widgets.
- SHOULD prefer a single ChangeNotifier per feature over shared global state.

**Example (layer flow):** UI → `PaymentRepository` (Domain) → `PaymentGatewayService` (Data) → DTO → Domain Model.

## Error Handling & Logging
- MUST convert transport errors into domain-level failures.
- MUST log with a single logger utility (if added) and avoid `print()` in production.
- SHOULD include context (feature, action, id) in logs.

## Testing Standards
- MUST add **unit tests** for Domain logic and Data mapping/validation.
- MUST add **widget tests** for key screens in [lib/pages](lib/pages).
- SHOULD add **integration tests** for end-to-end flows (routing + repository).

## Naming & Code Style
- MUST follow Dart style: files in lower_snake_case, types in UpperCamelCase, members in lowerCamelCase.
- MUST keep public APIs documented with `///`.
- SHOULD keep functions short and single-purpose.

## Folder Boundaries (Current)
- Presentation: [lib/pages](lib/pages), [lib/widgets](lib/widgets)
- Domain: [lib/domain](lib/domain)
- Data: [lib/data](lib/data)
- Shared utilities: [lib/utils](lib/utils), [lib/theme.dart](lib/theme.dart)

If restructuring becomes necessary, choose **one** of these common layouts:
1. **Layer-first:** `lib/{presentation,domain,data}/...`
2. **Feature-first:** `lib/features/<feature>/{presentation,domain,data}/...`

## Do not
- Do not add API calls inside widgets.
- Do not bypass repository interfaces.
- Do not pass DTOs into UI.
- Do not mix multiple state management patterns in a single feature.
- Do not add routes outside [lib/nav.dart](lib/nav.dart).

## Governance
- This constitution overrides local practices.
- Any exception MUST be documented with rationale and scope.

**Version**: 1.0.0 | **Ratified**: 2026-02-06 | **Last Amended**: 2026-02-06
