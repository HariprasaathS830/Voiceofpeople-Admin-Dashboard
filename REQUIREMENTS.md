# Requirements and Run Steps

This project has two runnable parts:

- Flutter app in the repository root
- Node.js backend in `backend/`

## Prerequisites

- Flutter SDK compatible with Dart `^3.11.0`
- Node.js 18 or newer
- Firebase project configured for the Flutter app and backend

## Flutter App

Install dependencies:

```bash
flutter pub get
```

Run the app:

```bash
flutter run
```

The app initializes Firebase from `lib/firebase_options.dart`, so no placeholder values are needed in `lib/main.dart`.

## Backend

Install backend dependencies:

```bash
cd backend
npm install
```

Start the backend in development mode:

```bash
npm run dev
```

Start it in production mode:

```bash
npm start
```

## Firebase Backend File

The backend expects `backend/src/serviceAccountKey.json` to exist locally. That file is ignored by git, so generate or copy it from your Firebase service account credentials before starting the backend.