# Merchant Configuration Feature

## Overview
Complete merchant configuration management system with support for:
- Business information editing
- Payment provider credential verification (MTN & Airtel)
- Bank account management
- Webhook configuration and testing
- KYC status tracking

## New Files Created

### 1. `/lib/pages/settings/merchant_config_page.dart`
**Purpose**: Main UI page for merchant configuration
**Features**:
- Business Information Section - Edit business details, contact info, website
- Payment Providers Section - Manage MTN and Airtel credentials
- Bank Account Section - Configure and verify bank accounts
- Webhook Configuration - Set webhook URL, secret, and test events
- KYC Status Display - Show verification status with indicators
- Comprehensive dialogs for each credential type verification

**Key Widgets**:
- `MerchantConfigPage` - Main stateful widget using Consumer pattern
- `_BusinessInfoSection` - Editable business information form
- `_PaymentProvidersSection` - MTN/Airtel provider cards
- `_BankAccountSection` - Bank account display and configuration
- `_WebhookSection` - Webhook management
- `_KycSection` - KYC status display
- Dialog widgets for each credential verification type

### 2. `/lib/pages/settings/merchant_config_provider.dart`
**Purpose**: State management for merchant configuration
**Responsibilities**:
- Manages merchant configuration state (config, loading, error)
- Provides methods for all configuration operations:
  - `loadConfiguration()` - Fetch config from API
  - `updateBusinessInfo()` - Update business details
  - `verifyMtnCredentials()` - Verify MTN credentials
  - `verifyAirtelCredentials()` - Verify Airtel credentials
  - `verifyBankAccount()` - Verify bank account
  - `testWebhook()` - Send webhook test event
- Automatically reloads configuration after updates
- Extends ChangeNotifier for provider pattern integration

## Updated Files

### 1. `/lib/nav.dart`
**Changes**:
- Added import for `merchant_config_page.dart`
- Added nested route under profile:
  ```dart
  GoRoute(
    path: AppRoutes.merchantConfig,
    name: 'merchantConfig',
    pageBuilder: (context, state) => NoTransitionPage(
      child: MerchantConfigPage(api: state.extra as dynamic),
    ),
  )
  ```
- Added `merchantConfig` route constant to `AppRoutes`

### 2. `/lib/pages/profile/profile_page.dart`
**Changes**:
- Added "Merchant Configuration" tile at top of settings section
- Clicking navigates to merchant configuration page using `context.pushNamed()`
- Icon: `Icons.settings_outlined`
- Subtitle: "Business & payment settings"

### 3. `/lib/main.dart`
**Changes**:
- Added import for `merchant_config_provider.dart`
- Added `MerchantConfigProvider` to MultiProvider:
  ```dart
  ChangeNotifierProvider(
    create: (_) => MerchantConfigProvider(api: api),
  ),
  ```

## Architecture

### Data Flow
```
MerchantConfigPage (UI)
    ↓
MerchantConfigProvider (State Management)
    ↓
MerchantConfigService (API Layer)
    ↓
PaymentGatewayApi (HTTP Client)
```

### Features

#### Business Information
Edit fields:
- Business Name
- Registration Number
- Tax ID
- Business Category
- Website URL
- Business Address
- Contact Person Name
- Contact Phone
- Contact Email

#### Payment Providers
Support for:
- **MTN Money**: Subscription Key, API Key, X-Reference ID, Environment
- **Airtel Money**: Client ID, Client Secret, Signing Secret, Environment

Status indicators:
- Green checkmark if verified
- Red X if not verified
- Last verification date

#### Bank Account
Configuration:
- Account Number
- Bank Code
- Account Holder Name

Status:
- Verification indicator (Verified/Not Verified)
- Full details display when configured

#### Webhooks
Configuration:
- Webhook URL
- Webhook Secret
- Event subscription list

Testing:
- Test event type selector (payment.success, payment.failed, disbursement.complete, disbursement.failed)
- Send Test Event button with loading indicator

#### KYC Status
Display:
- Status indicator (Verified, Pending, Rejected, Needs Update)
- Submission date
- Verification date
- Rejection reason (if applicable)
- Color-coded status (green for verified, red for rejected, amber for pending/needs update)

## Integration

### Navigation
From Profile page → Settings section → "Merchant Configuration" tile → MerchantConfigPage

### State Management
- Provider pattern for reactive updates
- Automatic reloading after configuration changes
- Error handling with user-friendly messages
- Loading states with spinners

### API Integration
All operations automatically:
- Include bearer token (from auth)
- Include API key and tenant ID headers
- Unwrap response structure `{success: true, data: {...}}`
- Log requests/responses for debugging
- Handle errors with try-catch

## Error Handling
- Network errors shown in SnackBars
- Form validation in dialogs
- Loading states disable buttons
- Empty state displays if configuration fails to load
- Refresh button available on main page and in snackbar actions

## User Experience Features
- Pull-to-refresh on configuration page
- Visual status indicators for all credentials
- Grouped information into logical sections
- Confirmation dialogs before sensitive operations
- Progress indicators during verification
- Success/error feedback via SnackBars
- Responsive design for mobile and tablet

## API Endpoints Used
- `GET /api/v1/merchant/configuration` - Fetch configuration
- `PATCH /api/v1/merchant/configuration` - Update business info
- `POST /api/v1/merchant/configuration/verify/mtn` - Verify MTN
- `POST /api/v1/merchant/configuration/verify/airtel` - Verify Airtel
- `POST /api/v1/merchant/configuration/verify/bank` - Verify bank account
- `POST /api/v1/merchant/configuration/webhook/test` - Test webhook

## Future Enhancements
- KYC submission form
- Director information management
- Beneficial owner details
- Rate limit configuration
- Encryption key management
- Compliance notes editing
