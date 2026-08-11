# Smart Dress Shop POS & Business Management Application

A production-quality commercial POS and business management solution specifically designed for dress and clothing retail shops.

---

## Technical Stack Overview

### Mobile Client (`/mobile`)
- **Framework**: Flutter 3.x with Dart 3.x
- **UI & Theme**: Material 3 Design System with Outfit & Inter typography
- **State Management**: Flutter Riverpod (`flutter_riverpod`)
- **Navigation**: GoRouter with authentication guards and shell bottom navigation
- **HTTP Client**: Dio with authorization interceptor & error handlers
- **Storage**: `flutter_secure_storage` for encrypted token storage

### Backend API (`/server`)
- **Runtime**: Node.js & Express.js with TypeScript (`strict: true`)
- **Database**: MongoDB with Mongoose ODM
- **Authentication**: JWT authentication & Bcrypt password hashing
- **Authorization**: Role-based access control (`ADMIN`, `MANAGER`, `CASHIER`, `STOCK_STAFF`, `VIEWER`)
- **Security**: Helmet headers, CORS policies, Rate limiting, input validation via Zod
- **Audit Logging**: Comprehensive Audit Trail logger

---

## Directory Structure

```text
d:\DRESS APP\
├── server/                   # Node.js + Express + TypeScript Backend
│   ├── src/
│   │   ├── config/           # DB & Environment variables config
│   │   ├── middleware/       # Auth, Role, Error & Validation middlewares
│   │   ├── modules/          # Domain modules (Auth, Users, Roles, Audit)
│   │   ├── utils/            # JWT, Password, API error/response handlers
│   │   ├── scripts/          # Seed script for initial roles & users
│   │   ├── app.ts            # Express App initialization
│   │   └── server.ts         # Entry point server runner
│   ├── tsconfig.json
│   └── package.json
│
├── mobile/                   # Flutter Clean Architecture Client
│   ├── lib/
│   │   ├── core/             # Network, Storage, Theme, Constants, Routing
│   │   ├── features/         # Auth, Dashboard, POS, Inventory, Sales, More
│   │   ├── shared/           # Shared UI widgets (Buttons, Inputs, Cards, Shell)
│   │   └── main.dart
│   └── pubspec.yaml
│
└── README.md
```

---

## Setup & Running Instructions

### 1. Start Backend REST API
```bash
cd "d:\DRESS APP\server"
npm install
npm run dev
```

### 2. Seed Initial Database Roles & Super Admin
With the server running or via ts-node:
```bash
npm run seed
```
This populates standard system roles and initial accounts:
- **Super Admin**: `admin@smartdress.com` / `Admin@123456`
- **Main Cashier**: `cashier@smartdress.com` / `Cashier@123456`
- **Store Manager**: `manager@smartdress.com` / `Manager@123456`

### 3. Run Flutter Application
```bash
cd "d:\DRESS APP\mobile"
flutter pub get
flutter run -d chrome
```

---

## Verification Check

1. Backend Health Check: `GET http://localhost:5000/health`
2. Authentication API: `POST http://localhost:5000/api/v1/auth/login`
3. Mobile App Flutter navigation flow from Splash -> Login Screen -> Dashboard.
