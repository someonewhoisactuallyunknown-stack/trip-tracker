# IRSHAD HIGH SCHOOL Trip Tracker

A comprehensive cross-platform mobile application designed to ensure safety and tracking of students and teachers during school trips for **IRSHAD HIGH SCHOOL, CHANGALEERI, MANNARKKAD**.

## Features

### Core Functionality
- Real-time Location Tracking with GPS
- Online & Offline Modes (Bluetooth/Wi-Fi Direct)
- Distance Calculation between users
- Direction Indicators with compass arrows
- Battery Monitoring with alerts
- Emergency Alert System
- Role-Based Access Control

### User Roles

#### Developer (Admin) - Access Code: `123456`
- Generate codes for teachers and students
- View all users' locations on map
- Monitor battery levels and alerts
- Manage groups and access control

#### Teacher
- View students in their group
- See distance and direction to each student
- Monitor battery levels
- Send and receive alerts
- Switch between online/offline tracking

#### Student
- Share location and battery level
- See distance and direction to teacher
- Emergency HELP button
- View group information

## Quick Start

1. **Install Dependencies**
   ```bash
   flutter pub get
   ```

2. **Run the App**
   ```bash
   flutter run
   ```

3. **Login as Developer**
   - Use code: `123456`
   - Generate teacher codes with group names
   - Generate student codes for each group

## Technical Stack

- **Framework**: Flutter
- **Database**: Supabase (PostgreSQL with real-time)
- **Location**: Geolocator with GPS
- **Sensors**: Compass, Battery monitoring
- **Offline**: Bluetooth/Wi-Fi Direct capability

## Database Features

- Real-time location updates
- Row Level Security (RLS)
- Automatic battery alerts when <15%
- Emergency alert system
- Distance calculations using Haversine formula

## Permissions Required

- Location (Fine, Coarse, Background)
- Bluetooth (for offline mode)
- Internet (for online sync)
- Wi-Fi State (for peer-to-peer)

## Key Services

- `SupabaseService`: Database and real-time sync
- `LocationService`: GPS tracking and distance calculation
- `BatteryService`: Battery monitoring
- `CompassService`: Direction arrows
- `CodeService`: Access code management

For detailed documentation, see the full README in the project root.

---

**Developed for IRSHAD HIGH SCHOOL, CHANGALEERI, MANNARKKAD**
