# 💰 Expense Tracker App

A modern and user-friendly **Expense Tracker Application** built with Flutter. This app helps users manage daily income and expenses, track transactions, monitor their balance, and view monthly financial reports.

## ✨ Features

- 📊 **Dashboard** – View total income, expenses, and current balance.
- 💵 **Income Management** – Add and manage income records.
- 💸 **Expense Management** – Record daily expenses with categories.
- 🗂️ **Custom Categories** – Choose predefined categories or add your own.
- 📝 **Transaction History** – View all income and expense records.
- ✏️ **Edit & Delete** – Update or remove existing transactions.
- 🔍 **Transaction Filtering** – Filter transactions by type and date.
- 📈 **Monthly Reports** – Analyze monthly income and expenses.
- 🥧 **Pie Charts** – Visualize income vs expense percentages and category-wise expenses.
- 👤 **Local User Profile** – Save user information and maintain a local session.
- 💾 **Offline Database** – Store transaction data locally using SQLite.

## 🛠️ Technologies Used

- Flutter
- Dart
- SQLite
- Sqflite
- SharedPreferences
- FL Chart
- Android Studio

## 📂 Project Structure

```text
lib/
├── database/
│   └── db_helper.dart
├── models/
│   └── transaction_model.dart
├── screens/
│   ├── add_transaction_screen.dart
│   ├── history_screen.dart
│   ├── home_screen.dart
│   ├── login_screen.dart
│   └── report_screen.dart
├── widgets/
│   ├── category_helper.dart
│   └── transaction_item.dart
└── main.dart
```

## 🚀 Getting Started

Follow these steps to run the project locally.

**1. Clone the repository**

```bash
git clone https://github.com/arifuldev47/Expense_Tracker.git
```

**2. Open the project folder**

```bash
cd Expense_Tracker
```

**3. Install dependencies**

```bash
flutter pub get
```

**4. Run the application**

```bash
flutter run
```

## 💾 Database

This application uses SQLite for local data storage.

Transaction records include:
- Transaction Title
- Amount
- Income or Expense Type
- Category
- Date
- Description

## 🎯 Project Goal

The goal of this project is to build a complete Flutter application with practical experience in UI development, state management, local database integration, CRUD operations, and data visualization.

## 👨‍💻 Developer

**Ariful Islam**

- GitHub: [@arifuldev47](https://github.com/arifuldev47)
- Project: [Expense Tracker](https://github.com/arifuldev47/Expense_Tracker)

---

⭐ If you find this project useful, consider giving it a star!
