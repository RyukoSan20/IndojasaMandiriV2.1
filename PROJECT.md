# FinTrack - Project Specification

## Part 1: Project Overview & Vision

---

## 1. Introduction

FinTrack is a comprehensive Personal Finance and Stock Portfolio Tracker designed to help users manage their personal finances, savings goals, and stock investments within a single, unified platform. The application prioritizes simplicity, speed, and ease of use while providing powerful financial insights.

The name "FinTrack" combines "Financial" and "Track," reflecting the core purpose: enabling users to track, manage, and understand their financial health with minimal friction.

---

## 2. Product Vision

FinTrack envisions a world where everyone—regardless of financial literacy level—can take control of their money. The application serves as a personal financial companion that:

- **Simplifies Complexity**: Transforms complicated financial data into clear, actionable insights
- **Encourages Good Habits**: Makes budgeting and saving feel rewarding rather than restrictive
- **Builds Financial Awareness**: Helps users understand where their money goes and how to grow it
- **Democratizes Investment**: Lowers barriers to entry for stock market participation

The guiding principle is: *"Financial freedom starts with awareness, and awareness starts with FinTrack."*

---

## 3. Core Objectives

### Primary Goals

1. **Expense & Income Tracking**
   - Enable users to record daily income and expenses effortlessly
   - Provide real-time financial status visibility
   - Support multiple transaction categories and tagging

2. **Savings Management**
   - Help users set and track financial goals
   - Visualize progress toward savings targets
   - Motivate consistent saving behavior

3. **Account Management**
   - Consolidate multiple financial accounts in one place
   - Support diverse account types (cash, bank, e-wallet, investments)
   - Calculate total net worth automatically

4. **Investment Tracking**
   - Monitor stock portfolio performance
   - Calculate profit/loss and average buy prices
   - Track investment returns over time

5. **Financial Insights**
   - Generate automatic financial insights
   - Identify spending patterns
   - Suggest improvement opportunities

---

## 4. Target Users

### Primary User Segments

| User Segment | Description | Key Needs |
|--------------|-------------|-----------|
| **Students** | University/college students managing allowance or part-time income | Simple budgeting, expense tracking, learning financial basics |
| **Fresh Graduates** | New workforce members starting financial independence | Budget management, emergency fund setup, basic investment knowledge |
| **Employees** | Working professionals with regular income | Multi-account management, savings goals, comprehensive tracking |
| **Freelancers** | Self-employed individuals with variable income | Income tracking, tax preparation support, irregular expense management |
| **Beginner Investors** | Individuals starting their investment journey | Portfolio tracking, profit/loss calculation, watchlist management |
| **Retail Investors** | Active investors managing personal portfolios | Advanced portfolio analytics, multiple holdings tracking |

### User Personas

**Persona 1: Maya (23, Fresh Graduate)**
- Just started working, earning first salary
- Wants to track expenses to avoid overspending
- Saving for emergency fund and first car
- Has a bank account and e-wallet

**Persona 2: Bagus (28, Freelance Designer)**
- Variable monthly income
- Needs to separate business and personal expenses
- Interested in starting stock investment
- Uses multiple payment methods

**Persona 3: Sari (35, Marketing Manager)**
- Established career with stable income
- Has multiple investments including stocks
- Focused on long-term wealth building
- Values detailed analytics and reporting

---

## 5. MVP Scope

### Phase 1: Minimum Viable Product

The MVP focuses on essential features that deliver immediate value to users.

#### Included in MVP

1. **Authentication System**
   - Email/password registration and login
   - Google OAuth integration
   - PIN code protection
   - Biometric authentication (fingerprint/face)

2. **Dashboard**
   - Total balance overview
   - Monthly income summary
   - Monthly expense summary
   - Total savings amount
   - Stock portfolio value
   - Cashflow trend chart
   - Net worth chart
   - Automated financial insights

3. **Transaction Management**
   - Add income transactions
   - Add expense transactions
   - Edit existing transactions
   - Delete transactions
   - Categorize transactions
   - Receipt/struk upload functionality

4. **Financial Accounts**
   - Cash account
   - Bank account
   - E-Wallet account
   - Savings account
   - Investment account

5. **Savings Goals**
   - Emergency fund goal
   - Vacation fund goal
   - Custom savings targets
   - Progress tracking with visual indicators

6. **Stock Portfolio**
   - Portfolio holdings list
   - Add/remove holdings
   - Average buy price calculation
   - Profit/loss calculation
   - Return on investment (ROI) tracking
   - Performance chart

7. **Basic Statistics**
   - Expense breakdown by category
   - Income vs expense comparison
   - Category-wise spending analysis

#### Excluded from MVP (Phase 2+)

- Advanced investment analytics
- Bill reminders and notifications
- Budget limits and alerts
- Export to PDF/Excel
- Multiple currencies
- Investment recommendations
- Tax report generation
- Investment news integration

---

## 6. Success Metrics

### Key Performance Indicators

| Metric | Target | Measurement |
|--------|--------|-------------|
| App Load Time | < 2 seconds | Time to interactive |
| User Retention (Day 1) | > 60% | DAU/MAU ratio |
| User Retention (Day 7) | > 40% | Users returning after 1 week |
| Transaction Completion | > 90% | Successful transaction recording |
| Dashboard Loading | < 1 second | Initial data load time |
| Offline Capability | 100% core features | App usability without internet |

---

## 7. Technical Constraints

### Platform Requirements

- **Primary Platform**: Mobile (iOS & Android)
- **Design Approach**: Mobile-first, responsive
- **Offline Support**: Full functionality without internet
- **Cloud Sync**: Automatic data synchronization
- **Data Storage**: Secure, encrypted local and cloud storage

### Security Requirements

- End-to-end encryption for sensitive data
- Secure authentication with token-based sessions
- Biometric data never leaves the device
- Compliance with data protection regulations

---

*End of Part 1: Project Overview & Vision*



# FinTrack - Bagian 2: Arsitektur Teknis

## Tech Stack

### Frontend Mobile
- **Framework**: React Native 0.76+
- **Language**: TypeScript 5.x
- **State Management**: Zustand
- **Navigation**: React Navigation 6
- **UI Components**: React Native Paper
- **Charts**: Victory Native
- **Storage**: AsyncStorage + WatermelonDB

### Backend API
- **Runtime**: Node.js 20 LTS
- **Framework**: Express.js
- **Language**: TypeScript 5.x
- **Database**: PostgreSQL 16
- **ORM**: Prisma
- **Cache**: Redis
- **Auth**: JWT + Firebase Auth

### Infrastructure
- **Cloud**: Google Cloud Platform
- **Container**: Docker
- **CI/CD**: GitHub Actions
- **Monitoring**: Cloud Logging + Sentry

## Database Schema

### Users

users
├── id (UUID, PK)
├── email (VARCHAR, UNIQUE)
├── password_hash (VARCHAR)
├── name (VARCHAR)
├── avatar_url (VARCHAR)
├── pin_hash (VARCHAR)
├── biometric_enabled (BOOLEAN)
├── created_at (TIMESTAMP)
└── updated_at (TIMESTAMP)


### Financial Accounts

accounts
├── id (UUID, PK)
├── user_id (UUID, FK → users)
├── name (VARCHAR)
├── type (ENUM: cash, bank, ewallet, savings, investment)
├── balance (DECIMAL)
├── currency (VARCHAR)
├── icon (VARCHAR)
├── color (VARCHAR)
├── is_active (BOOLEAN)
├── created_at (TIMESTAMP)
└── updated_at (TIMESTAMP)


### Transactions

transactions
├── id (UUID, PK)
├── user_id (UUID, FK → users)
├── account_id (UUID, FK → accounts)
├── type (ENUM: income, expense, transfer)
├── amount (DECIMAL)
├── category (VARCHAR)
├── description (TEXT)
├── date (DATE)
├── receipt_url (VARCHAR)
├── created_at (TIMESTAMP)
└── updated_at (TIMESTAMP)


### Savings Goals

savings_goals
├── id (UUID, PK)
├── user_id (UUID, FK → users)
├── name (VARCHAR)
├── target_amount (DECIMAL)
├── current_amount (DECIMAL)
├── deadline (DATE)
├── icon (VARCHAR)
├── color (VARCHAR)
├── status (ENUM: active, completed, cancelled)
├── created_at (TIMESTAMP)
└── updated_at (TIMESTAMP)


### Stock Portfolio

portfolios
├── id (UUID, PK)
├── user_id (UUID, FK → users)
├── symbol (VARCHAR)
├── company_name (VARCHAR)
├── quantity (DECIMAL)
├── average_price (DECIMAL)
├── current_price (DECIMAL)
├── sector (VARCHAR)
├── created_at (TIMESTAMP)
└── updated_at (TIMESTAMP)


### Stock Watchlist

watchlists
├── id (UUID, PK)
├── user_id (UUID, FK → users)
├── symbol (VARCHAR)
├── target_price (DECIMAL)
├── alert_enabled (BOOLEAN)
├── created_at (TIMESTAMP)
└── updated_at (TIMESTAMP)


### Categories

categories
├── id (UUID, PK)
├── user_id (UUID, FK → users, NULLABLE)
├── name (VARCHAR)
├── type (ENUM: income, expense)
├── icon (VARCHAR)
├── color (VARCHAR)
├── is_system (BOOLEAN)
├── parent_id (UUID, FK → categories, NULLABLE)
├── created_at (TIMESTAMP)
└── updated_at (TIMESTAMP)


## API Endpoints

### Authentication

POST   /api/auth/register
POST   /api/auth/login
POST   /api/auth/logout
POST   /api/auth/refresh
POST   /api/auth/forgot-password
POST   /api/auth/reset-password
POST   /api/auth/verify-email
POST   /api/auth/set-pin
POST   /api/auth/verify-pin


### Users

GET    /api/users/me
PUT    /api/users/me
PUT    /api/users/me/avatar
PUT    /api/users/me/password
PUT    /api/users/me/pin
PUT    /api/users/me/biometric
DELETE /api/users/me


### Accounts

GET    /api/accounts
POST   /api/accounts
GET    /api/accounts/:id
PUT    /api/accounts/:id
DELETE /api/accounts/:id
GET    /api/accounts/:id/balance
PUT    /api/accounts/:id/balance


### Transactions

GET    /api/transactions
POST   /api/transactions
GET    /api/transactions/:id
PUT    /api/transactions/:id
DELETE /api/transactions/:id
POST   /api/transactions/transfer
POST   /api/transactions/upload-receipt
GET    /api/transactions/export


### Categories

GET    /api/categories
POST   /api/categories
PUT    /api/categories/:id
DELETE /api/categories/:id


### Savings Goals

GET    /api/savings-goals
POST   /api/savings-goals
GET    /api/savings-goals/:id
PUT    /api/savings-goals/:id
DELETE /api/savings-goals/:id
POST   /api/savings-goals/:id/contribute


### Portfolio

GET    /api/portfolio
POST   /api/portfolio
GET    /api/portfolio/:id
PUT    /api/portfolio/:id
DELETE /api/portfolio/:id
POST   /api/portfolio/buy
POST   /api/portfolio/sell
GET    /api/portfolio/summary
GET    /api/portfolio/performance


### Watchlist

GET    /api/watchlist
POST   /api/watchlist
DELETE /api/watchlist/:id
PUT    /api/watchlist/:id


### Dashboard

GET    /api/dashboard/summary
GET    /api/dashboard/cashflow
GET    /api/dashboard/networth
GET    /api/dashboard/insights


### Statistics

GET    /api/stats/expenses
GET    /api/stats/income
GET    /api/stats/categories
GET    /api/stats/assets
GET    /api/stats/investments


## Data Models (TypeScript)

### User Model
typescript
interface User {
  id: string;
  email: string;
  name: string;
  avatarUrl?: string;
  pinEnabled: boolean;
  biometricEnabled: boolean;
  createdAt: Date;
  updatedAt: Date;
}


### Account Model
typescript
interface Account {
  id: string;
  userId: string;
  name: string;
  type: AccountType;
  balance: number;
  currency: string;
  icon: string;
  color: string;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}

type AccountType = 'cash' | 'bank' | 'ewallet' | 'savings' | 'investment';


### Transaction Model
typescript
interface Transaction {
  id: string;
  userId: string;
  accountId: string;
  type: TransactionType;
  amount: number;
  category: string;
  description: string;
  date: Date;
  receiptUrl?: string;
  createdAt: Date;
  updatedAt: Date;
}

type TransactionType = 'income' | 'expense' | 'transfer';


### SavingsGoal Model
typescript
interface SavingsGoal {
  id: string;
  userId: string;
  name: string;
  targetAmount: number;
  currentAmount: number;
  deadline: Date;
  icon: string;
  color: string;
  status: GoalStatus;
  progress: number;
  createdAt: Date;
  updatedAt: Date;
}

type GoalStatus = 'active' | 'completed' | 'cancelled';


### Portfolio Model
typescript
interface Portfolio {
  id: string;
  userId: string;
  symbol: string;
  companyName: string;
  quantity: number;
  averagePrice: number;
  currentPrice: number;
  sector: string;
  totalValue: number;
  profitLoss: number;
  profitLossPercent: number;
  returnPercent: number;
  createdAt: Date;
  updatedAt: Date;
}


## Security Implementation

### Authentication Flow
1. User registers/logs in via email or Google
2. Server validates credentials
3. JWT access token (15min) + refresh token (7 days) issued
4. Access token stored in memory
5. Refresh token stored in HttpOnly cookie

### PIN Security
1. User sets 6-digit PIN after registration
2. PIN hashed with bcrypt (salt rounds: 12)
3. PIN verified on sensitive operations
4. 5 failed attempts = 30min lockout

### Biometric Authentication
1. Face ID / Fingerprint registered via device
2. Biometric assertion sent to server
3. Server validates with Firebase Auth
4. Session token issued on success

### Data Encryption
- HTTPS/TLS 1.3 for all connections
- AES-256 for sensitive local storage
- Database encryption at rest
- Backup encryption with user-specific keys

## Offline Support Architecture

### Local Database (WatermelonDB)
- Full offline read capability
- Queue writes for sync
- Conflict resolution with last-write-wins
- Sync status indicator

### Sync Strategy
1. On app open: fetch delta changes
2. On connectivity restore: push queued changes
3. Background sync every 5 minutes
4. Manual sync button available
5. Conflict detection and resolution

## State Management (Zustand)

### Stores
typescript
// authStore - authentication state
// accountStore - financial accounts
// transactionStore - transactions
// savingsStore - savings goals
// portfolioStore - stock portfolio
// watchlistStore - stock watchlist
// categoryStore - transaction categories
// settingsStore - user preferences
// syncStore - sync status


### Persistence
- Auth state: AsyncStorage (memory only)
- User data: WatermelonDB (local SQLite)
- Settings: AsyncStorage (persistent)



# FinTrack - Technical Architecture & Implementation

## Technology Stack

### Frontend
- **Framework**: React Native with Expo
- **Language**: TypeScript
- **State Management**: Zustand
- **Navigation**: React Navigation v6
- **UI Components**: React Native Paper
- **Charts**: react-native-gifted-charts
- **Storage**: AsyncStorage + SQLite

### Backend
- **Runtime**: Node.js 18+
- **Framework**: Express.js
- **Database**: PostgreSQL
- **ORM**: Prisma
- **Authentication**: JWT + Firebase Auth
- **File Storage**: Cloudinary
- **Cache**: Redis

### Infrastructure
- **Hosting**: AWS / Vercel
- **CI/CD**: GitHub Actions
- **Monitoring**: Sentry
- **Analytics**: Firebase Analytics

---

## Database Schema

### Users

id              UUID PRIMARY KEY
email           VARCHAR(255) UNIQUE
password_hash   VARCHAR(255)
name            VARCHAR(100)
pin_hash        VARCHAR(255)
created_at      TIMESTAMP
updated_at      TIMESTAMP


### Accounts

id              UUID PRIMARY KEY
user_id         UUID REFERENCES users
name            VARCHAR(100)
type            ENUM('cash', 'bank', 'e-wallet', 'savings', 'investment')
balance         DECIMAL(15,2)
currency        VARCHAR(3)
icon            VARCHAR(50)
color           VARCHAR(7)
is_active       BOOLEAN
created_at      TIMESTAMP
updated_at      TIMESTAMP


### Transactions

id              UUID PRIMARY KEY
user_id         UUID REFERENCES users
account_id      UUID REFERENCES accounts
category_id     UUID REFERENCES categories
amount          DECIMAL(15,2)
type            ENUM('income', 'expense')
description     VARCHAR(255)
date            DATE
receipt_url     VARCHAR(500)
created_at      TIMESTAMP
updated_at      TIMESTAMP


### Categories

id              UUID PRIMARY KEY
user_id         UUID REFERENCES users
name            VARCHAR(100)
type            ENUM('income', 'expense')
icon            VARCHAR(50)
color           VARCHAR(7)
parent_id       UUID REFERENCES categories
is_default      BOOLEAN


### Savings Goals

id              UUID PRIMARY KEY
user_id         UUID REFERENCES users
name            VARCHAR(100)
target_amount   DECIMAL(15,2)
current_amount  DECIMAL(15,2)
deadline        DATE
icon            VARCHAR(50)
color           VARCHAR(7)
status          ENUM('active', 'completed', 'cancelled')
created_at      TIMESTAMP


### Stock Portfolios

id              UUID PRIMARY KEY
user_id         UUID REFERENCES users
symbol          VARCHAR(10)
company_name    VARCHAR(100)
quantity        DECIMAL(15,4)
average_price   DECIMAL(15,2)
current_price   DECIMAL(15,2)
sector          VARCHAR(50)
created_at      TIMESTAMP
updated_at      TIMESTAMP


### Stock Watchlist

id              UUID PRIMARY KEY
user_id         UUID REFERENCES users
symbol          VARCHAR(10)
target_price    DECIMAL(15,2)
notes           TEXT
created_at      TIMESTAMP


---

## API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login with email/password
- `POST /api/auth/google` - Login with Google
- `POST /api/auth/refresh` - Refresh JWT token
- `POST /api/auth/pin` - Set/verify PIN
- `POST /api/auth/logout` - Logout user

### Accounts
- `GET /api/accounts` - List all accounts
- `POST /api/accounts` - Create account
- `GET /api/accounts/:id` - Get account details
- `PUT /api/accounts/:id` - Update account
- `DELETE /api/accounts/:id` - Delete account
- `GET /api/accounts/:id/balance` - Get account balance

### Transactions
- `GET /api/transactions` - List transactions (with filters)
- `POST /api/transactions` - Create transaction
- `GET /api/transactions/:id` - Get transaction details
- `PUT /api/transactions/:id` - Update transaction
- `DELETE /api/transactions/:id` - Delete transaction
- `POST /api/transactions/upload-receipt` - Upload receipt image

### Categories
- `GET /api/categories` - List categories
- `POST /api/categories` - Create category
- `PUT /api/categories/:id` - Update category
- `DELETE /api/categories/:id` - Delete category

### Savings Goals
- `GET /api/goals` - List all goals
- `POST /api/goals` - Create goal
- `GET /api/goals/:id` - Get goal details
- `PUT /api/goals/:id` - Update goal
- `DELETE /api/goals/:id` - Delete goal
- `POST /api/goals/:id/contribute` - Add contribution

### Stock Portfolio
- `GET /api/portfolio` - Get portfolio summary
- `POST /api/portfolio` - Add stock position
- `PUT /api/portfolio/:id` - Update position
- `DELETE /api/portfolio/:id` - Remove position
- `GET /api/portfolio/performance` - Get performance metrics
- `GET /api/portfolio/summary` - Get portfolio summary

### Watchlist
- `GET /api/watchlist` - Get watchlist
- `POST /api/watchlist` - Add to watchlist
- `DELETE /api/watchlist/:id` - Remove from watchlist

### Statistics
- `GET /api/stats/overview` - Financial overview
- `GET /api/stats/cashflow` - Cashflow data
- `GET /api/stats/categories` - Category breakdown
- `GET /api/stats/assets` - Asset allocation

### Sync
- `POST /api/sync` - Sync local data to cloud
- `GET /api/sync/last` - Get last sync timestamp

---

## Security Implementation

### Authentication Flow
1. User registers or logs in
2. Server validates credentials
3. JWT access token (15min) issued
4. Refresh token (7 days) stored in httpOnly cookie
5. Biometric/PIN for quick access on app

### Data Encryption
- Passwords: bcrypt with salt rounds 12
- PIN: SHA-256 hash
- Data at rest: AES-256 encryption
- Data in transit: TLS 1.3

### Session Management
- JWT tokens with short expiry
- Automatic refresh before expiry
- Force logout on password change
- Device tracking for anomalies

---

## Deployment Strategy

### Development
- Local development with Expo
- SQLite for local database
- Mock APIs for testing

### Staging
- Vercel preview deployments
- PostgreSQL test database
- Full feature parity with production

### Production
- Auto-deployment from main branch
- PostgreSQL with read replicas
- Redis for caching and sessions
- Cloudflare CDN for assets
- Automated backups daily

### Mobile Release
- TestFlight for iOS beta
- Internal testing channel for Android
- Staged rollout on production stores

---

## Development Timeline

### Phase 1: Foundation (4 weeks)
- Project setup and architecture
- Authentication system
- Basic UI components
- Local database setup

### Phase 2: Core Features (6 weeks)
- Dashboard implementation
- Account management
- Transaction CRUD
- Category management

### Phase 3: Savings & Goals (3 weeks)
- Savings goal tracking
- Progress visualization
- Notifications system

### Phase 4: Stock Portfolio (4 weeks)
- Portfolio tracking
- Stock API integration
- Performance calculations
- Watchlist feature

### Phase 5: Analytics (3 weeks)
- Statistics dashboard
- Charts and visualizations
- Financial insights

### Phase 6: Polish (2 weeks)
- Offline support
- Cloud sync
- Performance optimization
- Bug fixes

---

## Performance Targets

- App launch: < 2 seconds
- Screen transitions: < 300ms
- API response: < 500ms
- Offline capability: Full CRUD operations
- Battery impact: Minimal background usage
- Storage efficiency: < 100MB app size

---

## Accessibility

- WCAG 2.1 AA compliance
- Screen reader support
- High contrast mode
- Adjustable text sizes
- Keyboard navigation
- Color blind friendly charts

---

## Future Roadmap

### v2.0
- Multiple currencies
- Budget planning
- Bill reminders
- Investment news feed

### v2.1
- Family sharing
- Collaborative goals
- Export to Excel/PDF
- Tax report generation

### v3.0
- Cryptocurrency tracking
- Real estate valuation
- Debt tracking
- AI-powered insights



