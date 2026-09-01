# FinTrack API Specification

## Document Information

- **Version:** 1.0.0
- **Last Updated:** 2024
- **Status:** Draft
- **Part:** 1 of 3

---

## Table of Contents

1. [Introduction](#introduction)
2. [API Overview](#api-overview)
3. [Authentication](#authentication)
4. [Base URL & Response Format](#base-url--response-format)
5. [Error Handling](#error-handling)

---

## Introduction

### About FinTrack API

FinTrack API is a RESTful backend service designed to support the FinTrack Personal Finance and Stock Portfolio Tracker application. The API provides endpoints for managing user finances, transactions, accounts, savings targets, and stock portfolios.

### Technology Stack

| Layer | Technology |
|-------|------------|
| Runtime | Node.js 20+ |
| Framework | Express.js 4.x |
| Database | PostgreSQL 15+ |
| ORM | Prisma |
| Authentication | JWT (Access + Refresh Tokens) |
| File Storage | AWS S3 / Local Storage |
| Validation | Zod |
| API Documentation | OpenAPI 3.0 |

### API Versioning

All endpoints are versioned using URL path versioning:


https://api.fintrack.app/v1/{resource}


---

## API Overview

### HTTP Methods

| Method | Usage |
|--------|-------|
| GET | Retrieve resources |
| POST | Create new resources |
| PUT | Full update of resources |
| PATCH | Partial update of resources |
| DELETE | Remove resources |

### Request Headers

| Header | Required | Description |
|--------|----------|-------------|
| `Content-Type` | Yes | Must be `application/json` for request body |
| `Authorization` | Yes | Bearer token for authenticated requests |
| `X-Request-ID` | No | UUID for request tracing |
| `X-Timezone` | No | User timezone (e.g., `Asia/Jakarta`) |

### Response Format

All API responses follow a consistent structure:

#### Success Response

json
{
  "success": true,
  "data": { ... },
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 100,
    "totalPages": 5
  }
}


#### Error Response

json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid request data",
    "details": [
      {
        "field": "email",
        "message": "Invalid email format"
      }
    ]
  }
}


### Pagination

List endpoints support pagination via query parameters:

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `page` | integer | 1 | Page number |
| `limit` | integer | 20 | Items per page (max: 100) |
| `sort` | string | `createdAt` | Sort field |
| `order` | string | `desc` | Sort order (`asc` or `desc`) |

---

## Authentication

### Endpoints Overview

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/auth/register` | Register new user |
| POST | `/auth/login` | User login |
| POST | `/auth/logout` | User logout |
| POST | `/auth/refresh` | Refresh access token |
| POST | `/auth/forgot-password` | Request password reset |
| POST | `/auth/reset-password` | Reset password with token |
| POST | `/auth/verify-email` | Verify email address |
| POST | `/auth/google` | Google OAuth login |
| GET | `/auth/me` | Get current user |

### POST /auth/register

Register a new user account.

**Request Body:**

json
{
  "email": "user@example.com",
  "password": "SecurePassword123!",
  "fullName": "John Doe",
  "currency": "IDR",
  "timezone": "Asia/Jakarta"
}


**Validation Rules:**

| Field | Type | Required | Rules |
|-------|------|----------|-------|
| email | string | Yes | Valid email format, unique |
| password | string | Yes | Min 8 chars, 1 uppercase, 1 number, 1 special char |
| fullName | string | Yes | Min 2 chars, max 100 chars |
| currency | string | No | ISO 4217 code (default: IDR) |
| timezone | string | No | IANA timezone (default: Asia/Jakarta) |

**Success Response (201):**

json
{
  "success": true,
  "data": {
    "user": {
      "id": "usr_abc123xyz",
      "email": "user@example.com",
      "fullName": "John Doe",
      "currency": "IDR",
      "timezone": "Asia/Jakarta",
      "emailVerified": false,
      "createdAt": "2024-01-15T10:30:00Z"
    },
    "tokens": {
      "accessToken": "eyJhbGciOiJIUzI1NiIs...",
      "refreshToken": "eyJhbGciOiJIUzI1NiIs...",
      "expiresIn": 900
    }
  }
}


### POST /auth/login

Authenticate user and receive tokens.

**Request Body:**

json
{
  "email": "user@example.com",
  "password": "SecurePassword123!",
  "deviceInfo": {
    "name": "iPhone 15 Pro",
    "platform": "ios",
    "version": "17.0"
  }
}


**Success Response (200):**

json
{
  "success": true,
  "data": {
    "user": {
      "id": "usr_abc123xyz",
      "email": "user@example.com",
      "fullName": "John Doe",
      "avatar": "https://cdn.fintrack.app/avatars/usr_abc123xyz.jpg",
      "currency": "IDR",
      "pinEnabled": false,
      "biometricEnabled": false
    },
    "tokens": {
      "accessToken": "eyJhbGciOiJIUzI1NiIs...",
      "refreshToken": "eyJhbGciOiJIUzI1NiIs...",
      "expiresIn": 900
    }
  }
}


**Error Codes:**

| Code | HTTP Status | Description |
|------|-------------|-------------|
| INVALID_CREDENTIALS | 401 | Email or password incorrect |
| ACCOUNT_LOCKED | 423 | Account temporarily locked |
| ACCOUNT_DISABLED | 403 | Account has been disabled |

### POST /auth/refresh

Refresh access token using refresh token.

**Request Body:**

json
{
  "refreshToken": "eyJhbGciOiJIUzI1NiIs..."
}


**Success Response (200):**

json
{
  "success": true,
  "data": {
    "tokens": {
      "accessToken": "eyJhbGciOiJIUzI1NiIs...",
      "refreshToken": "eyJhbGciOiJIUzI1NiIs...",
      "expiresIn": 900
    }
  }
}


### POST /auth/logout

Invalidate refresh token and logout user.

**Request Body:**

json
{
  "refreshToken": "eyJhbGciOiJIUzI1NiIs..."
}


**Success Response (200):**

json
{
  "success": true,
  "message": "Successfully logged out"
}


### POST /auth/google

Authenticate using Google OAuth.

**Request Body:**

json
{
  "idToken": "google_id_token_here",
  "deviceInfo": {
    "name": "Chrome Browser",
    "platform": "web",
    "version": "120.0"
  }
}


**Success Response (200):**

json
{
  "success": true,
  "data": {
    "user": {
      "id": "usr_abc123xyz",
      "email": "user@example.com",
      "fullName": "John Doe",
      "avatar": "https://lh3.googleusercontent.com/...",
      "authProvider": "google",
      "emailVerified": true
    },
    "tokens": {
      "accessToken": "eyJhbGciOiJIUzI1NiIs...",
      "refreshToken": "eyJhbGciOiJIUzI1NiIs...",
      "expiresIn": 900
    },
    "isNewUser": false
  }
}


### GET /auth/me

Get authenticated user's profile.

**Headers:**


Authorization: Bearer eyJhbGciOiJIUzI1NiIs...


**Success Response (200):**

json
{
  "success": true,
  "data": {
    "id": "usr_abc123xyz",
    "email": "user@example.com",
    "fullName": "John Doe",
    "avatar": "https://cdn.fintrack.app/avatars/usr_abc123xyz.jpg",
    "currency": "IDR",
    "timezone": "Asia/Jakarta",
    "pinEnabled": true,
    "biometricEnabled": false,
    "emailVerified": true,
    "settings": {
      "darkMode": false,
      "notifications": true,
      "language": "id"
    },
    "createdAt": "2024-01-15T10:30:00Z",
    "updatedAt": "2024-01-20T15:45:00Z"
  }
}


### POST /auth/forgot-password

Request password reset email.

**Request Body:**

json
{
  "email": "user@example.com"
}


**Success Response (200):**

json
{
  "success": true,
  "message": "Password reset email sent if account exists"
}


### POST /auth/reset-password

Reset password using token from email.

**Request Body:**

json
{
  "token": "reset_token_from_email",
  "newPassword": "NewSecurePassword123!"
}


**Success Response (200):**

json
{
  "success": true,
  "message": "Password successfully reset"
}


---

## Base URL & Response Format

### Environments

| Environment | Base URL |
|-------------|----------|
| Production | `https://api.fintrack.app` |
| Staging | `https://api-staging.fintrack.app` |
| Development | `https://api-dev.fintrack.app` |

### Content-Type

All responses are JSON-encoded. Always include header:


Content-Type: application/json


### Rate Limiting

| Plan | Requests/minute | Requests/day |
|------|-----------------|--------------|
| Free | 60 | 1,000 |
| Premium | 300 | 10,000 |
| Enterprise | 1,000 | 100,000 |

Rate limit headers in response:


X-RateLimit-Limit: 60
X-RateLimit-Remaining: 55
X-RateLimit-Reset: 1705312260


---

## Error Handling

### HTTP Status Codes

| Code | Meaning |
|------|---------|
| 200 | Success |
| 201 | Created |
| 204 | No Content (successful delete) |
| 400 | Bad Request - Invalid input |
| 401 | Unauthorized - Invalid/missing token |
| 403 | Forbidden - Insufficient permissions |
| 404 | Not Found |
| 409 | Conflict - Resource already exists |
| 422 | Unprocessable Entity - Validation failed |
| 423 | Locked - Resource locked |
| 429 | Too Many Requests - Rate limited |
| 500 | Internal Server Error |

### Error Response Format

json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human readable message",
    "details": []
  }
}


### Common Error Codes

| Code | Description |
|------|-------------|
| VALIDATION_ERROR | Request validation failed |
| INVALID_CREDENTIALS | Wrong email or password |
| TOKEN_EXPIRED | Access token has expired |
| TOKEN_INVALID | Token is malformed or invalid |
| UNAUTHORIZED | Not authenticated |
| FORBIDDEN | Not authorized to access resource |
| NOT_FOUND | Resource does not exist |
| CONFLICT | Resource already exists |
| RATE_LIMITED | Too many requests |
| INTERNAL_ERROR | Server error |

### Example Error Response

json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Request validation failed",
    "details": [
      {
        "field": "email",
        "message": "Invalid email format",
        "value": "invalid-email"
      },
      {
        "field": "password",
        "message": "Password must be at least 8 characters",
        "value": "short"
      }
    ]
  }
}


---

## Next Steps

- **Part 2:** User Profile, Accounts, and Categories API
- **Part 3:** Transactions, Savings Targets, and Stock Portfolio API



# FinTrack API Specification - Part 2

## 3. Transaction API

### 3.1 Transaction Object

json
{
  "id": "txn_uuid",
  "type": "income | expense",
  "amount": 150000.00,
  "category_id": "cat_uuid",
  "account_id": "acc_uuid",
  "description": "Gaji Bulanan",
  "date": "2024-01-15",
  "time": "08:30:00",
  "tags": ["gaji", "bulanan"],
  "receipt_url": "https://storage.fintrack.app/receipts/uuid.pdf",
  "is_recurring": false,
  "recurring_interval": null,
  "created_at": "2024-01-15T08:30:00Z",
  "updated_at": "2024-01-15T08:30:00Z"
}


### 3.2 Transaction Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/transactions` | List all transactions |
| POST | `/api/v1/transactions` | Create new transaction |
| GET | `/api/v1/transactions/:id` | Get transaction details |
| PUT | `/api/v1/transactions/:id` | Update transaction |
| DELETE | `/api/v1/transactions/:id` | Delete transaction |
| POST | `/api/v1/transactions/bulk` | Bulk create transactions |
| GET | `/api/v1/transactions/export` | Export transactions |

### 3.3 Transaction List Parameters


GET /api/v1/transactions?type=expense&category_id=uuid&account_id=uuid&start_date=2024-01-01&end_date=2024-01-31&page=1&limit=20&sort=date&order=desc


| Parameter | Type | Description |
|-----------|------|-------------|
| type | string | Filter by income or expense |
| category_id | string | Filter by category UUID |
| account_id | string | Filter by account UUID |
| start_date | date | Filter start date (YYYY-MM-DD) |
| end_date | date | Filter end date (YYYY-MM-DD) |
| min_amount | number | Minimum transaction amount |
| max_amount | number | Maximum transaction amount |
| tags | string | Comma-separated tags |
| search | string | Search in description |
| page | integer | Page number (default: 1) |
| limit | integer | Items per page (default: 20, max: 100) |
| sort | string | Sort field (date, amount, created_at) |
| order | string | Sort order (asc, desc) |

### 3.4 Create Transaction Request

json
{
  "type": "expense",
  "amount": 75000,
  "category_id": "cat_uuid",
  "account_id": "acc_uuid",
  "description": "Makan siang tim",
  "date": "2024-01-15",
  "time": "12:30:00",
  "tags": ["makan", "kantor"],
  "receipt_base64": "base64_encoded_image"
}


### 3.5 Category Object

json
{
  "id": "cat_uuid",
  "name": "Makanan & Minuman",
  "icon": "restaurant",
  "color": "#FF5722",
  "type": "expense",
  "parent_id": null,
  "is_system": true,
  "user_id": null,
  "created_at": "2024-01-01T00:00:00Z"
}


### 3.6 Category Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/categories` | List all categories |
| POST | `/api/v1/categories` | Create custom category |
| PUT | `/api/v1/categories/:id` | Update category |
| DELETE | `/api/v1/categories/:id` | Delete custom category |

---

## 4. Financial Account API

### 4.1 Account Object

json
{
  "id": "acc_uuid",
  "name": "Bank BCA",
  "type": "bank",
  "icon": "account_balance",
  "color": "#1E3A5F",
  "balance": 15000000.00,
  "currency": "IDR",
  "card_last_digits": "1234",
  "is_active": true,
  "include_in_total": true,
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-15T10:00:00Z"
}


### 4.2 Account Types

| Type | Description | Icon |
|------|-------------|------|
| cash | Tunai | wallet |
| bank | Rekening Bank | account_balance |
| ewallet | E-Wallet | smartphone |
| savings | Tabungan | savings |
| investment | Rekening Investasi | trending_up |

### 4.3 Account Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/accounts` | List all accounts |
| POST | `/api/v1/accounts` | Create new account |
| GET | `/api/v1/accounts/:id` | Get account details |
| PUT | `/api/v1/accounts/:id` | Update account |
| DELETE | `/api/v1/accounts/:id` | Delete account |
| GET | `/api/v1/accounts/:id/transactions` | Get account transactions |
| POST | `/api/v1/accounts/:id/transfer` | Transfer between accounts |
| GET | `/api/v1/accounts/balance/summary` | Get total balance summary |

### 4.4 Create Account Request

json
{
  "name": "OVO",
  "type": "ewallet",
  "icon": "payment",
  "color": "#6B3FA0",
  "initial_balance": 500000,
  "currency": "IDR",
  "card_last_digits": "4321",
  "include_in_total": true
}


### 4.5 Transfer Request

json
{
  "from_account_id": "acc_uuid_1",
  "to_account_id": "acc_uuid_2",
  "amount": 1000000,
  "description": "Transfer ke tabungan",
  "date": "2024-01-15",
  "fee": 0
}


---

## 5. Savings Goals API

### 5.1 Savings Goal Object

json
{
  "id": "goal_uuid",
  "name": "Dana Liburan",
  "target_amount": 10000000,
  "current_amount": 3500000,
  "deadline": "2024-12-31",
  "icon": "flight",
  "color": "#4CAF50",
  "priority": 1,
  "status": "in_progress",
  "contributions": [
    {
      "id": "contrib_uuid",
      "amount": 500000,
      "date": "2024-01-10",
      "note": "Tabungan mingguan"
    }
  ],
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-15T10:00:00Z"
}


### 5.2 Goal Status Values

| Status | Description |
|--------|-------------|
| in_progress | Masih dalam proses |
| achieved | Target tercapai |
| expired | Melewati deadline |
| cancelled | Dibatalkan |

### 5.3 Savings Goal Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/goals` | List all savings goals |
| POST | `/api/v1/goals` | Create new goal |
| GET | `/api/v1/goals/:id` | Get goal details |
| PUT | `/api/v1/goals/:id` | Update goal |
| DELETE | `/api/v1/goals/:id` | Delete goal |
| POST | `/api/v1/goals/:id/contribute` | Add contribution |
| DELETE | `/api/v1/goals/:id/contribute/:cid` | Remove contribution |
| GET | `/api/v1/goals/:id/progress` | Get progress statistics |
| PUT | `/api/v1/goals/:id/complete` | Mark goal as achieved |

### 5.4 Predefined Goal Templates

| Template | Target Amount | Icon |
|----------|---------------|------|
| Dana Darurat | 6x monthly expense | shield |
| Liburan | 5000000 | flight |
| Laptop | 15000000 | laptop |
| Kendaraan | 50000000 | directions_car |
| Rumah | 500000000 | home |
| Investasi | 100000000 | trending_up |

### 5.5 Create Goal Request

json
{
  "name": "Dana Darurat",
  "target_amount": 36000000,
  "deadline": "2024-12-31",
  "icon": "shield",
  "color": "#2196F3",
  "priority": 1,
  "template": "emergency_fund",
  "auto_contribute": true,
  "contribution_interval": "monthly",
  "contribution_amount": 3000000
}


### 5.6 Add Contribution Request

json
{
  "amount": 500000,
  "date": "2024-01-15",
  "note": "Tabungan dari bonus",
  "account_id": "acc_uuid"
}


---

## 6. Stock Portfolio API

### 6.1 Portfolio Holding Object

json
{
  "id": "hold_uuid",
  "symbol": "BBCA.JK",
  "company_name": "Bank Central Asia",
  "shares": 100,
  "average_buy_price": 8500,
  "current_price": 9200,
  "total_invested": 850000,
  "current_value": 920000,
  "profit_loss": 70000,
  "profit_loss_percent": 8.24,
  "sector": "Financial Services",
  "exchange": "IDX",
  "last_updated": "2024-01-15T16:00:00+07:00",
  "created_at": "2024-01-01T00:00:00Z"
}


### 6.2 Portfolio Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/portfolio` | Get full portfolio |
| GET | `/api/v1/portfolio/holdings` | List all holdings |
| POST | `/api/v1/portfolio/holdings` | Add new holding |
| GET | `/api/v1/portfolio/holdings/:id` | Get holding details |
| PUT | `/api/v1/portfolio/holdings/:id` | Update holding |
| DELETE | `/api/v1/portfolio/holdings/:id` | Remove holding |
| POST | `/api/v1/portfolio/holdings/:id/buy` | Record buy transaction |
| POST | `/api/v1/portfolio/holdings/:id/sell` | Record sell transaction |
| GET | `/api/v1/portfolio/summary` | Portfolio summary |
| GET | `/api/v1/portfolio/performance` | Performance charts |

### 6.3 Portfolio Summary Response

json
{
  "total_invested": 50000000,
  "current_value": 54500000,
  "total_profit_loss": 4500000,
  "total_profit_loss_percent": 9.0,
  "day_change": 250000,
  "day_change_percent": 0.46,
  "best_performer": {
    "symbol": "AMMN.JK",
    "profit_loss_percent": 15.5
  },
  "worst_performer": {
    "symbol": "TLKM.JK",
    "profit_loss_percent": -2.3
  },
  "sector_allocation": [
    {"sector": "Financial", "percentage": 45, "value": 24525000},
    {"sector": "Technology", "percentage": 25, "value": 13625000},
    {"sector": "Consumer", "percentage": 30, "value": 16350000}
  ]
}


### 6.4 Add Holding Request

json
{
  "symbol": "BBCA.JK",
  "shares": 100,
  "buy_price": 8500,
  "buy_date": "2024-01-10",
  "broker": "Stockbit",
  "fees": 25000
}


### 6.5 Record Buy Request

json
{
  "shares": 50,
  "price": 8800,
  "date": "2024-01-15",
  "fees": 20000,
  "broker": "Ajaib"
}


### 6.6 Record Sell Request

json
{
  "shares": 25,
  "price": 9500,
  "date": "2024-01-15",
  "fees": 20000,
  "broker": "Ajaib"
}


### 6.7 Watchlist Object

json
{
  "id": "watch_uuid",
  "symbol": "AMMN.JK",
  "company_name": "Ammann Mineral Internasional",
  "last_price": 12500,
  "change": 450,
  "change_percent": 3.74,
  "volume": 1500000,
  "market_cap": "250T",
  "add_alert": true,
  "target_price": 15000,
  "created_at": "2024-01-01T00:00:00Z"
}


### 6.8 Watchlist Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/watchlist` | List watchlist |
| POST | `/api/v1/watchlist` | Add to watchlist |
| DELETE | `/api/v1/watchlist/:symbol` | Remove from watchlist |
| PUT | `/api/v1/watchlist/:symbol/alert` | Set price alert |
| GET | `/api/v1/watchlist/search` | Search symbols |



# FinTrack API Specification - Part 3

## 7. Statistics & Analytics API

### 7.1 Get Spending Statistics

GET /api/v1/statistics/spending

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| period | string | No | daily, weekly, monthly, yearly (default: monthly) |
| start_date | date | No | Start of period (YYYY-MM-DD) |
| end_date | date | No | End of period (YYYY-MM-DD) |
| account_id | UUID | No | Filter by account |

**Response (200):**
json
{
  "success": true,
  "data": {
    "total_spending": 1500000,
    "transaction_count": 25,
    "average_transaction": 60000,
    "by_category": [
      {
        "category_id": "uuid",
        "category_name": "Makanan",
        "total": 500000,
        "percentage": 33.33,
        "transaction_count": 10
      }
    ],
    "by_day": [
      {
        "date": "2024-01-15",
        "total": 150000
      }
    ],
    "top_transactions": [
      {
        "id": "uuid",
        "amount": 200000,
        "description": "Makan siang",
        "category": "Makanan",
        "date": "2024-01-15"
      }
    ]
  }
}


### 7.2 Get Income Statistics

GET /api/v1/statistics/income

**Query Parameters:** Same as spending statistics

**Response (200):**
json
{
  "success": true,
  "data": {
    "total_income": 5000000,
    "transaction_count": 5,
    "average_transaction": 1000000,
    "by_category": [
      {
        "category_id": "uuid",
        "category_name": "Gaji",
        "total": 4000000,
        "percentage": 80,
        "transaction_count": 1
      }
    ],
    "by_day": [
      {
        "date": "2024-01-10",
        "total": 4000000
      }
    ]
  }
}


### 7.3 Get Cash Flow Statistics

GET /api/v1/statistics/cashflow

**Query Parameters:** Same as spending statistics

**Response (200):**
json
{
  "success": true,
  "data": {
    "total_income": 5000000,
    "total_spending": 1500000,
    "net_cashflow": 3500000,
    "savings_rate": 70,
    "by_month": [
      {
        "month": "2024-01",
        "income": 5000000,
        "spending": 1500000,
        "net": 3500000
      }
    ],
    "projected_savings": 42000000
  }
}


### 7.4 Get Net Worth Statistics

GET /api/v1/statistics/networth

**Response (200):**
json
{
  "success": true,
  "data": {
    "total_assets": 50000000,
    "total_liabilities": 0,
    "net_worth": 50000000,
    "asset_allocation": {
      "cash": 10000000,
      "bank_accounts": 25000000,
      "investments": 15000000,
      "other": 0
    },
    "change_percentage": 5.2,
    "history": [
      {
        "date": "2024-01-01",
        "net_worth": 47500000
      }
    ]
  }
}


### 7.5 Get Investment Statistics

GET /api/v1/statistics/investments

**Response (200):**
json
{
  "success": true,
  "data": {
    "total_portfolio_value": 15000000,
    "total_invested": 12000000,
    "total_gain_loss": 3000000,
    "total_return_percentage": 25,
    "day_change": 150000,
    "day_change_percentage": 1,
    "best_performer": {
      "symbol": "BBCA",
      "return_percentage": 15
    },
    "worst_performer": {
      "symbol": "TLKM",
      "return_percentage": -5
    },
    "allocation": [
      {
        "symbol": "BBCA",
        "shares": 100,
        "value": 7500000,
        "percentage": 50
      }
    ]
  }
}


---

## 8. User Profile & Settings API

### 8.1 Get User Profile

GET /api/v1/users/profile

**Response (200):**
json
{
  "success": true,
  "data": {
    "id": "uuid",
    "email": "user@example.com",
    "name": "John Doe",
    "avatar_url": "https://storage.example.com/avatars/uuid.jpg",
    "phone": "+6281234567890",
    "currency": "IDR",
    "timezone": "Asia/Jakarta",
    "language": "id",
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-15T00:00:00Z"
  }
}


### 8.2 Update User Profile

PUT /api/v1/users/profile

**Request Body:**
json
{
  "name": "John Doe Updated",
  "phone": "+6281234567890",
  "avatar": "base64_encoded_image",
  "currency": "IDR",
  "timezone": "Asia/Jakarta",
  "language": "id"
}


### 8.3 Get App Settings

GET /api/v1/users/settings

**Response (200):**
json
{
  "success": true,
  "data": {
    "theme": "dark",
    "notifications": {
      "daily_reminder": true,
      "reminder_time": "20:00",
      "transaction_alerts": true,
      "portfolio_alerts": true,
      "savings_milestones": true
    },
    "security": {
      "biometric_enabled": true,
      "pin_enabled": true
    },
    "display": {
      "currency_symbol": "Rp",
      "date_format": "DD/MM/YYYY",
      "start_of_week": "monday"
    },
    "sync": {
      "auto_sync": true,
      "sync_frequency": "realtime"
    }
  }
}


### 8.4 Update App Settings

PUT /api/v1/users/settings

**Request Body:**
json
{
  "theme": "dark",
  "notifications": {
    "daily_reminder": true,
    "reminder_time": "20:00"
  }
}


### 8.5 Change Password

POST /api/v1/users/change-password

**Request Body:**
json
{
  "current_password": "oldPassword123",
  "new_password": "newPassword456",
  "confirm_password": "newPassword456"
}


### 8.6 Delete Account

DELETE /api/v1/users/account

**Request Body:**
json
{
  "password": "currentPassword",
  "confirmation_text": "DELETE MY ACCOUNT"
}


---

## 9. Security API

### 9.1 Setup PIN

POST /api/v1/security/pin/setup

**Request Body:**
json
{
  "pin": "123456"
}


### 9.2 Verify PIN

POST /api/v1/security/pin/verify

**Request Body:**
json
{
  "pin": "123456"
}


**Response (200):**
json
{
  "success": true,
  "data": {
    "verified": true,
    "session_token": "temp_session_token",
    "expires_at": "2024-01-15T21:00:00Z"
  }
}


### 9.3 Enable Biometric

POST /api/v1/security/biometric/enable

**Request Body:**
json
{
  "device_id": "device_unique_id",
  "biometric_token": "biometric_signature"
}


### 9.4 Disable Biometric

POST /api/v1/security/biometric/disable

**Request Body:**
json
{
  "pin": "123456"
}


### 9.5 Get Login History

GET /api/v1/security/login-history

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| page | integer | No | Page number (default: 1) |
| limit | integer | No | Items per page (default: 20) |

**Response (200):**
json
{
  "success": true,
  "data": {
    "logins": [
      {
        "id": "uuid",
        "device": "iPhone 15 Pro",
        "ip_address": "192.168.1.1",
        "location": "Jakarta, Indonesia",
        "timestamp": "2024-01-15T14:30:00Z",
        "status": "success"
      }
    ],
    "pagination": {
      "current_page": 1,
      "total_pages": 5,
      "total_items": 100,
      "items_per_page": 20
    }
  }
}


### 9.6 Logout All Devices

POST /api/v1/security/logout-all

**Request Body:**
json
{
  "pin": "123456"
}


---

## 10. Notifications API

### 10.1 Get Notifications

GET /api/v1/notifications

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| type | string | No | Filter by type |
| is_read | boolean | No | Filter by read status |
| page | integer | No | Page number |
| limit | integer | No | Items per page |

**Response (200):**
json
{
  "success": true,
  "data": {
    "notifications": [
      {
        "id": "uuid",
        "type": "savings_milestone",
        "title": "Target Tercapai!",
        "body": "Anda telah mencapai 50% target dana darurat",
        "data": {
          "target_id": "uuid",
          "percentage": 50
        },
        "is_read": false,
        "created_at": "2024-01-15T14:30:00Z"
      }
    ],
    "unread_count": 5,
    "pagination": {
      "current_page": 1,
      "total_pages": 1,
      "total_items": 5,
      "items_per_page": 20
    }
  }
}


### 10.2 Mark Notification as Read

PUT /api/v1/notifications/{id}/read


### 10.3 Mark All Notifications as Read

PUT /api/v1/notifications/read-all


### 10.4 Delete Notification

DELETE /api/v1/notifications/{id}


### 10.5 Register Push Token

POST /api/v1/notifications/push-token

**Request Body:**
json
{
  "token": "push_notification_token",
  "platform": "ios",
  "device_id": "device_unique_id"
}


### 10.6 Delete Push Token

DELETE /api/v1/notifications/push-token


---

## 11. Data Sync API

### 11.1 Get Sync Status

GET /api/v1/sync/status

**Response (200):**
json
{
  "success": true,
  "data": {
    "last_sync": "2024-01-15T14:30:00Z",
    "pending_changes": 0,
    "sync_enabled": true,
    "conflict_resolution": "server_wins"
  }
}


### 11.2 Perform Sync

POST /api/v1/sync

**Request Body:**
json
{
  "last_sync_timestamp": "2024-01-15T14:00:00Z",
  "changes": [
    {
      "entity_type": "transaction",
      "entity_id": "uuid",
      "action": "create",
      "data": {},
      "timestamp": "2024-01-15T14:30:00Z"
    }
  ]
}


**Response (200):**
json
{
  "success": true,
  "data": {
    "sync_timestamp": "2024-01-15T14:35:00Z",
    "server_changes": [],
    "conflicts": [],
    "synced_count": 1
  }
}


### 11.3 Export Data

POST /api/v1/sync/export

**Request Body:**
json
{
  "format": "json",
  "include": ["transactions", "accounts", "investments", "savings"]
}


### 11.4 Import Data

POST /api/v1/sync/import

**Request Body:**
json
{
  "format": "json",
  "data": {},
  "conflict_resolution": "skip"
}


---

## 12. Utility API

### 12.1 Get Exchange Rates

GET /api/v1/utilities/exchange-rates

**Response (200):**
json
{
  "success": true,
  "data": {
    "base_currency": "IDR",
    "rates": {
      "USD": 0.000064,
      "EUR": 0.000059,
      "SGD": 0.000086
    },
    "last_updated": "2024-01-15T14:30:00Z"
  }
}


### 12.2 Get Currency Converter

GET /api/v1/utilities/converter

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| from | string | Yes | Source currency |
| to | string | Yes | Target currency |
| amount | number | Yes | Amount to convert |

**Response (200):**
json
{
  "success": true,
  "data": {
    "from": "IDR",
    "to": "USD",
    "original_amount": 1000000,
    "converted_amount": 64,
    "rate": 0.000064,
    "last_updated": "2024-01-15T14:30:00Z"
  }
}


### 12.3 Upload Receipt

POST /api/v1/utilities/receipts

**Request:** multipart/form-data
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| file | file | Yes | Image file (max 5MB) |
| transaction_id | UUID | No | Link to transaction |

**Response (201):**
json
{
  "success": true,
  "data": {
    "id": "uuid",
    "url": "https://storage.example.com/receipts/uuid.jpg",
    "thumbnail_url": "https://storage.example.com/receipts/uuid_thumb.jpg",
    "ocr_result": {
      "merchant": "Toko ABC",
      "amount": 150000,
      "date": "2024-01-15"
    }
  }
}


---

## 13. Error Handling

### Standard Error Response Format
json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input data",
    "details": [
      {
        "field": "amount",
        "message": "Amount must be a positive number"
      }
    ],
    "request_id": "uuid"
  }
}


### Error Codes
| Code | HTTP Status | Description |
|------|-------------|-------------|
| VALIDATION_ERROR | 400 | Invalid request parameters |
| UNAUTHORIZED | 401 | Authentication required |
| FORBIDDEN | 403 | Insufficient permissions |
| NOT_FOUND | 404 | Resource not found |
| CONFLICT | 409 | Resource conflict |
| RATE_LIMITED | 429 | Too many requests |
| SERVER_ERROR | 500 | Internal server error |

---

## 14. Rate Limiting

| Endpoint Type | Limit | Window |
|---------------|-------|--------|
| Authentication | 5 requests | per minute |
| Read Operations | 100 requests | per minute |
| Write Operations | 30 requests | per minute |
| File Upload | 10 requests | per minute |

**Rate Limit Response Headers:**

X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1705330200


---

## 15. Webhooks

### Supported Events
- `transaction.created`
- `transaction.updated`
- `transaction.deleted`
- `savings.target_reached`
- `investment.price_alert`
- `sync.completed`

### Webhook Payload Format
json
{
  "id": "uuid",
  "event": "transaction.created",
  "timestamp": "2024-01-15T14:30:00Z",
  "data": {}
}


### Register Webhook

POST /api/v1/webhooks

**Request Body:**
json
{
  "url": "https://your-server.com/webhook",
  "events": ["transaction.created", "savings.target_reached"],
  "secret": "webhook_secret_key"
}


---

## 16. API Versioning

Current API Version: **v1**

Versioning Strategy: URL Path
- Base URL: `/api/v1/`

Deprecated versions will be supported for 12 months after a new version release.

### Deprecation Headers

Sunset: Sat, 01 Jan 2025 00:00:00 GMT
Deprecation: true
Link: <https://api.fintrack.app/api/v2>; rel="successor-version"


---

## 17. Appendix

### A. Supported Currencies
| Code | Name | Symbol |
|------|------|--------|
| IDR | Indonesian Rupiah | Rp |
| USD | US Dollar | $ |
| EUR | Euro | € |
| SGD | Singapore Dollar | S$ |

### B. Transaction Categories
**Income:**
- Gaji
- Bonus
- Freelance
- Investasi
- Hadiah
- Lainnya

**Expense:**
- Makanan & Minuman
- Transportasi
- Belanja
- Hiburan
- Kesehatan
- Pendidikan
- Tagihan
- Lainnya

### C. Account Types
| Type | Icon | Description |
|------|------|-------------|
| cash | 💵 | Cash on hand |
| bank | 🏦 | Bank accounts |
| ewallet | 📱 | Digital wallets |
| savings | 🏠 | Savings accounts |
| investment | 📈 | Investment accounts |

### D. Timezone Support
- Asia/Jakarta (UTC+7) - Default
- Asia/Makassar (UTC+8)
- Asia/Jayapura (UTC+9)

---

*Document Version: 1.0*
*Last Updated: 2024-01-15*
*API Base URL: https://api.fintrack.app*



