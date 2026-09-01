# FinTrack ERD - Part 1: Core Foundation

## Overview

Dokumen ini merupakan bagian pertama dari three-part ERD untuk aplikasi FinTrack. Bagian pertama mencakup **Core Foundation** yang terdiri dari entitas autentikasi, user profile, dan financial accounts.

---

## 1. Authentication & User Management

### 1.1 Users Table

sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255),
    full_name VARCHAR(255) NOT NULL,
    avatar_url VARCHAR(500),
    phone_number VARCHAR(20),
    date_of_birth DATE,
    timezone VARCHAR(50) DEFAULT 'Asia/Jakarta',
    locale VARCHAR(10) DEFAULT 'id_ID',
    
    -- Auth Provider
    auth_provider ENUM('email', 'google', 'apple') DEFAULT 'email',
    google_id VARCHAR(255) UNIQUE,
    apple_id VARCHAR(255) UNIQUE,
    
    -- Security
    pin_hash VARCHAR(255),
    biometric_enabled BOOLEAN DEFAULT FALSE,
    two_factor_enabled BOOLEAN DEFAULT FALSE,
    
    -- Status
    is_verified BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    is_premium BOOLEAN DEFAULT FALSE,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_login_at TIMESTAMP WITH TIME ZONE,
    deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_google_id ON users(google_id);
CREATE INDEX idx_users_apple_id ON users(apple_id);


### 1.2 User Sessions Table

sql
CREATE TABLE user_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Session Info
    session_token VARCHAR(500) UNIQUE NOT NULL,
    refresh_token VARCHAR(500),
    device_id VARCHAR(255),
    device_name VARCHAR(255),
    device_type VARCHAR(50), -- 'ios', 'android', 'web', 'desktop'
    browser VARCHAR(255),
    os VARCHAR(100),
    ip_address INET,
    
    -- Location
    location_country VARCHAR(100),
    location_city VARCHAR(100),
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE,
    last_activity_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_user_sessions_user_id ON user_sessions(user_id);
CREATE INDEX idx_user_sessions_token ON user_sessions(session_token);
CREATE INDEX idx_user_sessions_expires ON user_sessions(expires_at);


### 1.3 User Security Log Table

sql
CREATE TABLE user_security_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Event Details
    event_type VARCHAR(50) NOT NULL, -- 'login', 'logout', 'pin_set', 'pin_change', 'biometric_enable', 'password_change'
    auth_provider VARCHAR(20),
    status VARCHAR(20) NOT NULL, -- 'success', 'failed', 'pending'
    
    -- Device Info
    device_id VARCHAR(255),
    device_name VARCHAR(255),
    ip_address INET,
    user_agent TEXT,
    location_country VARCHAR(100),
    location_city VARCHAR(100),
    
    -- Additional Info
    failure_reason VARCHAR(255),
    metadata JSONB,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_security_logs_user_id ON user_security_logs(user_id);
CREATE INDEX idx_security_logs_created_at ON user_security_logs(created_at);
CREATE INDEX idx_security_logs_event_type ON user_security_logs(event_type);


### 1.4 User Preferences Table

sql
CREATE TABLE user_preferences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Appearance
    theme VARCHAR(20) DEFAULT 'system', -- 'light', 'dark', 'system'
    accent_color VARCHAR(20) DEFAULT '#4F46E5',
    
    -- Display
    currency_code VARCHAR(3) DEFAULT 'IDR',
    currency_symbol VARCHAR(10) DEFAULT 'Rp',
    date_format VARCHAR(20) DEFAULT 'DD/MM/YYYY',
    number_format VARCHAR(20) DEFAULT 'id-ID',
    decimal_places INTEGER DEFAULT 0,
    
    -- Notifications
    push_enabled BOOLEAN DEFAULT TRUE,
    email_enabled BOOLEAN DEFAULT TRUE,
    daily_reminder BOOLEAN DEFAULT TRUE,
    daily_reminder_time TIME DEFAULT '08:00',
    weekly_report BOOLEAN DEFAULT TRUE,
    budget_alert BOOLEAN DEFAULT TRUE,
    
    -- Privacy
    show_balance BOOLEAN DEFAULT TRUE,
    show_investment BOOLEAN DEFAULT TRUE,
    
    -- Data
    backup_enabled BOOLEAN DEFAULT TRUE,
    auto_sync BOOLEAN DEFAULT TRUE,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);


---

## 2. Financial Accounts

### 2.1 Accounts Table

sql
CREATE TABLE accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Basic Info
    name VARCHAR(255) NOT NULL,
    account_type VARCHAR(50) NOT NULL, -- 'cash', 'bank', 'e_wallet', 'savings', 'investment'
    icon VARCHAR(50) DEFAULT 'wallet',
    color VARCHAR(20) DEFAULT '#4F46E5',
    
    -- Financial Details
    balance DECIMAL(20, 4) DEFAULT 0,
    currency_code VARCHAR(3) DEFAULT 'IDR',
    initial_balance DECIMAL(20, 4) DEFAULT 0,
    
    -- Institution Info
    institution_name VARCHAR(255),
    institution_logo VARCHAR(500),
    account_number VARCHAR(100),
    bank_code VARCHAR(20),
    
    -- Account Specific
    interest_rate DECIMAL(5, 4), -- For savings accounts
    card_type VARCHAR(50), -- 'debit', 'credit'
    card_brand VARCHAR(50), -- 'visa', 'mastercard'
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    is_hidden BOOLEAN DEFAULT FALSE,
    is_default BOOLEAN DEFAULT FALSE,
    include_in_total BOOLEAN DEFAULT TRUE,
    
    -- Integration
    integration_type VARCHAR(50), -- 'manual', 'linked'
    last_synced_at TIMESTAMP WITH TIME ZONE,
    
    -- Notes
    notes TEXT,
    
    -- Sort Order
    sort_order INTEGER DEFAULT 0,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_accounts_user_id ON accounts(user_id);
CREATE INDEX idx_accounts_type ON accounts(account_type);
CREATE INDEX idx_accounts_user_type ON accounts(user_id, account_type);
CREATE INDEX idx_accounts_is_active ON accounts(is_active);


### 2.2 Account Types Reference Table

sql
CREATE TABLE account_types (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    name_en VARCHAR(100),
    icon VARCHAR(50),
    color VARCHAR(20),
    description TEXT,
    is_system BOOLEAN DEFAULT FALSE,
    
    -- Category
    category VARCHAR(50), -- 'asset', 'liability', 'cash', 'bank', 'digital'
    
    -- Features
    supports_interest BOOLEAN DEFAULT FALSE,
    supports_credit_limit BOOLEAN DEFAULT FALSE,
    supports_cards BOOLEAN DEFAULT FALSE,
    
    -- Display
    display_order INTEGER DEFAULT 0,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Default Account Types
INSERT INTO account_types (id, name, name_en, icon, color, category, is_system, supports_interest, display_order) VALUES
('cash', 'Tunai', 'Cash', 'banknotes', '#10B981', 'cash', TRUE, FALSE, 1),
('bank', 'Bank', 'Bank Account', 'building-columns', '#3B82F6', 'bank', TRUE, TRUE, 2),
('e_wallet', 'E-Wallet', 'E-Wallet', 'wallet', '#8B5CF6', 'digital', TRUE, FALSE, 3),
('savings', 'Tabungan', 'Savings', 'piggy-bank', '#F59E0B', 'bank', TRUE, TRUE, 4),
('investment', 'Investasi', 'Investment', 'chart-line', '#EC4899', 'asset', TRUE, FALSE, 5),
('credit', 'Kartu Kredit', 'Credit Card', 'credit-card', '#EF4444', 'liability', TRUE, TRUE, 6);


### 2.3 Account Balances History Table

sql
CREATE TABLE account_balance_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    
    -- Balance Data
    balance DECIMAL(20, 4) NOT NULL,
    balance_type VARCHAR(20) DEFAULT 'actual', -- 'actual', 'available', 'pending'
    
    -- Context
    changed_by VARCHAR(50), -- 'transaction', 'transfer', 'adjustment', 'sync', 'interest'
    related_transaction_id UUID,
    
    -- Timestamps
    recorded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    as_of_date DATE NOT NULL
);

CREATE INDEX idx_balance_history_account_id ON account_balance_history(account_id);
CREATE INDEX idx_balance_history_as_of_date ON account_balance_history(as_of_date);
CREATE INDEX idx_balance_history_account_date ON account_balance_history(account_id, as_of_date);


---

## Entity Relationship Diagram

plaintext
┌─────────────────────┐       ┌─────────────────────┐
│       users         │       │   user_sessions     │
├─────────────────────┤       ├─────────────────────┤
│ id (PK)             │───1:N─│ id (PK)             │
│ email               │       │ user_id (FK)        │
│ password_hash       │       │ session_token       │
│ full_name           │       │ refresh_token       │
│ auth_provider       │       │ device_id           │
│ is_active           │       │ is_active           │
│ created_at          │       │ created_at          │
└─────────────────────┘       │ expires_at          │
         │                    └─────────────────────┘
         │ 1:1
         ▼
┌─────────────────────┐       ┌─────────────────────────┐
│  user_preferences   │       │  user_security_logs     │
├─────────────────────┤       ├─────────────────────────┤
│ id (PK)             │       │ id (PK)                 │
│ user_id (FK, UNIQUE)│───1:N─│ user_id (FK)           │
│ theme               │       │ event_type              │
│ currency_code       │       │ status                  │
│ date_format         │       │ ip_address              │
│ push_enabled        │       │ created_at              │
└─────────────────────┘       └─────────────────────────┘

┌─────────────────────┐       ┌─────────────────────────┐
│     accounts        │       │   account_types         │
├─────────────────────┤       ├─────────────────────────┤
│ id (PK)             │───N:1─│ id (PK)                 │
│ user_id (FK)        │       │ name                    │
│ name                │       │ icon                    │
│ account_type (FK)   │       │ color                   │
│ balance             │       │ category                │
│ currency_code       │       │ is_system               │
│ institution_name    │       │ supports_interest       │
│ is_active           │       └─────────────────────────┘
│ created_at          │
└─────────────────────┘
         │
         │ 1:N
         ▼
┌─────────────────────────────┐
│  account_balance_history    │
├─────────────────────────────┤
│ id (PK)                     │
│ account_id (FK)             │
│ balance                     │
│ balance_type                │
│ changed_by                  │
│ recorded_at                 │
│ as_of_date                  │
└─────────────────────────────┘


---

## Relationships Summary

| Parent Entity | Child Entity | Relationship Type | Description |
|---------------|--------------|-------------------|-------------|
| users | user_sessions | 1:N | One user can have multiple sessions |
| users | user_preferences | 1:1 | One user has one preferences record |
| users | accounts | 1:N | One user can have multiple accounts |
| users | user_security_logs | 1:N | One user can have multiple security logs |
| account_types | accounts | 1:N | One account type can be used by multiple accounts |
| accounts | account_balance_history | 1:N | One account has many balance snapshots |

---

## Indexes Summary

| Table | Index Name | Columns | Type | Purpose |
|-------|------------|---------|------|---------|
| users | idx_users_email | email | B-tree | Fast email lookup |
| users | idx_users_google_id | google_id | B-tree | Google OAuth lookup |
| user_sessions | idx_user_sessions_user_id | user_id | B-tree | Get all sessions for user |
| user_sessions | idx_user_sessions_token | session_token | B-tree | Session validation |
| user_sessions | idx_user_sessions_expires | expires_at | B-tree | Session cleanup |
| user_security_logs | idx_security_logs_user_id | user_id | B-tree | Security audit by user |
| user_security_logs | idx_security_logs_created_at | created_at | B-tree | Time-based security queries |
| accounts | idx_accounts_user_id | user_id | B-tree | Get accounts by user |
| accounts | idx_accounts_type | account_type | B-tree | Filter by account type |
| accounts | idx_accounts_user_type | user_id, account_type | B-tree | Complex filtering |
| account_balance_history | idx_balance_history_account_id | account_id | B-tree | Balance history by account |
| account_balance_history | idx_balance_history_account_date | account_id, as_of_date | B-tree | Balance trends |

---

## Notes

1. **Soft Delete**: Users and accounts use soft delete pattern with `deleted_at` timestamp for data recovery and audit purposes.

2. **UUID Primary Keys**: All tables use UUID v4 for primary keys to ensure uniqueness across distributed systems.

3. **Timestamps**: All tables include `created_at` and `updated_at` for audit trail. `TIMESTAMP WITH TIME ZONE` is used for consistent timezone handling.

4. **Decimal Precision**: Balance and monetary values use `DECIMAL(20, 4)` to accommodate both small daily transactions and large investment values.

5. **Session Security**: Sessions include device information and IP for security monitoring and fraud detection.

6. **Balance History**: Automatic tracking of account balance changes enables accurate reporting and prevents data loss.

---

*Continue to Part 2: Transactions & Categories*



# FinTrack - Entity Relationship Diagram (Part 2)

## 2. Core Financial Entities

### 2.1 Financial Accounts (`accounts`)

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | UUID | PK, NOT NULL | Unique identifier |
| user_id | UUID | FK → users.id, NOT NULL, INDEX | Account owner |
| account_type_id | UUID | FK → account_types.id, NOT NULL | Type of account |
| name | VARCHAR(100) | NOT NULL | Account name (e.g., "Bank BCA", "GoPay") |
| balance | DECIMAL(18,2) | NOT NULL, DEFAULT 0, INDEX | Current balance |
| currency | VARCHAR(3) | NOT NULL, DEFAULT 'IDR' | Currency code (ISO 4217) |
| icon | VARCHAR(50) | NULL | Icon identifier |
| color | VARCHAR(7) | NULL | Hex color code (e.g., #FF5722) |
| is_active | BOOLEAN | NOT NULL, DEFAULT TRUE | Soft delete flag |
| include_in_total | BOOLEAN | NOT NULL, DEFAULT TRUE | Include in net worth calculation |
| sort_order | INT | NOT NULL, DEFAULT 0 | Display order |
| created_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Creation timestamp |
| updated_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Last update timestamp |

**Indexes:**
- `idx_accounts_user_id` on (user_id)
- `idx_accounts_type_id` on (account_type_id)
- `idx_accounts_balance` on (balance)

**Relationships:**
- 1 User → Many Accounts (user_id)
- 1 Account Type → Many Accounts (account_type_id)
- 1 Account → Many Transactions (as source_account_id)
- 1 Account → Many Transactions (as destination_account_id)

---

### 2.2 Account Types (`account_types`)

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | UUID | PK, NOT NULL | Unique identifier |
| code | VARCHAR(30) | NOT NULL, UNIQUE | Type code (e.g., "cash", "bank") |
| name | VARCHAR(50) | NOT NULL | Display name (e.g., "Kas", "Bank") |
| icon | VARCHAR(50) | NOT NULL | Icon identifier |
| color | VARCHAR(7) | NOT NULL | Default hex color |
| sort_order | INT | NOT NULL, DEFAULT 0 | Display order |
| created_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Creation timestamp |

**Default Values:**
sql
INSERT INTO account_types (code, name, icon, color, sort_order) VALUES
('cash', 'Kas', 'wallet', '#4CAF50', 1),
('bank', 'Bank', 'account-balance', '#2196F3', 2),
('ewallet', 'E-Wallet', 'mobile-friendly', '#FF9800', 3),
('savings', 'Tabungan', 'savings', '#9C27B0', 4),
('investment', 'Rekening Investasi', 'trending-up', '#00BCD4', 5);


---

### 2.3 Transactions (`transactions`)

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | UUID | PK, NOT NULL | Unique identifier |
| user_id | UUID | FK → users.id, NOT NULL, INDEX | Transaction owner |
| account_id | UUID | FK → accounts.id, NOT NULL, INDEX | Primary account |
| destination_account_id | UUID | FK → accounts.id, NULL | For transfers |
| transaction_type_id | UUID | FK → transaction_types.id, NOT NULL | Income/Expense/Transfer |
| category_id | UUID | FK → categories.id, NULL, INDEX | Transaction category |
| amount | DECIMAL(18,2) | NOT NULL, CHECK > 0 | Transaction amount |
| description | VARCHAR(255) | NULL | Transaction notes |
| transaction_date | DATE | NOT NULL, INDEX | Date of transaction |
| is_recurring | BOOLEAN | NOT NULL, DEFAULT FALSE | Recurring flag |
| recurring_id | UUID | FK → recurring_transactions.id, NULL | Recurring reference |
| receipt_url | VARCHAR(500) | NULL | Uploaded receipt path |
| tags | JSON | NULL | Array of tag strings |
| latitude | DECIMAL(10,8) | NULL | Location latitude |
| longitude | DECIMAL(11,8) | NULL | Location longitude |
| created_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Creation timestamp |
| updated_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Last update timestamp |

**Indexes:**
- `idx_transactions_user_date` on (user_id, transaction_date)
- `idx_transactions_account_date` on (account_id, transaction_date)
- `idx_transactions_category_date` on (category_id, transaction_date)
- `idx_transactions_type_date` on (transaction_type_id, transaction_date)

**Relationships:**
- 1 User → Many Transactions
- 1 Account → Many Transactions (as primary)
- 1 Account → Many Transactions (as destination for transfers)
- 1 Transaction Type → Many Transactions
- 1 Category → Many Transactions (optional)

**Business Rules:**
- For income/expense: only account_id is set
- For transfer: both account_id and destination_account_id are set
- Transfer creates two transaction records (debit and credit)

---

### 2.4 Transaction Types (`transaction_types`)

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | UUID | PK, NOT NULL | Unique identifier |
| code | VARCHAR(20) | NOT NULL, UNIQUE | Type code |
| name | VARCHAR(50) | NOT NULL | Display name |
| effect | ENUM | NOT NULL | 'debit', 'credit', 'transfer' |
| icon | VARCHAR(50) | NOT NULL | Icon identifier |
| color | VARCHAR(7) | NOT NULL | Hex color |
| created_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Creation timestamp |

**Default Values:**
sql
INSERT INTO transaction_types (code, name, effect, icon, color) VALUES
('income', 'Pemasukan', 'credit', 'arrow-downward', '#4CAF50'),
('expense', 'Pengeluaran', 'debit', 'arrow-upward', '#F44336'),
('transfer', 'Transfer', 'transfer', 'swap-horiz', '#2196F3');


---

### 2.5 Categories (`categories`)

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | UUID | PK, NOT NULL | Unique identifier |
| user_id | UUID | FK → users.id, NULL, INDEX | NULL = system category |
| transaction_type_id | UUID | FK → transaction_types.id, NOT NULL | Associated type |
| parent_id | UUID | FK → categories.id, NULL | Parent category for subcategories |
| name | VARCHAR(100) | NOT NULL | Category name |
| icon | VARCHAR(50) | NOT NULL | Icon identifier |
| color | VARCHAR(7) | NOT NULL | Hex color |
| budget_limit | DECIMAL(18,2) | NULL | Monthly budget limit |
| is_active | BOOLEAN | NOT NULL, DEFAULT TRUE | Active flag |
| sort_order | INT | NOT NULL, DEFAULT 0 | Display order |
| created_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Creation timestamp |
| updated_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Last update timestamp |

**Indexes:**
- `idx_categories_user_type` on (user_id, transaction_type_id)
- `idx_categories_parent` on (parent_id)

**Relationships:**
- 1 User → Many Categories (optional)
- 1 Transaction Type → Many Categories
- 1 Category → Many Subcategories (self-referential)
- 1 Category → Many Transactions

**System Categories (user_id = NULL):**
sql
-- Income Categories
('income', 'Gaji', 'payments', '#4CAF50'),
('income', 'Freelance', 'work', '#8BC34A'),
('income', 'Investasi', 'trending-up', '#CDDC39'),
('income', 'Hadiah', 'card-giftcard', '#FFEB3B'),
('income', 'Lainnya', 'more-horiz', '#FFC107');

-- Expense Categories
('expense', 'Makanan', 'restaurant', '#F44336'),
('expense', 'Transportasi', 'directions-car', '#E91E63'),
('expense', 'Belanja', 'shopping-cart', '#9C27B0'),
('expense', 'Kesehatan', 'medical-services', '#673AB7'),
('expense', 'Pendidikan', 'school', '#3F51B5'),
('expense', 'Hiburan', 'movie', '#2196F3'),
('expense', 'Tagihan', 'receipt', '#03A9F4'),
('expense', 'Pulsa & Data', 'sim', '#00BCD4'),
('expense', 'Kosmetik', 'face', '#009688'),
('expense', 'Donasi', 'volunteer', '#4CAF50'),
('expense', 'Lainnya', 'more-horiz', '#607D8B');


---

### 2.6 Receipts (`receipts`)

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | UUID | PK, NOT NULL | Unique identifier |
| user_id | UUID | FK → users.id, NOT NULL, INDEX | Receipt owner |
| transaction_id | UUID | FK → transactions.id, NULL | Associated transaction |
| original_filename | VARCHAR(255) | NOT NULL | Original upload filename |
| storage_path | VARCHAR(500) | NOT NULL | Cloud storage path |
| file_size | INT | NOT NULL | File size in bytes |
| mime_type | VARCHAR(100) | NOT NULL | MIME type |
| ocr_data | JSON | NULL | Extracted OCR data |
| ocr_confidence | DECIMAL(5,2) | NULL | OCR confidence score |
| processed_at | TIMESTAMP | NULL | OCR processing timestamp |
| created_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Upload timestamp |

**Indexes:**
- `idx_receipts_user_id` on (user_id)
- `idx_receipts_transaction_id` on (transaction_id)

**Relationships:**
- 1 User → Many Receipts
- 1 Transaction → Many Receipts (0..1)

---

### 2.7 Recurring Transactions (`recurring_transactions`)

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | UUID | PK, NOT NULL | Unique identifier |
| user_id | UUID | FK → users.id, NOT NULL, INDEX | Owner |
| account_id | UUID | FK → accounts.id, NOT NULL | Target account |
| destination_account_id | UUID | FK → accounts.id, NULL | For recurring transfers |
| transaction_type_id | UUID | FK → transaction_types.id, NOT NULL | Type |
| category_id | UUID | FK → categories.id, NULL | Category |
| amount | DECIMAL(18,2) | NOT NULL | Fixed amount |
| description | VARCHAR(255) | NULL | Notes |
| frequency | ENUM | NOT NULL | 'daily', 'weekly', 'biweekly', 'monthly', 'yearly' |
| day_of_week | INT | NULL | 0-6 for weekly (0=Sunday) |
| day_of_month | INT | NULL | 1-31 for monthly |
| start_date | DATE | NOT NULL | First occurrence |
| end_date | DATE | NULL | Last occurrence |
| next_run_date | DATE | NOT NULL, INDEX | Next scheduled execution |
| last_run_date | DATE | NULL | Last successful execution |
| is_active | BOOLEAN | NOT NULL, DEFAULT TRUE | Active flag |
| created_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Creation timestamp |
| updated_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Last update timestamp |

**Indexes:**
- `idx_recurring_next_run` on (next_run_date, is_active)

**Relationships:**
- 1 User → Many Recurring Transactions
- 1 Account → Many Recurring Transactions
- 1 Transaction Type → Many Recurring Transactions

---

## Entity Relationship Diagram (Partial)


┌─────────────────┐       ┌──────────────────┐
│   account_types │       │    users         │
├─────────────────┤       ├──────────────────┤
│ PK id           │       │ PK id            │
│    code         │       │    email         │
│    name         │       │    name          │
│    icon         │       │    ...           │
│    color        │       └────────┬─────────┘
└────────┬────────┘                │
         │ 1:N                    │ 1:N
         ▼                        ▼
┌─────────────────┐       ┌──────────────────┐
│    accounts     │       │   categories     │
├─────────────────┤       ├──────────────────┤
│ PK id           │       │ PK id           │
│ FK user_id ─────────────│ FK user_id      │
│ FK account_type_id───────│    name         │
│    name         │       │ FK transaction   │
│    balance      │       │   _type_id       │
│    currency     │       │ FK parent_id     │
│    ...          │       │    ...           │
└────────┬────────┘       └────────┬─────────┘
         │ 1:N                    │ 1:N
         │                        ▼
         │                ┌──────────────────┐
         │                │ transaction_types│
         │                ├──────────────────┤
         │                │ PK id           │
         │                │    code         │
         │                │    name         │
         │                │    effect       │
         │                │    ...          │
         │                └────────┬─────────┘
         │                         │ 1:N
         │  1:N      ┌─────────────┘
         ▼           │
┌─────────────────┐  │     ┌──────────────────┐
│  transactions   │◄─┘     │    receipts      │
├─────────────────┤        ├──────────────────┤
│ PK id           │        │ PK id           │
│ FK user_id      │        │ FK user_id      │
│ FK account_id   │────────│ FK transaction_id│
│ FK dest_acc_id  │        │    storage_path │
│ FK transaction  │        │    ocr_data     │
│   _type_id      │        │    ...          │
│ FK category_id  │        └─────────────────┘
│    amount       │
│    description  │
│    date         │
│    ...          │
└─────────────────┘

         ┌──────────────────┐
         │recurring_trans. │
         ├──────────────────┤
         │ PK id           │
         │ FK user_id      │
         │ FK account_id   │
         │ FK transaction  │
         │   _type_id      │
         │    frequency    │
         │    next_run     │
         │    ...          │
         └──────────────────┘




# FinTrack ERD - Part 3: Relasi & Implementasi

## 7. Relasi Antar Entitas

### 7.1 Diagram Relasi


┌─────────────┐       ┌─────────────────┐       ┌─────────────┐
│   User      │───────│   Account       │───────│ Transaction │
│             │  1:N  │                 │  1:N  │             │
└─────────────┘       └─────────────────┘       └─────────────┘
      │                                                 │
      │                  ┌─────────────────┐            │
      │                  │  Transaction    │◄───────────┘
      │                  │  Category       │
      │                  └─────────────────┘
      │                         │
      │  ┌──────────────────────┼──────────────────────┐
      │  │                      │                      │
      ▼  ▼                      ▼                      ▼
┌─────────────┐       ┌─────────────────┐       ┌─────────────┐
│  Savings    │       │    Stock        │       │   Stock     │
│  Goal       │       │  Portfolio      │       │  Watchlist  │
└─────────────┘       └─────────────────┘       └─────────────┘


### 7.2 Kardinalitas Relasi

| Entitas A        | Relasi | Entitas B          | Tipe      | Deskripsi                           |
|-------------------|--------|--------------------|-----------|-------------------------------------|
| User              | 1:N    | Account            | Mandatory | Satu user punya banyak akun         |
| User              | 1:N    | Transaction        | Mandatory | Satu user punya banyak transaksi    |
| User              | 1:N    | SavingsGoal        | Optional  | Satu user punya banyak target       |
| User              | 1:N    | StockPortfolio     | Optional  | Satu user punya banyak portofolio  |
| User              | 1:N    | StockWatchlist     | Optional  | Satu user punya banyak watchlist    |
| Account           | 1:N    | Transaction        | Mandatory | Satu akun punya banyak transaksi   |
| Category          | 1:N    | Transaction        | Mandatory | Satu kategori punya banyak transaksi|
| Stock             | 1:N    | StockPortfolio     | Mandatory | Satu saham punya banyak portofolio |
| Stock             | 1:N    | StockWatchlist     | Mandatory | Satu saham punya banyak watchlist   |
| User              | 1:1    | UserSettings       | Mandatory | Satu user punya satu pengaturan     |
| User              | 1:N    | Budget             | Optional  | Satu user punya banyak budget       |

## 8. Implementasi Database

### 8.1 PostgreSQL Schema (Primary)

sql
-- Users
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255),
    name VARCHAR(100) NOT NULL,
    pin_hash VARCHAR(255),
    biometric_enabled BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Accounts
CREATE TABLE accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    type VARCHAR(50) NOT NULL,
    balance DECIMAL(15,2) DEFAULT 0,
    currency VARCHAR(3) DEFAULT 'IDR',
    icon VARCHAR(50),
    color VARCHAR(7),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Categories
CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    type VARCHAR(20) NOT NULL,
    icon VARCHAR(50),
    color VARCHAR(7),
    is_system BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Transactions
CREATE TABLE transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    account_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
    amount DECIMAL(15,2) NOT NULL,
    type VARCHAR(20) NOT NULL,
    description TEXT,
    date DATE NOT NULL,
    receipt_url VARCHAR(500),
    tags TEXT[],
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Savings Goals
CREATE TABLE savings_goals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    target_amount DECIMAL(15,2) NOT NULL,
    current_amount DECIMAL(15,2) DEFAULT 0,
    deadline DATE,
    icon VARCHAR(50),
    color VARCHAR(7),
    is_completed BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Stocks
CREATE TABLE stocks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    symbol VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(200) NOT NULL,
    exchange VARCHAR(50),
    sector VARCHAR(100),
    last_price DECIMAL(15,4),
    last_updated TIMESTAMP
);

-- Stock Portfolio
CREATE TABLE stock_portfolios (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    stock_id UUID NOT NULL REFERENCES stocks(id) ON DELETE CASCADE,
    quantity DECIMAL(15,4) NOT NULL,
    average_price DECIMAL(15,4) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, stock_id)
);

-- Stock Transactions (Buy/Sell)
CREATE TABLE stock_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    portfolio_id UUID NOT NULL REFERENCES stock_portfolios(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(10) NOT NULL,
    quantity DECIMAL(15,4) NOT NULL,
    price DECIMAL(15,4) NOT NULL,
    fee DECIMAL(15,2) DEFAULT 0,
    date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Stock Watchlist
CREATE TABLE stock_watchlists (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    stock_id UUID NOT NULL REFERENCES stocks(id) ON DELETE CASCADE,
    target_price DECIMAL(15,4),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, stock_id)
);

-- User Settings
CREATE TABLE user_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    currency VARCHAR(3) DEFAULT 'IDR',
    theme VARCHAR(20) DEFAULT 'light',
    language VARCHAR(10) DEFAULT 'id',
    notifications_enabled BOOLEAN DEFAULT true,
    biometric_enabled BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_transactions_user_date ON transactions(user_id, date);
CREATE INDEX idx_transactions_account ON transactions(account_id);
CREATE INDEX idx_transactions_category ON transactions(category_id);
CREATE INDEX idx_stock_portfolios_user ON stock_portfolios(user_id);
CREATE INDEX idx_accounts_user ON accounts(user_id);


### 8.2 SQLite Schema (Offline/Mobile)

sql
-- Simplified schema for SQLite (mobile offline support)
CREATE TABLE users (
    id TEXT PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    password_hash TEXT,
    name TEXT NOT NULL,
    pin_hash TEXT,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
);

CREATE TABLE accounts (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    name TEXT NOT NULL,
    type TEXT NOT NULL,
    balance REAL DEFAULT 0,
    currency TEXT DEFAULT 'IDR',
    icon TEXT,
    color TEXT,
    is_active INTEGER DEFAULT 1,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE transactions (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    account_id TEXT NOT NULL,
    category_id TEXT,
    amount REAL NOT NULL,
    type TEXT NOT NULL,
    description TEXT,
    date INTEGER NOT NULL,
    receipt_url TEXT,
    tags TEXT,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (account_id) REFERENCES accounts(id)
);

CREATE TABLE categories (
    id TEXT PRIMARY KEY,
    user_id TEXT,
    name TEXT NOT NULL,
    type TEXT NOT NULL,
    icon TEXT,
    color TEXT,
    is_system INTEGER DEFAULT 0,
    created_at INTEGER NOT NULL
);

CREATE TABLE savings_goals (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    name TEXT NOT NULL,
    target_amount REAL NOT NULL,
    current_amount REAL DEFAULT 0,
    deadline INTEGER,
    icon TEXT,
    color TEXT,
    is_completed INTEGER DEFAULT 0,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE stock_portfolios (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    stock_id TEXT NOT NULL,
    symbol TEXT NOT NULL,
    quantity REAL NOT NULL,
    average_price REAL NOT NULL,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE stock_watchlists (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    stock_id TEXT NOT NULL,
    target_price REAL,
    notes TEXT,
    created_at INTEGER NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE user_settings (
    id TEXT PRIMARY KEY,
    user_id TEXT UNIQUE NOT NULL,
    currency TEXT DEFAULT 'IDR',
    theme TEXT DEFAULT 'light',
    language TEXT DEFAULT 'id',
    notifications_enabled INTEGER DEFAULT 1,
    biometric_enabled INTEGER DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES users(id)
);


## 9. Panduan Implementasi

### 9.1 Sync Strategy

javascript
// Sync conflict resolution
const syncStrategy = {
    transactions: 'server_wins',      // Transaksi keuangan: akurasi prioritas
    accounts: 'client_wins',          // Saldo: client lebih up-to-date
    portfolios: 'server_wins',        // Portofolio: harga dari server
    goals: 'merge',                   // Target: merge amount
    watchlists: 'client_wins'         // Watchlist: preferensi user
};


### 9.2 Offline-First Approach

1. **Local-first writes**: Semua operasi tulis dilakukan ke SQLite lokal
2. **Background sync**: Sinkronisasi ke server saat koneksi tersedia
3. **Conflict detection**: Gunakan timestamp + version vector
4. **Rollback support**: Simpan history perubahan untuk rollback

### 9.3 Security Considerations

1. **Authentication**: JWT dengan refresh token
2. **Encryption**: AES-256 untuk data sensitif di lokal
3. **PIN/Biometric**: Untuk akses aplikasi
4. **Audit log**: Catat semua perubahan data

## 10. Kesimpulan

ERD ini menyediakan fondasi database yang komprehensif untuk aplikasi FinTrack dengan dukungan:

- Multi-device sync
- Offline-first capability
- Scalable untuk fitur tambahan
- Secure dan compliant

Untuk implementasi, disarankan untuk memulai dengan PostgreSQL sebagai primary database dan SQLite untuk offline support pada mobile app.

---

*Generated: FinTrack ERD Documentation*
*Version: 1.0.0*



