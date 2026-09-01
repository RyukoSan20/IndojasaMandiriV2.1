# FinTrack Design Document

**Version:** 1.0  
**Date:** 2024  
**Status:** Draft  

---

## Part 1: Product Overview & Vision

### 1. Introduction

FinTrack is a comprehensive personal finance and stock portfolio tracking application designed to consolidate all aspects of personal financial management into a single, intuitive platform. This document outlines the complete design specification for the FinTrack application, covering product vision, technical architecture, UI/UX design, data models, and implementation guidelines.

This design document is organized into three parts:

- **Part 1:** Product Overview & Vision
- **Part 2:** Technical Architecture & Data Models
- **Part 3:** UI/UX Design & Implementation Guidelines

---

### 2. Product Vision

FinTrack embodies the philosophy that financial literacy should be accessible to everyone. The application serves as a personal financial companion that transforms complex financial data into actionable insights, empowering users to make informed decisions about their money.

**Core Values:**

- **Simplicity First:** Complex financial operations presented through intuitive interfaces
- **Privacy by Design:** User data remains encrypted and under user control
- **Offline-First:** Full functionality without internet dependency
- **Insight-Driven:** Automated analysis providing meaningful financial understanding

**Design Philosophy:**

The application follows a "calm technology" approach, providing users with the information they need precisely when they need it, without overwhelming them with data. Visual hierarchy guides users naturally through financial information, while subtle animations provide feedback without distraction.

---

### 3. Target Users

FinTrack serves a diverse demographic of individuals seeking to improve their financial literacy and management capabilities.

| User Segment | Characteristics | Primary Needs |
|--------------|-----------------|---------------|
| Students | Limited income, learning financial basics | Simple tracking, expense categorization, savings goals |
| Fresh Graduates | New income sources, student loans | Budget management, spending awareness, emergency fund tracking |
| Employees | Regular income, employer benefits | Multi-account management, investment tracking, tax preparation support |
| Freelancers | Variable income, irregular expenses | Invoice tracking, tax estimation, cash flow management |
| Beginner Investors | Interest in stock market | Portfolio tracking, watchlist, basic analytics |
| Retail Investors | Active portfolio management | Advanced metrics, performance analysis, dividend tracking |

---

### 4. Core Features Overview

#### 4.1 Dashboard Module

The dashboard serves as the central hub for financial overview, presenting key metrics and insights at a glance.

**Components:**

- **Financial Summary Cards:** Display total balance, monthly income, monthly expenses, and total savings
- **Portfolio Overview:** Real-time stock portfolio value with daily change indicators
- **Cash Flow Chart:** Visual representation of income versus expenses over selectable time periods
- **Net Worth Trend:** Historical net worth tracking with projection capabilities
- **Quick Actions:** One-tap access to common operations (add income, add expense, transfer)
- **AI Insights Panel:** Automated recommendations and financial health indicators

#### 4.2 Transaction Management

Comprehensive transaction handling with smart categorization and receipt management.

**Capabilities:**

- Income and expense recording with customizable categories
- Recurring transaction support (daily, weekly, monthly, yearly)
- Split transactions for multi-category entries
- Receipt photo attachment with OCR extraction
- Batch import from CSV/Excel formats
- Duplicate transaction detection

#### 4.3 Account Management

Multi-account financial tracking supporting various account types.

**Supported Account Types:**

- Cash (physical currency)
- Bank accounts (checking, savings)
- E-Wallets (digital payment platforms)
- Investment accounts (brokerage)
- Credit cards (with liability tracking)

#### 4.4 Savings Goals

Target-based savings with progress tracking and milestone notifications.

**Goal Types:**

- Emergency fund accumulation
- Purchase-based goals (vacation, vehicle, electronics)
- Custom savings targets with flexible parameters
- Milestone celebrations and progress reminders

#### 4.5 Stock Portfolio

Investment tracking with performance analytics and watchlist management.

**Features:**

- Holdings management with transaction history
- Average cost basis calculation
- Profit/loss tracking (realized and unrealized)
- Dividend tracking and reinvestment planning
- Portfolio allocation visualization
- Watchlist for market monitoring

#### 4.6 Statistics & Analytics

Comprehensive reporting with visual representations of financial data.

**Report Types:**

- Spending analysis by category and time period
- Income trends and patterns
- Asset allocation breakdown
- Investment performance metrics
- Net worth progression over time

---

### 5. User Experience Principles

#### 5.1 Navigation Architecture

FinTrack employs a bottom-tab navigation pattern optimized for mobile-first interaction:


┌─────────────────────────────────────────┐
│              App Bar                    │
├─────────────────────────────────────────┤
│                                         │
│                                         │
│           Main Content Area             │
│                                         │
│                                         │
├─────────────────────────────────────────┤
│  [Dashboard] [Transactions] [Accounts] │
│  [Portfolio] [Stats]      [Settings]   │
└─────────────────────────────────────────┘


#### 5.2 Interaction Patterns

**Gestures:**

- Swipe left on transactions: Edit
- Swipe right on transactions: Delete
- Pull to refresh: Sync data
- Long press: Quick actions menu
- Pinch: Zoom charts

**Feedback Systems:**

- Haptic feedback on critical actions
- Toast notifications for async operations
- Progress indicators for data loading
- Success/error state illustrations

#### 5.3 Accessibility Standards

- Minimum touch target size: 48x48dp
- Color contrast ratio: 4.5:1 minimum
- Screen reader compatibility for all interactive elements
- Scalable text supporting system font size preferences
- Motion reduction option for animations

---

*End of Part 1*



# FinTrack - Technical Design (Part 2)

## Technical Architecture

### Technology Stack

#### Frontend (Mobile-First PWA)
- **Framework**: Flutter 3.x with Dart
- **State Management**: flutter_bloc (BLoC pattern)
- **Local Storage**: Hive (offline-first NoSQL database)
- **HTTP Client**: Dio with interceptors
- **Charts**: fl_chart for data visualization
- **Image Processing**: image_picker for receipt scanning

#### Backend (Cloud Sync)
- **Runtime**: Node.js 18+ with TypeScript
- **Framework**: NestJS (modular architecture)
- **Database**: PostgreSQL with Prisma ORM
- **Cache**: Redis for session management
- **Auth**: JWT with refresh token rotation
- **API Style**: RESTful with JSON responses

#### Infrastructure
- **Hosting**: Cloud Run (Google Cloud)
- **Database**: Cloud SQL (PostgreSQL)
- **Storage**: Cloud Storage for receipt images
- **CDN**: Cloud CDN for static assets
- **Monitoring**: Cloud Logging + Error Reporting

### Project Structure


fintrack/
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   ├── errors/
│   │   ├── themes/
│   │   └── utils/
│   ├── data/
│   │   ├── datasources/
│   │   ├── models/
│   │   └── repositories/
│   ├── domain/
│   │   ├── entities/
│   │   ├── repositories/
│   │   └── usecases/
│   ├── presentation/
│   │   ├── blocs/
│   │   ├── pages/
│   │   └── widgets/
│   └── main.dart
├── assets/
│   ├── icons/
│   └── images/
└── test/


## Design System

### Color Palette

#### Light Theme

Primary:        #2563EB (Blue 600)
Primary Dark:   #1D4ED8 (Blue 700)
Secondary:      #10B981 (Emerald 500)
Accent:         #F59E0B (Amber 500)
Background:     #FFFFFF (White)
Surface:        #F8FAFC (Slate 50)
Text Primary:   #1E293B (Slate 800)
Text Secondary: #64748B (Slate 500)
Success:        #22C55E (Green 500)
Warning:        #EAB308 (Yellow 500)
Error:          #EF4444 (Red 500)
Income:         #10B981 (Green)
Expense:        #EF4444 (Red)


#### Dark Theme

Primary:        #3B82F6 (Blue 500)
Primary Dark:   #2563EB (Blue 600)
Secondary:      #34D399 (Emerald 400)
Accent:         #FBBF24 (Amber 400)
Background:     #0F172A (Slate 900)
Surface:        #1E293B (Slate 800)
Text Primary:   #F8FAFC (Slate 50)
Text Secondary: #94A3B8 (Slate 400)


### Typography


Font Family: Inter (Google Fonts)

Headings:
  H1: 32px / Bold / Line Height 1.2
  H2: 24px / SemiBold / Line Height 1.3
  H3: 20px / SemiBold / Line Height 1.4
  H4: 16px / Medium / Line Height 1.4

Body:
  Large:  16px / Regular / Line Height 1.5
  Medium: 14px / Regular / Line Height 1.5
  Small:  12px / Regular / Line Height 1.4

Numbers (Currency):
  Large:  28px / Bold / Tabular nums
  Medium: 20px / SemiBold / Tabular nums
  Small:  16px / Medium / Tabular nums


### Spacing System (8pt Grid)


xs:   4px
sm:   8px
md:  16px
lg:  24px
xl:  32px
2xl: 48px

Border Radius:
  sm:   4px
  md:   8px
  lg:  12px
  xl:  16px
  full: 9999px


### Component Specifications

#### Cards
- Background: Surface color
- Border Radius: 12px
- Padding: 16px
- Shadow: 0 1px 3px rgba(0,0,0,0.1)
- Shadow (Dark): 0 1px 3px rgba(0,0,0,0.3)

#### Buttons

Primary:
  Background: Primary color
  Text: White
  Height: 48px
  Border Radius: 12px
  Pressed: Primary Dark
  Disabled: 50% opacity

Secondary:
  Background: Transparent
  Border: 1px Primary
  Text: Primary
  Height: 48px
  Border Radius: 12px


#### Input Fields
- Height: 56px
- Border: 1px Slate 300
- Border (Focused): 2px Primary
- Border Radius: 12px
- Label: Above field, 12px, Slate 500
- Padding: 16px horizontal

## Data Models

### User
dart
class User {
  String id;
  String email;
  String? name;
  String? avatarUrl;
  String currency; // IDR, USD
  String language; // id, en
  bool darkMode;
  DateTime createdAt;
  DateTime updatedAt;
}


### Account (Akun Keuangan)
dart
class Account {
  String id;
  String userId;
  String name;
  AccountType type; // cash, bank, ewallet, savings, investment
  double balance;
  String currency;
  String? icon;
  String? color;
  bool isActive;
  DateTime createdAt;
  DateTime updatedAt;
}


### Transaction (Transaksi)
dart
class Transaction {
  String id;
  String userId;
  String? accountId;
  TransactionType type; // income, expense, transfer
  double amount;
  String category;
  String? description;
  DateTime date;
  String? receiptUrl;
  List<String>? tags;
  DateTime createdAt;
  DateTime updatedAt;
}


### Savings Target (Target Tabungan)
dart
class SavingsTarget {
  String id;
  String userId;
  String name;
  double targetAmount;
  double currentAmount;
  DateTime? deadline;
  String? icon;
  String? color;
  bool isCompleted;
  DateTime createdAt;
  DateTime updatedAt;
}


### Stock Portfolio (Portofolio Saham)
dart
class StockHolding {
  String id;
  String userId;
  String symbol; // AAPL, BBCA
  String companyName;
  double shares;
  double averagePrice;
  double currentPrice;
  String currency;
  DateTime createdAt;
  DateTime updatedAt;
}


### Watchlist
dart
class WatchlistItem {
  String id;
  String userId;
  String symbol;
  double? targetPrice;
  String? notes;
  DateTime addedAt;
}


## State Management (BLoC)

### Blocs Required


AuthBloc          - Authentication state
DashboardBloc     - Dashboard data aggregation
AccountsBloc      - Account CRUD operations
TransactionsBloc  - Transaction management
SavingsBloc       - Savings targets
PortfolioBloc     - Stock holdings
WatchlistBloc     - Watchlist management
SettingsBloc      - User preferences
SyncBloc          - Offline/online sync status


### Events & States Pattern

dart
// Example: TransactionsBloc
abstract class TransactionsEvent {}
class LoadTransactions extends TransactionsEvent {}
class AddTransaction extends TransactionsEvent {}
class UpdateTransaction extends TransactionsEvent {}
class DeleteTransaction extends TransactionsEvent {}
class FilterTransactions extends TransactionsEvent {}

abstract class TransactionsState {}
class TransactionsInitial extends TransactionsState {}
class TransactionsLoading extends TransactionsState {}
class TransactionsLoaded extends TransactionsState {}
class TransactionsError extends TransactionsState {}


## Offline-First Architecture

### Sync Strategy

1. **Local-First**: All operations write to Hive first
2. **Queue System**: Pending changes queued in local storage
3. **Background Sync**: Service runs when connectivity restored
4. **Conflict Resolution**: Last-write-wins with timestamp comparison
5. **Sync Status**: Real-time indicator in UI

### Sync Flow

User Action → Hive Write → UI Update → Queue Sync
                                          ↓
                              Network Available?
                            ↓ Yes           ↓ No
                        Push to Server  Wait for Network
                            ↓
                     Server Response
                            ↓
                  Mark as Synced / Handle Conflict




# FinTrack - Design Document (Part 3)

## 8. Keamanan & Autentikasi

### 8.1 Metode Autentikasi

FinTrack menyediakan tiga metode autentikasi untuk keamanan akun pengguna:

**Email Login**
- Registrasi dengan email dan password
- Password harus minimal 8 karakter dengan kombinasi huruf besar, huruf kecil, angka, dan simbol
- Password di-hash menggunakan bcrypt dengan salt rounds 12
- Token reset password dikirim via email dengan expiry 1 jam

**Google OAuth Login**
- Integrasi dengan Google Identity Services
- Mendapatkan email, profile, dan avatar dari Google account
- OAuth 2.0 dengan PKCE untuk keamanan tambahan
- Token refresh otomatis untuk session management

**Two-Factor Authentication (2FA)**
- PIN 6 digit untuk verifikasi tambahan
- Biometric authentication menggunakan Face ID atau Fingerprint
- PIN dapat diubah kapan saja melalui settings
- Biometric memerlukan persetujuan explisit pengguna

### 8.2 Keamanan Data

**Enkripsi**
- Data sensitif di-enkripsi menggunakan AES-256-GCM
- Encryption key dikelola terpisah dari data
- HTTPS-only untuk semua komunikasi API
- Certificate pinning untuk aplikasi mobile

**Session Management**
- JWT access token dengan expiry 15 menit
- Refresh token dengan expiry 7 hari
- Auto-logout setelah 30 menit tidak aktif
- Single device login dapat diaktifkan opsional

**Privacy & Compliance**
- Data tidak dijual ke pihak ketiga
- User consent diperlukan untuk data collection
- Right to delete account dan data tersimpan
- GDPR compliant untuk pengguna EU

## 9. Arsitektur Backend

### 9.1 API Design

RESTful API dengan JSON response menggunakan protocol berikut:

**Base URL**

https://api.fintrack.app/v1


**Authentication Endpoints**

POST /auth/register        - Registrasi pengguna baru
POST /auth/login           - Login dengan email/password
POST /auth/google          - Login dengan Google OAuth
POST /auth/refresh         - Refresh access token
POST /auth/logout          - Logout dan invalidate token
POST /auth/forgot-password - Request reset password
POST /auth/reset-password  - Reset password dengan token


**Account Endpoints**

GET    /accounts           - List semua akun
POST   /accounts           - Tambah akun baru
GET    /accounts/:id       - Detail akun
PUT    /accounts/:id       - Update akun
DELETE /accounts/:id       - Hapus akun
GET    /accounts/:id/balance - Get saldo akun


**Transaction Endpoints**

GET    /transactions                - List transaksi (paginated)
POST   /transactions                - Tambah transaksi
GET    /transactions/:id            - Detail transaksi
PUT    /transactions/:id            - Update transaksi
DELETE /transactions/:id            - Hapus transaksi
GET    /transactions/export         - Export transaksi CSV/PDF
POST   /transactions/upload-receipt - Upload struk


**Category Endpoints**

GET    /categories          - List kategori
POST   /categories         - Tambah kategori
PUT    /categories/:id     - Update kategori
DELETE /categories/:id     - Hapus kategori


**Goals Endpoints**

GET    /goals           - List target tabungan
POST   /goals           - Tambah target
GET    /goals/:id       - Detail target
PUT    /goals/:id       - Update target
DELETE /goals/:id       - Hapus target
POST   /goals/:id/contribution - Add kontribusi


**Portfolio Endpoints**

GET    /portfolio            - Get portofolio saham
POST   /portfolio/buy        - Tambah pembelian saham
POST   /portfolio/sell       - Record penjualan saham
GET    /portfolio/performance - Get performa portofolio
GET    /portfolio/history    - Get history transaksi saham


**Watchlist Endpoints**

GET    /watchlist            - List watchlist
POST   /watchlist            - Tambah ke watchlist
DELETE /watchlist/:symbol    - Hapus dari watchlist


**Dashboard Endpoints**

GET    /dashboard/summary    - Get ringkasan dashboard
GET    /dashboard/cashflow   - Get data cashflow chart
GET    /dashboard/networth   - Get data net worth chart
GET    /dashboard/insights   - Get financial insights


**Statistics Endpoints**

GET    /stats/spending       - Get statistik pengeluaran
GET    /stats/income         - Get statistik pendapatan
GET    /stats/categories     - Get statistik per kategori
GET    /stats/assets         - Get statistik aset


### 9.2 Response Format

**Success Response**
json
{
  "success": true,
  "data": { ... },
  "meta": {
    "page": 1,
    "per_page": 20,
    "total": 100
  }
}


**Error Response**
json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input data",
    "details": [
      { "field": "amount", "message": "Amount must be positive" }
    ]
  }
}


## 10. Database Schema

### 10.1 Core Entities

**users**
| Column | Type | Constraints |
|--------|------|-------------|
| id | UUID | PK |
| email | VARCHAR(255) | UNIQUE, NOT NULL |
| password_hash | VARCHAR(255) | NULL |
| google_id | VARCHAR(255) | UNIQUE, NULL |
| name | VARCHAR(100) | NOT NULL |
| pin_hash | VARCHAR(255) | NULL |
| biometric_enabled | BOOLEAN | DEFAULT FALSE |
| settings | JSONB | DEFAULT '{}' |
| created_at | TIMESTAMP | NOT NULL |
| updated_at | TIMESTAMP | NOT NULL |

**accounts**
| Column | Type | Constraints |
|--------|------|-------------|
| id | UUID | PK |
| user_id | UUID | FK -> users |
| name | VARCHAR(100) | NOT NULL |
| type | ENUM | kas, bank, ewallet, savings, investment |
| currency | VARCHAR(3) | DEFAULT 'IDR' |
| balance | DECIMAL(15,2) | DEFAULT 0 |
| icon | VARCHAR(50) | NULL |
| color | VARCHAR(7) | NULL |
| is_active | BOOLEAN | DEFAULT TRUE |
| created_at | TIMESTAMP | NOT NULL |
| updated_at | TIMESTAMP | NOT NULL |

**transactions**
| Column | Type | Constraints |
|--------|------|-------------|
| id | UUID | PK |
| user_id | UUID | FK -> users |
| account_id | UUID | FK -> accounts |
| category_id | UUID | FK -> categories |
| type | ENUM | income, expense |
| amount | DECIMAL(15,2) | NOT NULL |
| description | VARCHAR(255) | NULL |
| date | DATE | NOT NULL |
| receipt_url | VARCHAR(500) | NULL |
| created_at | TIMESTAMP | NOT NULL |
| updated_at | TIMESTAMP | NOT NULL |

**categories**
| Column | Type | Constraints |
|--------|------|-------------|
| id | UUID | PK |
| user_id | UUID | FK -> users (NULL untuk default) |
| name | VARCHAR(100) | NOT NULL |
| type | ENUM | income, expense |
| icon | VARCHAR(50) | NOT NULL |
| color | VARCHAR(7) | NOT NULL |
| is_default | BOOLEAN | DEFAULT FALSE |
| created_at | TIMESTAMP | NOT NULL |

**goals**
| Column | Type | Constraints |
|--------|------|-------------|
| id | UUID | PK |
| user_id | UUID | FK -> users |
| name | VARCHAR(100) | NOT NULL |
| target_amount | DECIMAL(15,2) | NOT NULL |
| current_amount | DECIMAL(15,2) | DEFAULT 0 |
| deadline | DATE | NULL |
| icon | VARCHAR(50) | NULL |
| color | VARCHAR(7) | NULL |
| status | ENUM | active, completed, cancelled |
| created_at | TIMESTAMP | NOT NULL |
| updated_at | TIMESTAMP | NOT NULL |

**stock_portfolios**
| Column | Type | Constraints |
|--------|------|-------------|
| id | UUID | PK |
| user_id | UUID | FK -> users |
| symbol | VARCHAR(10) | NOT NULL |
| company_name | VARCHAR(100) | NOT NULL |
| total_shares | DECIMAL(10,4) | NOT NULL |
| average_price | DECIMAL(15,2) | NOT NULL |
| created_at | TIMESTAMP | NOT NULL |
| updated_at | TIMESTAMP | NOT NULL |

**stock_transactions**
| Column | Type | Constraints |
|--------|------|-------------|
| id | UUID | PK |
| user_id | UUID | FK -> users |
| symbol | VARCHAR(10) | NOT NULL |
| type | ENUM | buy, sell |
| shares | DECIMAL(10,4) | NOT NULL |
| price | DECIMAL(15,2) | NOT NULL |
| total_amount | DECIMAL(15,2) | NOT NULL |
| date | DATE | NOT NULL |
| created_at | TIMESTAMP | NOT NULL |

**watchlists**
| Column | Type | Constraints |
|--------|------|-------------|
| id | UUID | PK |
| user_id | UUID | FK -> users |
| symbol | VARCHAR(10) | NOT NULL |
| created_at | TIMESTAMP | NOT NULL |

### 10.2 Indexes

sql
CREATE INDEX idx_transactions_user_date ON transactions(user_id, date);
CREATE INDEX idx_transactions_user_type ON transactions(user_id, type);
CREATE INDEX idx_accounts_user ON accounts(user_id);
CREATE INDEX idx_goals_user ON goals(user_id);
CREATE INDEX idx_portfolio_user ON stock_portfolios(user_id);
CREATE INDEX idx_watchlist_user ON watchlists(user_id);


## 11. Deployment & Infrastructure

### 11.1 Environment

**Development**
- Local development dengan Docker Compose
- PostgreSQL 15 untuk database
- Redis untuk caching dan session
- MinIO untuk object storage (receipts)

**Staging**
- Single server deployment
- Auto-scaling tidak diperlukan
- Manual deployment via CI/CD

**Production**
- Kubernetes cluster dengan 3 node
- PostgreSQL dengan read replica
- Redis cluster untuk high availability
- S3-compatible object storage
- CDN untuk static assets

### 11.2 CI/CD Pipeline

yaml
stages:
  - lint        # Code linting dan formatting
  - test        # Unit dan integration tests
  - build       # Build Docker images
  - deploy      # Deploy ke environment


### 11.3 Monitoring & Logging

- Application monitoring: Sentry
- Infrastructure monitoring: Prometheus + Grafana
- Log aggregation: ELK Stack
- Uptime monitoring: UptimeRobot
- Error alerting: Slack notifications

## 12. Roadmap Pengembangan

### Phase 1: MVP (Bulan 1-2)
- [x] Authentication (email, Google)
- [x] Dashboard dengan ringkasan
- [x] CRUD transaksi
- [x] CRUD akun keuangan
- [x] CRUD target tabungan
- [x] Portofolio saham dasar
- [x] Statistik dasar

### Phase 2: Enhanced Features (Bulan 3-4)
- [ ] Upload struk transaksi
- [ ] Grafik advanced
- [ ] PIN dan biometric lock
- [ ] Export laporan
- [ ] Notifikasi dan reminder

### Phase 3: Advanced Features (Bulan 5-6)
- [ ] Investment insights
- [ ] Budget planning
- [ ] Debt tracking
- [ ] Multiple currency
- [ ] Recurring transactions

### Phase 4: Ecosystem (Bulan 7+)
- [ ] Browser extension
- [ ] API public untuk developer
- [ ] Widget dashboard
- [ ] Multi-language support
- [ ] Investment advisory

## 13. Estimasi Tim & Resource

### Tim Development
- 1 Product Manager
- 1 UI/UX Designer
- 2 Backend Developers
- 2 Mobile Developers
- 1 QA Engineer

### Teknologi Stack
- Frontend: React Native, TailwindCSS
- Backend: Node.js, Express, PostgreSQL
- Infrastructure: AWS/GCP, Docker, Kubernetes
- Monitoring: Sentry, DataDog, Grafana

---

*Document Version: 1.0*
*Last Updated: $(date +%Y-%m-%d)*
*Status: Draft for Review*



