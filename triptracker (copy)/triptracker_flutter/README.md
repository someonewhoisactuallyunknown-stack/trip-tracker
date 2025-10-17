# Triptracker Flutter (scaffold)

Minimal scaffold for IRSHAD HIGH SCHOOL Trip Tracker.

Features included:
- Code-based login (Developer code: 123456)
- Developer dashboard: generate teacher and student codes (in-memory)
- Teacher and Student dashboard stubs

How to run locally:

1. Install Flutter SDK: https://flutter.dev/docs/get-started/install
2. From project directory run:

```bash
flutter pub get
flutter run
```

Notes:
- This scaffold uses in-memory storage for codes. Later we'll add Hive/SQLite for persistence.
- Many production features (Bluetooth mesh, background tracking, Firebase) are planned but not yet implemented in this scaffold.
