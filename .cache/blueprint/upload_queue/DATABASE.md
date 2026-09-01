# FinTrack Database Documentation

## 1. Introduction

Dokumentasi ini menjelaskan desain basis data untuk aplikasi FinTrack - Personal Finance dan Stock Portfolio Tracker. Database ini dirancang untuk mendukung semua fitur utama aplikasi termasuk manajemen transaksi, akun keuangan, target tabungan, dan portofolio saham.

### 1.1 Design Principles

- **Normalized Structure**: Mengikuti aturan normalisasi hingga 3NF untuk menghindari redundansi data
- **Scalability**: Dirancang untuk mendukung growth data pengguna secara horizontal
- **Performance**: Indexing yang optimal untuk query yang sering dilakukan
- **Security**: Enkripsi untuk data sensitif, audit trail untuk aktivitas kritis

### 1.2 Database Type

**Primary Database**: PostgreSQL 15+
- Robust ACID compliance untuk integritas transaksi finansial
- JSON support untuk flexible schema pada metadata
- Full-text search capability untuk fitur pencarian

**Cache Layer**: Redis 7+
- Session management
- Real-time data caching
- Rate limiting

**File Storage**: S3-compatible storage
- Image storage untuk upload struk
- Export data files
- Backup archives

---

## 2. Entity Relationship Diagram (ERD) Overview


┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│    USERS    │────<│  ACCOUNTS   │────<│ TRANSACTIONS│
└─────────────┘     └─────────────┘     └─────────────┘
       │                   │                    │
       │                   │                    │
       ▼                   ▼                    ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   SESSIONS  │     │   TARGETS   │     │ CATEGORIES  │
└─────────────┘     └─────────────┘     └─────────────┘
                           │
                           ▼
                   ┌─────────────┐
                   │ INVESTMENTS │
                   │ (STOCKS)    │
                   └─────────────┘


---

## 3. Core Tables Schema

### 3.1 Users Table

Tabel utama untuk menyimpan informasi pengguna aplikasi.

sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255),
    full_name VARCHAR(255) NOT NULL,
    avatar_url TEXT,
    phone_number VARCHAR(20),
    date_of_birth DATE,
    pin_hash VARCHAR(255),
    biometric_enabled BOOLEAN DEFAULT FALSE,
    biometric_public_key TEXT,
    timezone VARCHAR(50) DEFAULT 'Asia/Jakarta',
    locale VARCHAR(10) DEFAULT 'id_ID',
    theme VARCHAR(10) DEFAULT 'light' CHECK (theme IN ('light', 'dark', 'system')),
    email_verified BOOLEAN DEFAULT FALSE,
    email_verified_at TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT TRUE,
    is_premium BOOLEAN DEFAULT FALSE,
    premium_expires_at TIMESTAMP WITH TIME ZONE,
    last_login_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_users_email ON users(email) WHERE deleted_at IS NULL;
CREATE INDEX idx_users_phone ON users(phone_number) WHERE deleted_at IS NULL;
CREATE INDEX idx_users_created_at ON users(created_at DESC);


### 3.2 User Auth Providers Table

Mendukung multiple authentication methods per user.

sql
CREATE TABLE auth_providers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    provider VARCHAR(20) NOT NULL CHECK (provider IN ('email', 'google', 'apple')),
    provider_user_id VARCHAR(255) NOT NULL,
    provider_access_token TEXT,
    provider_refresh_token TEXT,
    provider_token_expires_at TIMESTAMP WITH TIME ZONE,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(provider, provider_user_id),
    UNIQUE(user_id, provider)
);

CREATE INDEX idx_auth_providers_user_id ON auth_providers(user_id);
CREATE INDEX idx_auth_providers_provider ON auth_providers(provider, provider_user_id);


### 3.3 Sessions Table

sql
CREATE TABLE sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    session_token VARCHAR(255) UNIQUE NOT NULL,
    refresh_token VARCHAR(255) UNIQUE NOT NULL,
    device_info JSONB DEFAULT '{}',
    ip_address INET,
    user_agent TEXT,
    last_active_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_revoked BOOLEAN DEFAULT FALSE
);

CREATE INDEX idx_sessions_user_id ON sessions(user_id);
CREATE INDEX idx_sessions_token ON sessions(session_token) WHERE is_revoked = FALSE;
CREATE INDEX idx_sessions_refresh ON sessions(refresh_token) WHERE is_revoked = FALSE;
CREATE INDEX idx_sessions_expires ON sessions(expires_at) WHERE is_revoked = FALSE;


### 3.4 User Settings Table

sql
CREATE TABLE user_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE UNIQUE,
    currency_code VARCHAR(3) DEFAULT 'IDR',
    currency_symbol VARCHAR(10) DEFAULT 'Rp',
    date_format VARCHAR(20) DEFAULT 'DD/MM/YYYY',
    first_day_of_week SMALLINT DEFAULT 1 CHECK (first_day_of_week BETWEEN 0 AND 6),
    decimal_separator VARCHAR(2) DEFAULT ',',
    thousand_separator VARCHAR(2) DEFAULT '.',
    default_account_id UUID,
    enable_notifications BOOLEAN DEFAULT TRUE,
    enable_email_reports BOOLEAN DEFAULT FALSE,
    report_frequency VARCHAR(20) DEFAULT 'weekly',
    low_balance_alert BOOLEAN DEFAULT TRUE,
    low_balance_threshold DECIMAL(15, 2) DEFAULT 500000,
    budget_alert_percentage INTEGER DEFAULT 80,
    investment_alert_percentage INTEGER DEFAULT 10,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_user_settings_user_id ON user_settings(user_id);




# FinTrack Database Schema - Part 2

## 9. Stock Watchlist Table

sql
CREATE TABLE stock_watchlist (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    symbol VARCHAR(20) NOT NULL,
    name VARCHAR(255) NOT NULL,
    exchange VARCHAR(50),
    sector VARCHAR(100),
    current_price DECIMAL(15, 4),
    target_price DECIMAL(15, 4),
    notes TEXT,
    alert_enabled BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, symbol)
);


## 10. Stock Transaction Table

sql
CREATE TABLE stock_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    portfolio_id UUID NOT NULL REFERENCES stock_portfolios(id) ON DELETE CASCADE,
    transaction_type VARCHAR(10) NOT NULL CHECK (transaction_type IN ('BUY', 'SELL', 'DIVIDEND')),
    symbol VARCHAR(20) NOT NULL,
    name VARCHAR(255),
    quantity DECIMAL(15, 4) NOT NULL,
    price_per_share DECIMAL(15, 4) NOT NULL,
    total_amount DECIMAL(15, 2) NOT NULL,
    commission DECIMAL(15, 2) DEFAULT 0,
    transaction_date DATE NOT NULL,
    exchange VARCHAR(50),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


## 11. Categories Table

sql
CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    type VARCHAR(20) NOT NULL CHECK (type IN ('income', 'expense', 'transfer')),
    icon VARCHAR(50),
    color VARCHAR(7) DEFAULT '#6366F1',
    is_system BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, name, type)
);

-- Seed default expense categories
INSERT INTO categories (id, name, type, icon, color, is_system) VALUES
    (gen_random_uuid(), 'Makanan', 'expense', 'utensils', '#EF4444', true),
    (gen_random_uuid(), 'Transportasi', 'expense', 'car', '#F59E0B', true),
    (gen_random_uuid(), 'Belanja', 'expense', 'shopping-bag', '#10B981', true),
    (gen_random_uuid(), 'Hiburan', 'expense', 'film', '#8B5CF6', true),
    (gen_random_uuid(), 'Kesehatan', 'expense', 'heart', '#EC4899', true),
    (gen_random_uuid(), 'Pendidikan', 'expense', 'book', '#06B6D4', true),
    (gen_random_uuid(), 'Tagihan', 'expense', 'file-text', '#6366F1', true),
    (gen_random_uuid(), 'Lainnya', 'expense', 'more-horizontal', '#94A3B8', true);

-- Seed default income categories
INSERT INTO categories (id, name, type, icon, color, is_system) VALUES
    (gen_random_uuid(), 'Gaji', 'income', 'briefcase', '#10B981', true),
    (gen_random_uuid(), 'Freelance', 'income', 'laptop', '#F59E0B', true),
    (gen_random_uuid(), 'Investasi', 'income', 'trending-up', '#6366F1', true),
    (gen_random_uuid(), 'Hadiah', 'income', 'gift', '#EC4899', true),
    (gen_random_uuid(), 'Lainnya', 'income', 'plus-circle', '#94A3B8', true);


## 12. Savings Goals Table

sql
CREATE TABLE savings_goals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    target_amount DECIMAL(15, 2) NOT NULL,
    current_amount DECIMAL(15, 2) DEFAULT 0,
    deadline DATE,
    icon VARCHAR(50),
    color VARCHAR(7) DEFAULT '#6366F1',
    priority INTEGER DEFAULT 1,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'completed', 'cancelled')),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


## 13. Budgets Table

sql
CREATE TABLE budgets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    category_id UUID NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
    amount DECIMAL(15, 2) NOT NULL,
    period VARCHAR(20) DEFAULT 'monthly' CHECK (period IN ('weekly', 'monthly', 'yearly')),
    start_date DATE NOT NULL,
    end_date DATE,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, category_id, period, start_date)
);


## 14. Recurring Transactions Table

sql
CREATE TABLE recurring_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    account_id UUID REFERENCES financial_accounts(id) ON DELETE SET NULL,
    category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
    type VARCHAR(20) NOT NULL CHECK (type IN ('income', 'expense')),
    amount DECIMAL(15, 2) NOT NULL,
    description VARCHAR(255),
    frequency VARCHAR(20) NOT NULL CHECK (frequency IN ('daily', 'weekly', 'biweekly', 'monthly', 'yearly')),
    next_run_date DATE NOT NULL,
    last_run_date DATE,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


## 15. Notifications Table

sql
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    data JSONB,
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_notifications_user_read ON notifications(user_id, is_read);


## 16. User Settings Table

sql
CREATE TABLE user_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    currency VARCHAR(3) DEFAULT 'IDR',
    language VARCHAR(10) DEFAULT 'id',
    date_format VARCHAR(20) DEFAULT 'DD/MM/YYYY',
    theme VARCHAR(10) DEFAULT 'light',
    first_day_of_week INTEGER DEFAULT 1,
    default_account_id UUID REFERENCES financial_accounts(id) ON DELETE SET NULL,
    notifications_enabled BOOLEAN DEFAULT true,
    biometric_enabled BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


## 17. Data Exports Table

sql
CREATE TABLE data_exports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    export_type VARCHAR(50) NOT NULL,
    format VARCHAR(10) DEFAULT 'csv',
    file_path TEXT,
    date_from DATE,
    date_to DATE,
    status VARCHAR(20) DEFAULT 'pending',
    error_message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP
);


## 18. Sync Log Table

sql
CREATE TABLE sync_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    device_id VARCHAR(255),
    table_name VARCHAR(100),
    record_id UUID,
    action VARCHAR(20) NOT NULL CHECK (action IN ('INSERT', 'UPDATE', 'DELETE')),
    data_before JSONB,
    data_after JSONB,
    synced_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_sync_logs_user ON sync_logs(user_id, created_at);
CREATE INDEX idx_sync_logs_device ON sync_logs(device_id, synced_at);


## 19. Audit Log Table

sql
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(100),
    entity_id UUID,
    old_values JSONB,
    new_values JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_audit_logs_user ON audit_logs(user_id, created_at);
CREATE INDEX idx_audit_logs_entity ON audit_logs(entity_type, entity_id);


## 20. Stock Market Data Cache Table

sql
CREATE TABLE stock_market_cache (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    symbol VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(255),
    exchange VARCHAR(50),
    current_price DECIMAL(15, 4),
    previous_close DECIMAL(15, 4),
    change_percent DECIMAL(8, 4),
    volume BIGINT,
    market_cap DECIMAL(20, 2),
    pe_ratio DECIMAL(10, 2),
    dividend_yield DECIMAL(8, 4),
    week_52_high DECIMAL(15, 4),
    week_52_low DECIMAL(15, 4),
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP + INTERVAL '1 hour'
);

CREATE INDEX idx_stock_cache_symbol ON stock_market_cache(symbol);
CREATE INDEX idx_stock_cache_expiry ON stock_market_cache(expires_at);


## 21. Stock Price History Table

sql
CREATE TABLE stock_price_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    symbol VARCHAR(20) NOT NULL,
    price_date DATE NOT NULL,
    open_price DECIMAL(15, 4),
    high_price DECIMAL(15, 4),
    low_price DECIMAL(15, 4),
    close_price DECIMAL(15, 4),
    adjusted_close DECIMAL(15, 4),
    volume BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(symbol, price_date)
);

CREATE INDEX idx_stock_history_symbol_date ON stock_price_history(symbol, price_date);




# PART 3: Investment & Analytics Database

## 9. Investment Tables

### 9.1 Stocks Master Data

sql
CREATE TABLE stocks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    symbol VARCHAR(10) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    sector VARCHAR(100),
    exchange VARCHAR(50),
    currency VARCHAR(3) DEFAULT 'IDR',
    current_price DECIMAL(15,2),
    previous_close DECIMAL(15,2),
    market_cap BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_stocks_symbol ON stocks(symbol);
CREATE INDEX idx_stocks_sector ON stocks(sector);


### 9.2 Portfolio Holdings

sql
CREATE TABLE portfolio_holdings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    stock_id UUID NOT NULL REFERENCES stocks(id) ON DELETE CASCADE,
    account_id UUID REFERENCES accounts(id) ON DELETE SET NULL,
    quantity DECIMAL(15,4) NOT NULL,
    average_buy_price DECIMAL(15,2) NOT NULL,
    current_value DECIMAL(15,2),
    total_invested DECIMAL(15,2),
    unrealized_gain_loss DECIMAL(15,2),
    unrealized_gain_loss_pct DECIMAL(8,4),
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, stock_id)
);

CREATE INDEX idx_portfolio_user ON portfolio_holdings(user_id);
CREATE INDEX idx_portfolio_stock ON portfolio_holdings(stock_id);
CREATE INDEX idx_portfolio_status ON portfolio_holdings(status);


### 9.3 Transaction History

sql
CREATE TABLE stock_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    stock_id UUID NOT NULL REFERENCES stocks(id) ON DELETE CASCADE,
    holding_id UUID REFERENCES portfolio_holdings(id) ON DELETE CASCADE,
    account_id UUID REFERENCES accounts(id) ON DELETE SET NULL,
    transaction_type VARCHAR(10) NOT NULL CHECK (transaction_type IN ('buy', 'sell', 'dividend', 'split')),
    quantity DECIMAL(15,4) NOT NULL,
    price DECIMAL(15,2) NOT NULL,
    total_amount DECIMAL(15,2) NOT NULL,
    fee DECIMAL(10,2) DEFAULT 0,
    transaction_date DATE NOT NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_stock_tx_user ON stock_transactions(user_id);
CREATE INDEX idx_stock_tx_stock ON stock_transactions(stock_id);
CREATE INDEX idx_stock_tx_date ON stock_transactions(transaction_date);
CREATE INDEX idx_stock_tx_type ON stock_transactions(transaction_type);


### 9.4 Watchlist

sql
CREATE TABLE watchlists (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    stock_id UUID NOT NULL REFERENCES stocks(id) ON DELETE CASCADE,
    target_price DECIMAL(15,2),
    notes TEXT,
    alert_enabled BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, stock_id)
);

CREATE INDEX idx_watchlist_user ON watchlists(user_id);


### 9.5 Stock Price History

sql
CREATE TABLE stock_price_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    stock_id UUID NOT NULL REFERENCES stocks(id) ON DELETE CASCADE,
    price_date DATE NOT NULL,
    open_price DECIMAL(15,2),
    high_price DECIMAL(15,2),
    low_price DECIMAL(15,2),
    close_price DECIMAL(15,2) NOT NULL,
    volume BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(stock_id, price_date)
);

CREATE INDEX idx_price_history_stock ON stock_price_history(stock_id);
CREATE INDEX idx_price_history_date ON stock_price_history(price_date);


## 10. Reporting & Analytics Tables

### 10.1 Monthly Summaries

sql
CREATE TABLE monthly_summaries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    year INT NOT NULL,
    month INT NOT NULL CHECK (month BETWEEN 1 AND 12),
    total_income DECIMAL(15,2) DEFAULT 0,
    total_expense DECIMAL(15,2) DEFAULT 0,
    net_flow DECIMAL(15,2) DEFAULT 0,
    savings_rate DECIMAL(5,2),
    total_assets DECIMAL(15,2) DEFAULT 0,
    total_liabilities DECIMAL(15,2) DEFAULT 0,
    net_worth DECIMAL(15,2) DEFAULT 0,
    portfolio_value DECIMAL(15,2) DEFAULT 0,
    portfolio_return DECIMAL(10,4),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, year, month)
);

CREATE INDEX idx_monthly_user ON monthly_summaries(user_id);
CREATE INDEX idx_monthly_period ON monthly_summaries(year, month);


### 10.2 Category Statistics

sql
CREATE TABLE category_statistics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    category_id UUID REFERENCES categories(id) ON DELETE CASCADE,
    type VARCHAR(10) NOT NULL CHECK (type IN ('income', 'expense')),
    year INT NOT NULL,
    month INT NOT NULL,
    total_amount DECIMAL(15,2) DEFAULT 0,
    transaction_count INT DEFAULT 0,
    percentage DECIMAL(5,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, category_id, type, year, month)
);

CREATE INDEX idx_cat_stats_user ON category_statistics(user_id);
CREATE INDEX idx_cat_stats_period ON category_statistics(year, month);


### 10.3 Net Worth History

sql
CREATE TABLE net_worth_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    record_date DATE NOT NULL,
    cash_balance DECIMAL(15,2) DEFAULT 0,
    bank_balance DECIMAL(15,2) DEFAULT 0,
    ewallet_balance DECIMAL(15,2) DEFAULT 0,
    savings_balance DECIMAL(15,2) DEFAULT 0,
    investment_balance DECIMAL(15,2) DEFAULT 0,
    portfolio_value DECIMAL(15,2) DEFAULT 0,
    total_assets DECIMAL(15,2) DEFAULT 0,
    total_liabilities DECIMAL(15,2) DEFAULT 0,
    net_worth DECIMAL(15,2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, record_date)
);

CREATE INDEX idx_networth_user ON net_worth_history(user_id);
CREATE INDEX idx_networth_date ON net_worth_history(record_date);


## 11. System Tables

### 11.1 Audit Log

sql
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    action VARCHAR(50) NOT NULL,
    entity_type VARCHAR(50) NOT NULL,
    entity_id UUID,
    old_value JSONB,
    new_value JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_audit_user ON audit_logs(user_id);
CREATE INDEX idx_audit_entity ON audit_logs(entity_type, entity_id);
CREATE INDEX idx_audit_action ON audit_logs(action);
CREATE INDEX idx_audit_date ON audit_logs(created_at);


### 11.2 User Activity Log

sql
CREATE TABLE user_activities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    activity_type VARCHAR(50) NOT NULL,
    activity_data JSONB,
    session_id VARCHAR(100),
    device_info JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_activity_user ON user_activities(user_id);
CREATE INDEX idx_activity_date ON user_activities(created_at);


### 11.3 Sync Queue

sql
CREATE TABLE sync_queue (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    entity_type VARCHAR(50) NOT NULL,
    entity_id UUID NOT NULL,
    operation VARCHAR(10) NOT NULL CHECK (operation IN ('create', 'update', 'delete')),
    data JSONB,
    status VARCHAR(20) DEFAULT 'pending',
    retry_count INT DEFAULT 0,
    error_message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMP
);

CREATE INDEX idx_sync_user ON sync_queue(user_id);
CREATE INDEX idx_sync_status ON sync_queue(status);
CREATE INDEX idx_sync_pending ON sync_queue(created_at) WHERE status = 'pending';


### 11.4 Notification Queue

sql
CREATE TABLE notification_queue (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    body TEXT,
    data JSONB,
    channel VARCHAR(20) DEFAULT 'in_app',
    status VARCHAR(20) DEFAULT 'pending',
    scheduled_at TIMESTAMP,
    sent_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_notification_user ON notification_queue(user_id);
CREATE INDEX idx_notification_status ON notification_queue(status);
CREATE INDEX idx_notification_scheduled ON notification_queue(scheduled_at);


## 12. Database Triggers

### 12.1 Automatic Timestamp Update

sql
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_accounts_updated
    BEFORE UPDATE ON accounts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER tr_transactions_updated
    BEFORE UPDATE ON transactions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER tr_portfolio_updated
    BEFORE UPDATE ON portfolio_holdings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();


### 12.2 Portfolio Calculation Trigger

sql
CREATE OR REPLACE FUNCTION calculate_portfolio_metrics()
RETURNS TRIGGER AS $$
DECLARE
    current_price DECIMAL(15,2);
    total_invested DECIMAL(15,2);
BEGIN
    SELECT close_price INTO current_price
    FROM stock_price_history
    WHERE stock_id = NEW.stock_id
    ORDER BY price_date DESC
    LIMIT 1;

    total_invested := NEW.quantity * NEW.average_buy_price;
    
    NEW.current_value := NEW.quantity * COALESCE(current_price, NEW.average_buy_price);
    NEW.total_invested := total_invested;
    NEW.unrealized_gain_loss := NEW.current_value - total_invested;
    
    IF total_invested > 0 THEN
        NEW.unrealized_gain_loss_pct := 
            ((NEW.current_value - total_invested) / total_invested) * 100;
    ELSE
        NEW.unrealized_gain_loss_pct := 0;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_portfolio_calculate
    BEFORE INSERT OR UPDATE ON portfolio_holdings
    FOR EACH ROW EXECUTE FUNCTION calculate_portfolio_metrics();


### 12.3 Account Balance Trigger

sql
CREATE OR REPLACE FUNCTION update_account_balance()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        IF NEW.type = 'income' THEN
            UPDATE accounts SET balance = balance + NEW.amount WHERE id = NEW.account_id;
        ELSE
            UPDATE accounts SET balance = balance - NEW.amount WHERE id = NEW.account_id;
        END IF;
    ELSIF TG_OP = 'DELETE' THEN
        IF OLD.type = 'income' THEN
            UPDATE accounts SET balance = balance - OLD.amount WHERE id = OLD.account_id;
        ELSE
            UPDATE accounts SET balance = balance + OLD.amount WHERE id = OLD.account_id;
        END IF;
    ELSIF TG_OP = 'UPDATE' THEN
        IF OLD.account_id = NEW.account_id THEN
            IF OLD.type = 'income' AND NEW.type = 'expense' THEN
                UPDATE accounts SET balance = balance - OLD.amount - NEW.amount WHERE id = NEW.account_id;
            ELSIF OLD.type = 'expense' AND NEW.type = 'income' THEN
                UPDATE accounts SET balance = balance + OLD.amount + NEW.amount WHERE id = NEW.account_id;
            ELSIF OLD.type = NEW.type THEN
                UPDATE accounts SET balance = balance + (CASE WHEN NEW.type = 'income' THEN NEW.amount - OLD.amount ELSE OLD.amount - NEW.amount END)
                WHERE id = NEW.account_id;
            END IF;
        ELSE
            IF OLD.type = 'income' THEN
                UPDATE accounts SET balance = balance - OLD.amount WHERE id = OLD.account_id;
            ELSE
                UPDATE accounts SET balance = balance + OLD.amount WHERE id = OLD.account_id;
            END IF;
            
            IF NEW.type = 'income' THEN
                UPDATE accounts SET balance = balance + NEW.amount WHERE id = NEW.account_id;
            ELSE
                UPDATE accounts SET balance = balance - NEW.amount WHERE id = NEW.account_id;
            END IF;
        END IF;
    END IF;
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_transaction_balance
    AFTER INSERT OR UPDATE OR DELETE ON transactions
    FOR EACH ROW EXECUTE FUNCTION update_account_balance();


## 13. Views for Common Queries

### 13.1 Dashboard Summary View

sql
CREATE OR REPLACE VIEW v_dashboard_summary AS
SELECT 
    u.id AS user_id,
    u.name AS user_name,
    COALESCE(SUM(CASE WHEN a.account_type = 'cash' THEN a.balance ELSE 0 END), 0) AS total_cash,
    COALESCE(SUM(CASE WHEN a.account_type IN ('bank', 'savings') THEN a.balance ELSE 0 END), 0) AS total_bank,
    COALESCE(SUM(a.balance), 0) AS total_balance,
    COALESCE(SUM(p.current_value), 0) AS total_portfolio,
    COALESCE(SUM(p.current_value), 0) + COALESCE(SUM(a.balance), 0) AS total_net_worth
FROM users u
LEFT JOIN accounts a ON u.id = a.user_id AND a.status = 'active'
LEFT JOIN portfolio_holdings p ON u.id = p.user_id AND p.status = 'active'
GROUP BY u.id, u.name;


### 13.2 Monthly Cashflow View

sql
CREATE OR REPLACE VIEW v_monthly_cashflow AS
SELECT 
    user_id,
    DATE_TRUNC('month', transaction_date) AS month,
    SUM(CASE WHEN type = 'income' THEN amount ELSE 0 END) AS total_income,
    SUM(CASE WHEN type = 'expense' THEN amount ELSE 0 END) AS total_expense,
    SUM(CASE WHEN type = 'income' THEN amount ELSE -amount END) AS net_flow,
    COUNT(*) AS transaction_count
FROM transactions
WHERE status = 'completed'
GROUP BY user_id, DATE_TRUNC('month', transaction_date);


### 13.3 Category Breakdown View

sql
CREATE OR REPLACE VIEW v_category_breakdown AS
SELECT 
    t.user_id,
    t.category_id,
    c.name AS category_name,
    c.icon AS category_icon,
    c.color AS category_color,
    t.type,
    DATE_TRUNC('month', t.transaction_date) AS month,
    SUM(t.amount) AS total_amount,
    COUNT(*) AS transaction_count,
    RANK() OVER (PARTITION BY t.user_id, t.type, DATE_TRUNC('month', t.transaction_date) 
                 ORDER BY SUM(t.amount) DESC) AS category_rank
FROM transactions t
JOIN categories c ON t.category_id = c.id
WHERE t.status = 'completed'
GROUP BY t.user_id, t.category_id, c.name, c.icon, c.color, t.type, 
         DATE_TRUNC('month', t.transaction_date);


### 13.4 Portfolio Performance View

sql
CREATE OR REPLACE VIEW v_portfolio_performance AS
SELECT 
    p.user_id,
    p.stock_id,
    s.symbol,
    s.name,
    p.quantity,
    p.average_buy_price,
    p.current_value,
    p.total_invested,
    p.unrealized_gain_loss,
    p.unrealized_gain_loss_pct,
    SUM(p.unrealized_gain_loss) OVER (PARTITION BY p.user_id) AS total_gain_loss,
    (p.unrealized_gain_loss / NULLIF(SUM(p.total_invested) OVER (PARTITION BY p.user_id), 0)) * 100 AS portfolio_weight
FROM portfolio_holdings p
JOIN stocks s ON p.stock_id = s.id
WHERE p.status = 'active';


## 14. Indexing Strategy

### 14.1 Composite Indexes

sql
-- Transactions commonly queried by user and date range
CREATE INDEX idx_transactions_user_date ON transactions(user_id, transaction_date DESC);

-- Transactions by user, type, and date
CREATE INDEX idx_transactions_user_type_date ON transactions(user_id, type, transaction_date DESC);

-- Portfolio holdings by user and status
CREATE INDEX idx_holdings_user_status ON portfolio_holdings(user_id, status);

-- Net worth history for trend analysis
CREATE INDEX idx_networth_user_date ON net_worth_history(user_id, record_date DESC);

-- Monthly summaries for quick retrieval
CREATE INDEX idx_summaries_user_period ON monthly_summaries(user_id, year DESC, month DESC);


### 14.2 Partial Indexes

sql
-- Only index active records for faster queries
CREATE INDEX idx_accounts_active ON accounts(user_id) WHERE status = 'active';
CREATE INDEX idx_transactions_completed ON transactions(user_id, transaction_date) WHERE status = 'completed';
CREATE INDEX idx_holdings_active_value ON portfolio_holdings(user_id, current_value DESC) WHERE status = 'active';

-- Pending sync items
CREATE INDEX idx_sync_pending_user ON sync_queue(user_id, created_at) WHERE status = 'pending';


## 15. Data Retention & Archival

### 15.1 Retention Policies

sql
-- Audit logs: 1 year
-- User activities: 6 months
-- Price history: Indefinite (required for charts)
-- Sync queue: 30 days
-- Notification queue: 7 days (after sent)
-- Deleted transaction archive: 1 year


### 15.2 Archive Tables

sql
CREATE TABLE transactions_archive (
    LIKE transactions INCLUDING ALL
);

CREATE TABLE deleted_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    table_name VARCHAR(50) NOT NULL,
    record_id UUID NOT NULL,
    data JSONB NOT NULL,
    deleted_by UUID REFERENCES users(id),
    deleted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reason VARCHAR(255)
);

CREATE INDEX idx_deleted_table ON deleted_records(table_name);
CREATE INDEX idx_deleted_record ON deleted_records(record_id);


## 16. Security Considerations

### 16.1 Row Level Security (RLS)

sql
ALTER TABLE accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE portfolio_holdings ENABLE ROW LEVEL SECURITY;

CREATE POLICY accounts_user_policy ON accounts
    FOR ALL USING (user_id = current_user_id());

CREATE POLICY transactions_user_policy ON transactions
    FOR ALL USING (user_id = current_user_id());

CREATE POLICY portfolio_user_policy ON portfolio_holdings
    FOR ALL USING (user_id = current_user_id());


### 16.2 Data Encryption

sql
-- Enable pgcrypto for column-level encryption
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Example: Encrypting sensitive financial data
-- Note: Implement application-level encryption for PIN/biometric data


## 17. Performance Optimization

### 17.1 Materialized Views for Reports

sql
CREATE MATERIALIZED VIEW mv_daily_balances AS
SELECT 
    user_id,
    account_id,
    record_date,
    opening_balance,
    total_income,
    total_expense,
    closing_balance
FROM daily_balances
WITH DATA;

CREATE UNIQUE INDEX idx_mv_daily_user_account_date 
ON mv_daily_balances(user_id, account_id, record_date);

REFRESH MATERIALIZED VIEW CONCURRENTLY mv_daily_balances;


### 17.2 Query Optimization Tips

sql
-- Use prepared statements for repeated queries
-- Implement connection pooling (pgbouncer for PostgreSQL)
-- Use EXPLAIN ANALYZE for query analysis
-- Monitor slow queries via pg_stat_statements
-- Consider partitioning large tables by date


## 18. Backup & Recovery

### 18.1 Backup Strategy

sql
-- Daily full backups at low traffic hours
-- Point-in-time recovery (PITR) using WAL archiving
-- Cross-region replication for disaster recovery
-- Test restoration quarterly


### 18.2 Recovery Point Objective (RPO)

- Financial transactions: 15 minutes maximum data loss
- User data: 1 hour maximum data loss
- Price history: 24 hours acceptable

### 18.3 Recovery Time Objective (RTO)

- Critical systems: 30 minutes
- Non-critical systems: 4 hours

---

## Appendix A: Entity Relationship Summary


users (1) ─────── (n) accounts
    │                    │
    │                    └─── (n) transactions
    │                              │
    │                              └─── (1) categories
    │
    ├────── (n) savings_targets
    │
    ├────── (n) portfolio_holdings ──── (1) stocks
    │              │
    │              └─── (n) stock_transactions
    │
    ├────── (n) watchlists ──── (1) stocks
    │
    ├────── (n) monthly_summaries
    │
    ├────── (n) category_statistics
    │
    ├────── (n) net_worth_history
    │
    └────── (n) audit_logs


## Appendix B: Data Migration Notes

1. **Initial Setup**: Run all CREATE TABLE statements in dependency order
2. **Seed Data**: Populate categories and default settings after tables created
3. **Index Creation**: Create indexes after initial data load for better performance
4. **Trigger Creation**: Add triggers last after all tables are verified
5. **Testing**: Use EXPLAIN ANALYZE to verify query performance

## Appendix C: Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | Initial | Base schema for MVP |
| 1.1 | Added | Stock investment tables |
| 1.2 | Added | Analytics and reporting views |
| 1.3 | Added | Triggers for automatic calculations |
| 1.4 | Added | Security policies and indexes |

---

*Document Version: 1.4*
*Last Updated: 2024*
*Maintained by: Database Architecture Team*



