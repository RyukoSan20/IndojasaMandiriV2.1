# FinTrack - Project Tasks

## Document Information
- **Project Name:** FinTrack
- **Type:** Personal Finance & Stock Portfolio Tracker Mobile Application
- **Total Parts:** 3
- **Current Part:** 1 of 3

---

## Table of Contents - Part 1
1. [Project Setup & Configuration](#1-project-setup--configuration)
2. [Core Architecture & Infrastructure](#2-core-architecture--infrastructure)
3. [Authentication System](#3-authentication-system)
4. [Data Models & Database Schema](#4-data-models--database-schema)
5. [State Management Implementation](#5-state-management-implementation)

---

## 1. Project Setup & Configuration

### 1.1 Environment Setup
- [ ] Install Flutter SDK (latest stable version)
- [ ] Configure Android SDK with proper API levels
- [ ] Configure iOS deployment target (iOS 12.0+)
- [ ] Install CocoaPods for iOS dependencies
- [ ] Set up development IDE (VS Code / Android Studio)
- [ ] Configure emulator for testing (Pixel 4, iPhone 12)
- [ ] Set up physical device testing environment

### 1.2 Project Initialization
- [ ] Create Flutter project: `flutter create flintrack`
- [ ] Set project name: `com.flintrack.app`
- [ ] Set application ID (Android): `com.flintrack.app`
- [ ] Set bundle identifier (iOS): `com.flintrack.app`
- [ ] Configure project display name: "FinTrack"
- [ ] Set version code and version name
- [ ] Configure app icon and splash screen
- [ ] Set up app signing for debug and release builds

### 1.3 Dependencies Configuration
- [ ] **State Management**
  - [ ] Add `flutter_bloc: ^8.1.3` - BLoC pattern implementation
  - [ ] Add `provider: ^6.1.1` - Dependency injection
  - [ ] Add `get_it: ^7.6.4` - Service locator

- [ ] **Local Database**
  - [ ] Add `sqflite: ^2.3.0` - SQLite database
  - [ ] Add `path: ^1.8.3` - Path manipulation
  - [ ] Add `drift: ^2.14.1` - Type-safe database
  - [ ] Add `drift_flutter: ^0.1.0` - Drift Flutter bindings

- [ ] **Network & API**
  - [ ] Add `dio: ^5.3.3` - HTTP client
  - [ ] Add `connectivity_plus: ^5.0.2` - Network status
  - [ ] Add `hive: ^2.2.3` - Local key-value storage
  - [ ] Add `hive_flutter: ^1.1.0` - Hive Flutter bindings

- [ ] **Authentication**
  - [ ] Add `firebase_core: ^2.24.2` - Firebase initialization
  - [ ] Add `firebase_auth: ^4.16.0` - Firebase authentication
  - [ ] Add `google_sign_in: ^6.1.5` - Google sign-in
  - [ ] Add `flutter_secure_storage: ^9.0.0` - Secure storage

- [ ] **UI Components**
  - [ ] Add `flutter_svg: ^2.0.9` - SVG rendering
  - [ ] Add `cached_network_image: ^3.3.0` - Image caching
  - [ ] Add `shimmer: ^3.0.0` - Loading effects
  - [ ] Add `fl_chart: ^0.65.0` - Charts library
  - [ ] Add `percent_indicator: ^4.2.3` - Progress indicators

- [ ] **Utilities**
  - [ ] Add `intl: ^0.18.1` - Internationalization
  - [ ] Add `uuid: ^4.2.1` - UUID generation
  - [ ] Add `equatable: ^2.0.5` - Value equality
  - [ ] Add `dartz: ^0.10.1` - Functional programming
  - [ ] Add `local_auth: ^2.1.7` - Biometric authentication
  - [ ] Add `flutter_local_notifications: ^16.2.0` - Notifications
  - [ ] Add `share_plus: ^7.2.1` - Share functionality
  - [ ] Add `image_picker: ^1.0.4` - Image selection
  - [ ] Add `path_provider: ^2.1.1` - File paths
  - [ ] Add `permission_handler: ^11.1.0` - Permissions

### 1.4 Project Structure Setup

lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_typography.dart
│   │   ├── app_spacing.dart
│   │   ├── app_strings.dart
│   │   └── app_assets.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   ├── light_theme.dart
│   │   └── dark_theme.dart
│   ├── utils/
│   │   ├── currency_formatter.dart
│   │   ├── date_formatter.dart
│   │   ├── validators.dart
│   │   └── extensions.dart
│   ├── errors/
│   │   ├── failures.dart
│   │   └── exceptions.dart
│   └── routing/
│       ├── app_router.dart
│       └── route_names.dart
├── data/
│   ├── datasources/
│   │   ├── local/
│   │   └── remote/
│   ├── models/
│   ├── repositories/
│   └── database/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── presentation/
│   ├── blocs/
│   ├── pages/
│   ├── widgets/
│   └── common/
└── services/
    ├── auth_service.dart
    ├── storage_service.dart
    └── notification_service.dart


### 1.5 Asset Configuration
- [ ] Create assets directory structure
- [ ] Add app logo (SVG, PNG variants)
- [ ] Add icon set for categories
- [ ] Add placeholder images
- [ ] Configure pubspec.yaml asset paths
- [ ] Add custom fonts (Poppins, Inter)
- [ ] Configure font loading in theme

### 1.6 Build Configuration
- [ ] Configure Android build.gradle settings
- [ ] Configure iOS Podfile settings
- [ ] Set up environment-specific configurations
- [ ] Configure ProGuard rules for release
- [ ] Set up code signing certificates
- [ ] Configure build flavors (dev, staging, prod)

---

## 2. Core Architecture & Infrastructure

### 2.1 Clean Architecture Setup
- [ ] Implement domain layer (entities, repositories interfaces, use cases)
- [ ] Implement data layer (models, data sources, repository implementations)
- [ ] Implement presentation layer (blocs, pages, widgets)
- [ ] Set up dependency injection container
- [ ] Configure dependency injection bindings
- [ ] Implement dependency injection module structure

### 2.2 Repository Pattern Implementation
- [ ] Define repository interfaces in domain layer
- [ ] Implement repository concrete classes in data layer
- [ ] Set up repository data sources (local, remote)
- [ ] Implement repository method signatures
- [ ] Add error handling and mapping

### 2.3 Use Cases Implementation
#### Authentication Use Cases
- [ ] Implement `LoginWithEmailUseCase`
- [ ] Implement `LoginWithGoogleUseCase`
- [ ] Implement `RegisterWithEmailUseCase`
- [ ] Implement `LogoutUseCase`
- [ ] Implement `ResetPasswordUseCase`
- [ ] Implement `CheckAuthStatusUseCase`

#### Transaction Use Cases
- [ ] Implement `AddTransactionUseCase`
- [ ] Implement `UpdateTransactionUseCase`
- [ ] Implement `DeleteTransactionUseCase`
- [ ] Implement `GetTransactionsUseCase`
- [ ] Implement `GetTransactionsByDateRangeUseCase`
- [ ] Implement `GetTransactionsByCategoryUseCase`
- [ ] Implement `GetTransactionsByAccountUseCase`

#### Account Use Cases
- [ ] Implement `AddAccountUseCase`
- [ ] Implement `UpdateAccountUseCase`
- [ ] Implement `DeleteAccountUseCase`
- [ ] Implement `GetAccountsUseCase`
- [ ] Implement `GetAccountBalanceUseCase`
- [ ] Implement `TransferBetweenAccountsUseCase`

#### Savings Target Use Cases
- [ ] Implement `CreateSavingsTargetUseCase`
- [ ] Implement `UpdateSavingsTargetUseCase`
- [ ] Implement `DeleteSavingsTargetUseCase`
- [ ] Implement `GetSavingsTargetsUseCase`
- [ ] Implement `AddToSavingsTargetUseCase`
- [ ] Implement `GetSavingsProgressUseCase`

#### Stock Portfolio Use Cases
- [ ] Implement `AddStockUseCase`
- [ ] Implement `UpdateStockPositionUseCase`
- [ ] Implement `RemoveStockUseCase`
- [ ] Implement `GetPortfolioUseCase`
- [ ] Implement `GetPortfolioValueUseCase`
- [ ] Implement `CalculateProfitLossUseCase`
- [ ] Implement `CalculateAverageBuyPriceUseCase`
- [ ] Implement `CalculateReturnsUseCase`

### 2.4 Dependency Injection Setup
- [ ] Configure GetIt service locator
- [ ] Register data sources
- [ ] Register repositories
- [ ] Register use cases
- [ ] Register BLoCs/Cubits
- [ ] Configure lazy singletons where appropriate
- [ ] Set up factory registrations

### 2.5 Error Handling Infrastructure
- [ ] Implement base Failure class
- [ ] Implement specific failure types:
  - [ ] `ServerFailure`
  - [ ] `CacheFailure`
  - [ ] `NetworkFailure`
  - [ ] `AuthFailure`
  - [ ] `ValidationFailure`
  - [ ] `DatabaseFailure`
- [ ] Implement Exception classes
- [ ] Create error mapping utilities
- [ ] Set up global error handling

### 2.6 Logging Infrastructure
- [ ] Configure logging package
- [ ] Set up log levels (debug, info, warning, error)
- [ ] Implement log output destinations
- [ ] Add user action logging
- [ ] Implement crash reporting integration

---

## 3. Authentication System

### 3.1 Firebase Configuration
- [ ] Create Firebase project
- [ ] Configure Firebase console settings
- [ ] Add Android SHA-1 fingerprint
- [ ] Add iOS configuration files
- [ ] Enable authentication providers:
  - [ ] Email/Password
  - [ ] Google Sign-In
- [ ] Configure sign-in methods settings
- [ ] Set up Firebase rules
- [ ] Download google-services.json
- [ ] Download GoogleService-Info.plist

### 3.2 Authentication Service
- [ ] Implement `AuthService` class
- [ ] Implement email/password registration
- [ ] Implement email/password login
- [ ] Implement Google sign-in
- [ ] Implement password reset
- [ ] Implement logout functionality
- [ ] Implement auth state listening
- [ ] Implement token management
- [ ] Implement session management
- [ ] Add error handling for auth errors

### 3.3 Authentication BLoC
- [ ] Create `AuthEvent` base class
- [ ] Create auth events:
  - [ ] `AuthCheckRequested`
  - [ ] `AuthLoginRequested`
  - [ ] `AuthRegisterRequested`
  - [ ] `AuthGoogleLoginRequested`
  - [ ] `AuthLogoutRequested`
  - [ ] `AuthPasswordResetRequested`
- [ ] Create `AuthState` base class
- [ ] Create auth states:
  - [ ] `AuthInitial`
  - [ ] `AuthLoading`
  - [ ] `AuthAuthenticated`
  - [ ] `AuthUnauthenticated`
  - [ ] `AuthFailure`
- [ ] Implement `AuthBloc` class
- [ ] Handle state transitions
- [ ] Implement event handlers

### 3.4 PIN Authentication
- [ ] Implement PIN service
- [ ] Create PIN setup flow
- [ ] Implement PIN verification
- [ ] Implement PIN change functionality
- [ ] Implement PIN reset functionality
- [ ] Store PIN securely (encrypted)
- [ ] Implement PIN attempt limits
- [ ] Create lockout mechanism

### 3.5 Biometric Authentication
- [ ] Configure biometric permissions
- [ ] Implement biometric service
- [ ] Check biometric availability
- [ ] Implement fingerprint authentication
- [ ] Implement Face ID authentication
- [ ] Create biometric enable/disable toggle
- [ ] Implement biometric fallback to PIN

### 3.6 Auth UI Screens
#### Splash Screen
- [ ] Design splash screen layout
- [ ] Implement app initialization logic
- [ ] Check authentication status
- [ ] Navigate based on auth state
- [ ] Show app branding/logo
- [ ] Implement loading indicator

#### Login Screen
- [ ] Design login screen layout
- [ ] Implement email input field
- [ ] Implement password input field
- [ ] Add show/hide password toggle
- [ ] Implement "Remember me" checkbox
- [ ] Create "Forgot Password" link
- [ ] Implement login button
- [ ] Implement Google sign-in button
- [ ] Add loading state
- [ ] Implement form validation
- [ ] Handle error display

#### Registration Screen
- [ ] Design registration screen layout
- [ ] Implement name input field
- [ ] Implement email input field
- [ ] Implement password input field
- [ ] Implement confirm password field
- [ ] Add password strength indicator
- [ ] Implement registration button
- [ ] Add terms and conditions checkbox
- [ ] Add link to login screen
- [ ] Implement form validation

#### Forgot Password Screen
- [ ] Design forgot password screen layout
- [ ] Implement email input field
- [ ] Implement "Send Reset Link" button
- [ ] Show success message
- [ ] Add link back to login

#### PIN Setup Screen
- [ ] Design PIN setup screen layout
- [ ] Implement 6-digit PIN input
- [ ] Create PIN confirmation step
- [ ] Implement numeric keypad
- [ ] Add visual feedback for input
- [ ] Implement error handling

#### PIN Entry Screen
- [ ] Design PIN entry screen layout
- [ ] Implement PIN input
- [ ] Create biometric button
- [ ] Add "Forgot PIN" option
- [ ] Implement attempt counter
- [ ] Show lockout message

---

## 4. Data Models & Database Schema

### 4.1 User Model
dart
class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool isEmailVerified;
  final bool isPinEnabled;
  final bool isBiometricEnabled;
  final String? defaultCurrency;
  final String? defaultLanguage;
}


### 4.2 Transaction Model
dart
class TransactionModel {
  final String id;
  final String userId;
  final double amount;
  final TransactionType type; // income, expense
  final String categoryId;
  final String? accountId;
  final String? description;
  final DateTime date;
  final String? receiptUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;
}

enum TransactionType { income, expense }


### 4.3 Category Model
dart
class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final String color;
  final CategoryType type; // income, expense
  final bool isDefault;
  final String? parentId;
}


### 4.4 Account Model
dart
class AccountModel {
  final String id;
  final String userId;
  final String name;
  final AccountType type;
  final double balance;
  final String? institutionName;
  final String? accountNumber;
  final String? icon;
  final String? color;
  final DateTime createdAt;
  final DateTime? updatedAt;
}

enum AccountType { cash, bank, eWallet, savings, investment }


### 4.5 Savings Target Model
dart
class SavingsTargetModel {
  final String id;
  final String userId;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime? targetDate;
  final String? icon;
  final String? color;
  final SavingsTargetStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
}

enum SavingsTargetStatus { active, completed, cancelled }


### 4.6 Stock Portfolio Model
dart
class StockPositionModel {
  final String id;
  final String userId;
  final String symbol;
  final String? companyName;
  final int quantity;
  final double averagePrice;
  final double? currentPrice;
  final String? exchange;
  final DateTime createdAt;
  final DateTime? updatedAt;
}


### 4.7 Stock Watchlist Model
dart
class WatchlistItemModel {
  final String id;
  final String userId;
  final String symbol;
  final String? companyName;
  final double? lastPrice;
  final double? priceChange;
  final double? percentChange;
  final DateTime addedAt;
}


### 4.8 Database Tables Setup
- [ ] Create database migration system
- [ ] Create `users` table schema
- [ ] Create `accounts` table schema
- [ ] Create `transactions` table schema
- [ ] Create `categories` table schema
- [ ] Create `savings_targets` table schema
- [ ] Create `stock_positions` table schema
- [ ] Create `watchlist` table schema
- [ ] Create `settings` table schema
- [ ] Set up foreign key relationships
- [ ] Create necessary indexes
- [ ] Add database versioning

### 4.9 Database Operations
- [ ] Implement CRUD operations for all tables
- [ ] Implement batch operations
- [ ] Implement transaction support
- [ ] Implement query builders
- [ ] Add pagination support
- [ ] Implement data seeding for default categories

---

## 5. State Management Implementation

### 5.1 BLoC Architecture
- [ ] Set up BLoC base classes
- [ ] Configure BLoC observer for debugging
- [ ] Implement BLoC to Cubit converters where appropriate

### 5.2 Authentication BLoC (detailed)
- [ ] Define all auth events
- [ ] Define all auth states
- [ ] Implement auth state machine
- [ ] Add auth repository integration
- [ ] Implement token refresh logic
- [ ] Add logout handling

### 5.3 Dashboard BLoC
- [ ] Create `DashboardEvent` class
- [ ] Create `DashboardState` class
- [ ] Implement `DashboardBloc`
- [ ] Fetch dashboard summary data
- [ ] Calculate total balance
- [ ] Calculate monthly income
- [ ] Calculate monthly expenses
- [ ] Calculate total savings
- [ ] Calculate portfolio value
- [ ] Generate dashboard insights

### 5.4 Transaction BLoC
- [ ] Create `TransactionEvent` class
- [ ] Create `TransactionState` class
- [ ] Implement `TransactionBloc`
- [ ] Add transaction operations
- [ ] Implement transaction filtering
- [ ] Implement transaction search
- [ ] Add pagination support
- [ ] Handle transaction loading states

### 5.5 Account BLoC
- [ ] Create `AccountEvent` class
- [ ] Create `AccountState` class
- [ ] Implement `AccountBloc`
- [ ] Add account CRUD operations
- [ ] Implement balance updates
- [ ] Handle account switching

### 5.6 Savings Target BLoC
- [ ] Create `SavingsTargetEvent` class
- [ ] Create `SavingsTargetState` class
- [ ] Implement `SavingsTargetBloc`
- [ ] Add savings target operations
- [ ] Implement progress tracking
- [ ] Handle target completion

### 5.7 Portfolio BLoC
- [ ] Create `PortfolioEvent` class
- [ ] Create `PortfolioState` class
- [ ] Implement `PortfolioBloc`
- [ ] Add stock operations
- [ ] Implement profit/loss calculation
- [ ] Handle price updates
- [ ] Implement watchlist management

### 5.8 Settings BLoC
- [ ] Create `SettingsEvent` class
- [ ] Create `SettingsState` class
- [ ] Implement `SettingsBloc`
- [ ] Handle theme changes
- [ ] Handle language changes
- [ ] Handle notification settings
- [ ] Handle security settings

### 5.9 Navigation State Management
- [ ] Implement navigation cubit
- [ ] Handle bottom navigation state
- [ ] Implement deep linking support
- [ ] Handle back navigation
- [ ] Manage route parameters

---

## Part 1 Summary

Part 1 covers the foundational elements of the FinTrack application:

1. **Project Setup** - Complete development environment, dependencies, and project structure
2. **Core Architecture** - Clean Architecture implementation with dependency injection
3. **Authentication** - Full auth system including Firebase, PIN, and biometric authentication
4. **Data Models** - Complete data model definitions and database schema
5. **State Management** - BLoC pattern implementation for all features

### Progress Tracking
- Total Tasks: ~180 tasks
- Part 1 Tasks: ~180 tasks (Foundation)
- Estimated Completion: 30% of total project

---

## Continue to Part 2
[Part 2](./TASKS.md_part2.tmp) covers the main feature implementations including Dashboard, Transactions, Accounts, and Savings Targets.

---



## 3. Transaction Management

### 3.1 Transaction Data Model
- [ ] Create Transaction entity with fields: id, type (income/expense), amount, category, account_id, description, date, receipt_url, created_at, updated_at
- [ ] Create TransactionCategory entity with fields: id, name, icon, color, type, is_system, user_id
- [ ] Add SQLite indexes for date and account_id queries
- [ ] Implement TransactionRepository with CRUD operations

### 3.2 Transaction List Screen
- [ ] Design transaction list UI with date headers
- [ ] Implement infinite scroll pagination (20 items per page)
- [ ] Add pull-to-refresh functionality
- [ ] Display transaction type indicator (green for income, red for expense)
- [ ] Show category icon and name for each transaction
- [ ] Implement swipe-to-delete with confirmation
- [ ] Add FAB for quick add transaction

### 3.3 Add/Edit Transaction Screen
- [ ] Create AddTransactionScreen with form fields
- [ ] Implement transaction type toggle (income/expense)
- [ ] Add amount input with currency formatting
- [ ] Implement category picker with grid view
- [ ] Add account selector dropdown
- [ ] Include date picker (default today)
- [ ] Add optional description field
- [ ] Implement receipt image upload feature
- [ ] Add form validation (amount > 0, category required, account required)
- [ ] Handle save with loading state

### 3.4 Category Management
- [ ] Create default expense categories: Makanan, Transportasi, Belanja, Hiburan, Kesehatan, Pendidikan, Tagihan, Lainnya
- [ ] Create default income categories: Gaji, Freelance, Investasi, Bonus, Lainnya
- [ ] Implement custom category creation
- [ ] Add category editing capability
- [ ] Implement category deletion (move transactions to "Lainnya")
- [ ] Store category preferences in local storage

### 3.5 Receipt Scanner
- [ ] Integrate camera for receipt capture
- [ ] Implement image cropping functionality
- [ ] Add OCR placeholder for future receipt parsing
- [ ] Store receipt images locally with compression
- [ ] Link receipts to transaction records

---

## 4. Financial Accounts

### 4.1 Account Data Model
- [ ] Create Account entity with fields: id, name, type, balance, currency, icon, color, is_active, created_at, updated_at, sync_status
- [ ] Create AccountType enum: CASH, BANK, E_WALLET, SAVINGS, INVESTMENT
- [ ] Add AccountRepository with CRUD operations
- [ ] Implement balance calculation from transactions

### 4.2 Account List Screen
- [ ] Design account cards with balance display
- [ ] Show account type icon and color coding
- [ ] Display total balance across all accounts
- [ ] Implement account card tap for details
- [ ] Add account type filter chips
- [ ] Implement add account FAB

### 4.3 Add/Edit Account Screen
- [ ] Create account form with name input
- [ ] Implement account type selector (visual cards)
- [ ] Add initial balance input
- [ ] Include icon picker (emoji-based)
- [ ] Add color picker for account card
- [ ] Implement validation (name required, balance >= 0)

### 4.4 Account Detail Screen
- [ ] Display account information header
- [ ] Show transaction history for account
- [ ] Implement balance edit capability
- [ ] Add account edit/delete options
- [ ] Show account statistics (monthly in/out)

### 4.5 Default Accounts Setup
- [ ] Create "Tunai" cash account on first launch
- [ ] Prompt user to add more accounts
- [ ] Allow skipping account setup

---

## 5. Savings Goals

### 5.1 Savings Goal Data Model
- [ ] Create SavingsGoal entity with fields: id, name, target_amount, current_amount, deadline, icon, color, is_completed, created_at, updated_at
- [ ] Add SavingsGoalRepository with CRUD operations
- [ ] Implement progress calculation

### 5.2 Savings Goal List Screen
- [ ] Design goal cards with progress indicators
- [ ] Show progress percentage and remaining amount
- [ ] Display deadline countdown
- [ ] Add "Tambah Target" button
- [ ] Implement goal completion celebration
- [ ] Show completed vs active goals sections

### 5.3 Add/Edit Savings Goal Screen
- [ ] Create goal form with name input
- [ ] Add target amount input with formatting
- [ ] Include deadline date picker
- [ ] Add icon and color picker
- [ ] Implement existing goal edit
- [ ] Add goal deletion with confirmation

### 5.4 Goal Progress Management
- [ ] Implement add/withdraw funds to goal
- [ ] Show contribution history
- [ ] Calculate estimated completion date
- [ ] Send notification when goal is reached
- [ ] Auto-suggest goal adjustment based on spending

### 5.5 Default Goals
- [ ] Offer to create "Dana Darurat" goal (6x monthly expenses)
- [ ] Present preset goal templates
- [ ] Allow custom goal creation

---

## 6. Stock Portfolio

### 6.1 Stock Data Model
- [ ] Create Stock entity with fields: id, symbol, name, exchange, sector, current_price, last_updated, user_id
- [ ] Create Portfolio holding entity: id, stock_id, quantity, average_buy_price, account_id, created_at, updated_at
- [ ] Add StockRepository and PortfolioRepository
- [ ] Implement price update mechanism

### 6.2 Portfolio Overview Screen
- [ ] Display total portfolio value
- [ ] Show total gain/loss (amount and percentage)
- [ ] List all holdings with current value
- [ ] Show allocation pie chart
- [ ] Add "Tambah Saham" button
- [ ] Implement refresh for latest prices

### 6.3 Add Stock to Portfolio
- [ ] Create stock search functionality
- [ ] Display search results with company name
- [ ] Add stock symbol input
- [ ] Include quantity input
- [ ] Add average buy price input
- [ ] Select linked account
- [ ] Calculate total investment and gain/loss

### 6.4 Stock Detail Screen
- [ ] Show stock information header
- [ ] Display holding details (qty, avg price, current value)
- [ ] Calculate and show profit/loss per stock
- [ ] Show percentage return
- [ ] Add edit/delete holding options
- [ ] Link to external stock chart

### 6.5 Watchlist Feature
- [ ] Create Watchlist entity with stock symbols
- [ ] Implement add/remove from watchlist
- [ ] Display watchlist on portfolio screen
- [ ] Show price change indicators
- [ ] Add quick add to portfolio from watchlist

### 6.6 Portfolio Analytics
- [ ] Calculate sector allocation
- [ ] Show top gainers/losers
- [ ] Display portfolio performance chart
- [ ] Implement time period selector (1D, 1W, 1M, 3M, 1Y, ALL)



# FinTrack - Part 3: Stock Portfolio, Statistics & Advanced Features

---

## 8. Stock Portfolio (Investasi Saham)

### 8.1 Data Model


StockPortfolio {
  id: UUID
  user_id: UUID (FK)
  symbol: String (3-5 chars, e.g., "BBRI", "TLKM")
  company_name: String
  shares: Decimal (lot, 1 lot = 100 shares)
  average_buy_price: Decimal
  current_price: Decimal
  sector: String
  exchange: Enum ("IDX", "NASDAQ", "NYSE")
  created_at: DateTime
  updated_at: DateTime
}

StockTransaction {
  id: UUID
  portfolio_id: UUID (FK)
  user_id: UUID (FK)
  type: Enum ("BUY", "SELL")
  shares: Decimal
  price_per_share: Decimal
  transaction_date: Date
  broker: String
  fee: Decimal
  tax: Decimal
  notes: Text
  created_at: DateTime
}

StockWatchlist {
  id: UUID
  user_id: UUID (FK)
  symbol: String
  company_name: String
  target_price: Decimal
  alert_enabled: Boolean
  created_at: DateTime
}


### 8.2 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /api/v1/stocks/portfolio | Get user stock portfolio |
| POST | /api/v1/stocks/portfolio | Add stock to portfolio |
| PUT | /api/v1/stocks/portfolio/:id | Update stock holding |
| DELETE | /api/v1/stocks/portfolio/:id | Remove from portfolio |
| POST | /api/v1/stocks/portfolio/:id/transactions | Record buy/sell |
| GET | /api/v1/stocks/watchlist | Get watchlist |
| POST | /api/v1/stocks/watchlist | Add to watchlist |
| DELETE | /api/v1/stocks/watchlist/:id | Remove from watchlist |
| GET | /api/v1/stocks/quote/:symbol | Get real-time quote |

### 8.3 User Stories

- [ ] **US-8.1**: User dapat menambah saham ke portofolio dengan simbol, jumlah lot, dan harga rata-rata beli
- [ ] **US-8.2**: Sistem otomatis menghitung total investasi, profit/loss, dan ROI
- [ ] **US-8.3**: User dapat mencatat transaksi beli/jual saham
- [ ] **US-8.4**: User dapat menambah saham ke watchlist dengan target harga
- [ ] **US-8.5**: Sistem menampilkangrafik performa portofolio saham
- [ ] **US-8.6**: User dapat melihat nilai portofolio saham di dashboard

### 8.4 Technical Tasks

- [ ] **T-8.1**: Setup database tables for stock portfolio
- [ ] **T-8.2**: Integrate stock price API (e.g., Indonesia Stock Exchange API, Yahoo Finance)
- [ ] **T-8.3**: Implement portfolio calculation logic (average buy, P/L, ROI)
- [ ] **T-8.4**: Build stock portfolio UI with real-time prices
- [ ] **T-8.5**: Create stock transaction form with fee/tax calculation
- [ ] **T-8.6**: Implement watchlist with price alert feature
- [ ] **T-8.7**: Build stock performance charts (line chart, pie chart by sector)
- [ ] **T-8.8**: Add push notification for watchlist alerts

---

## 9. Statistics & Analytics (Statistik)

### 9.1 Chart Types

| Chart | Purpose | Data Source |
|-------|---------|-------------|
| Line Chart | Cash flow trend | Transactions (monthly) |
| Bar Chart | Income vs Expense | Transactions (monthly) |
| Pie Chart | Expense by category | Transactions (monthly) |
| Donut Chart | Asset allocation | Financial accounts |
| Area Chart | Net worth over time | Accounts + Portfolio |
| Stacked Bar | Investment vs Savings | Monthly aggregated |

### 9.2 Predefined Reports

- [ ] Monthly income report
- [ ] Monthly expense report
- [ ] Category breakdown report
- [ ] Cash flow analysis
- [ ] Net worth statement
- [ ] Investment performance report
- [ ] Savings goal progress report
- [ ] Year-to-date summary

### 9.3 Technical Tasks

- [ ] **T-9.1**: Implement aggregation queries for chart data
- [ ] **T-9.2**: Build reusable chart components (Recharts/Chart.js)
- [ ] **T-9.3**: Create export functionality (PDF, Excel, CSV)
- [ ] **T-9.4**: Implement date range filter for reports
- [ ] **T-9.5**: Build comparison mode (current vs previous period)
- [ ] **T-9.6**: Add drill-down functionality on charts

---

## 10. Security & Privacy (Keamanan)

### 10.1 Authentication Features

| Feature | Priority | Description |
|---------|----------|-------------|
| Email Login | P0 | Email + password authentication |
| Google OAuth | P0 | Google sign-in integration |
| PIN Lock | P1 | 4-6 digit PIN for app access |
| Biometric | P1 | Fingerprint/Face ID authentication |
| Session Timeout | P0 | Auto-logout after inactivity |

### 10.2 Data Security

- [ ] **T-10.1**: Implement JWT with refresh token rotation
- [ ] **T-10.2**: Add rate limiting on auth endpoints
- [ ] **T-10.3**: Encrypt sensitive data at rest (AES-256)
- [ ] **T-10.4**: Implement 2FA option for high-security users
- [ ] **T-10.5**: Add audit logging for sensitive actions
- [ ] **T-10.6**: Implement data export/delete (GDPR compliance)
- [ ] **T-10.7**: Add PIN hashing and verification
- [ ] **T-10.8**: Implement biometric authentication via native APIs

### 10.3 User Stories

- [ ] **US-10.1**: User dapat login dengan email dan password
- [ ] **US-10.2**: User dapat login dengan akun Google
- [ ] **US-10.3**: User dapat mengatur PIN untuk keamanan tambahan
- [ ] **US-10.4**: User dapat menggunakan biometric (sidik jari) untuk login
- [ ] **US-10.5**: App otomatis logout setelah 5 menit tidak aktif

---

## 11. Settings & Preferences

### 11.1 User Preferences


UserPreferences {
  user_id: UUID (FK)
  currency: String (default: "IDR")
  language: String (default: "id-ID")
  theme: Enum ("light", "dark", "system")
  date_format: String (default: "DD/MM/YYYY")
  first_day_of_week: Enum ("sunday", "monday")
  notifications_enabled: Boolean
  biometric_enabled: Boolean
  pin_enabled: Boolean
  auto_sync: Boolean
  sync_frequency: Enum ("realtime", "hourly", "daily")
}


### 11.2 Technical Tasks

- [ ] **T-11.1**: Build settings screen UI
- [ ] **T-11.2**: Implement theme switching (light/dark)
- [ ] **T-11.3**: Add language support (i18n)
- [ ] **T-11.4**: Create notification preferences
- [ ] **T-11.5**: Implement data backup/restore
- [ ] **T-11.6**: Build account management (change password, delete account)

---

## 12. Testing & Quality Assurance

### 12.1 Test Coverage Requirements

| Category | Coverage Target | Tools |
|----------|-----------------|-------|
| Unit Tests | 80% | Jest, React Testing Library |
| Integration Tests | 60% | Supertest, Detox |
| E2E Tests | Critical flows | Cypress, Appium |
| Performance | <2s load time | Lighthouse, k6 |
| Security | No critical vulns | OWASP ZAP, Snyk |

### 12.2 Test Scenarios

#### Authentication
- [ ] TC-12.1: Login with valid email/password
- [ ] TC-12.2: Login with Google OAuth
- [ ] TC-12.3: Login with wrong password (show error)
- [ ] TC-12.4: PIN authentication flow
- [ ] TC-12.5: Biometric authentication
- [ ] TC-12.6: Session timeout after inactivity

#### Transactions
- [ ] TC-12.7: Add income transaction
- [ ] TC-12.8: Add expense transaction with category
- [ ] TC-12.9: Edit existing transaction
- [ ] TC-12.10: Delete transaction with confirmation
- [ ] TC-12.11: Upload receipt image

#### Portfolio
- [ ] TC-12.12: Add stock to portfolio
- [ ] TC-12.13: Record buy transaction
- [ ] TC-12.14: Calculate average buy correctly
- [ ] TC-12.15: Calculate P/L accurately

### 12.3 Performance Benchmarks

- [ ] First Contentful Paint: <1.5s
- [ ] Time to Interactive: <3s
- [ ] Lighthouse Score: >90
- [ ] API Response Time: <200ms
- [ ] Offline capability: 100% core features

---

## 13. Deployment & DevOps

### 13.1 Environments

| Environment | Purpose | URL |
|-------------|---------|-----|
| Development | Local development | localhost:3000 |
| Staging | Pre-production testing | staging.fintrack.app |
| Production | Live application | app.fintrack.app |
| API | Backend services | api.fintrack.app |

### 13.2 CI/CD Pipeline

yaml
# GitHub Actions Workflow
stages:
  - lint: ESLint, Prettier checks
  - test: Unit & Integration tests
  - build: Docker image build
  - e2e: Cypress E2E tests
  - deploy-staging: Auto-deploy to staging
  - deploy-production: Manual approval required


### 13.3 Infrastructure


Production Architecture:
├── CDN (CloudFlare)
│   ├── Static Assets
│   └── API Gateway
├── Frontend (Vercel/Netlify)
│   └── React PWA
├── Backend (AWS ECS/Railway)
│   ├── API Service
│   ├── WebSocket Server
│   └── Worker Service
├── Database (Supabase/PostgreSQL)
│   ├── Primary DB
│   └── Read Replicas
├── Cache (Redis)
│   ├── Session Store
│   └── API Cache
├── Storage (S3/R2)
│   ├── User Uploads
│   └── Backups
└── Monitoring (Sentry, Datadog)


### 13.4 Technical Tasks

- [ ] **T-13.1**: Setup CI/CD with GitHub Actions
- [ ] **T-13.2**: Configure staging environment
- [ ] **T-13.3**: Setup production infrastructure
- [ ] **T-13.4**: Implement monitoring and alerting
- [ ] **T-13.5**: Setup automated database backups
- [ ] **T-13.6**: Configure CDN for static assets
- [ ] **T-13.7**: Implement disaster recovery plan

---

## 14. Post-MVP Roadmap

### Phase 2 Features (v2.0)

- [ ] Bill reminder/recurring transactions
- [ ] Split bill feature
- [ ] Investment calculator (SIP, CAGR)
- [ ] Multiple currency support
- [ ] Export to accounting software
- [ ] Collaboration features (family accounts)

### Phase 3 Features (v3.0)

- [ ] AI-powered financial insights
- [ ] Investment recommendations
- [ ] Budget planning with ML
- [ ] Tax preparation reports
- [ ] Multi-language support
- [ ] Desktop application

---

## Appendix A: Priority Matrix

| Priority | Criteria | Features |
|----------|----------|----------|
| P0 (Critical) | MVP, revenue blocker | Auth, Dashboard, Transactions, Accounts |
| P1 (High) | Core experience | Savings goals, Basic stats, Stock portfolio |
| P2 (Medium) | Enhanced UX | Charts, Export, Advanced stats |
| P3 (Low) | Nice-to-have | AI insights, Recommendations |

---

## Appendix B: Definition of Done

A task is considered complete when:
- [ ] Code is written and follows style guide
- [ ] Unit tests written and passing (>80% coverage)
- [ ] Integration with related modules verified
- [ ] UI matches design specifications
- [ ] Responsive design tested (mobile, tablet, desktop)
- [ ] Accessibility compliance (WCAG 2.1 AA)
- [ ] Security review completed
- [ ] Documentation updated
- [ ] Code reviewed and approved
- [ ] Deployed to staging environment

---

*End of TASKS.md - Part 3 of 3*

**Total Tasks: ~95 tasks across 14 sections**
**Estimated Development Time: 16-20 weeks (MVP: 8-10 weeks)**



