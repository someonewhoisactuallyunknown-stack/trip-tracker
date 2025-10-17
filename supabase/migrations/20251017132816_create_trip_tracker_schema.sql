/*
  # IRSHAD HIGH SCHOOL Trip Tracker Database Schema

  ## Overview
  Complete database schema for school trip tracking system with support for:
  - User management (developers, teachers, students)
  - Group organization and assignments
  - Real-time location tracking
  - Battery monitoring
  - Emergency alerts
  - Distance and direction calculations

  ## Tables Created

  ### 1. `users`
  Stores all app users with their roles and access codes
  - `id` (uuid, primary key): Unique user identifier
  - `access_code` (text, unique): 6-digit code for login
  - `role` (text): User role (developer/teacher/student)
  - `name` (text): User's display name
  - `group_id` (uuid, nullable): Associated group
  - `battery_level` (integer): Current battery percentage (0-100)
  - `is_online` (boolean): Online/offline status
  - `last_active` (timestamptz): Last activity timestamp
  - `created_at` (timestamptz): Account creation time

  ### 2. `groups`
  Manages student groups and teacher assignments
  - `id` (uuid, primary key): Unique group identifier
  - `name` (text): Group name
  - `teacher_id` (uuid): Assigned teacher reference
  - `created_by` (uuid): Developer who created the group
  - `created_at` (timestamptz): Group creation time

  ### 3. `locations`
  Real-time location tracking for all users
  - `id` (uuid, primary key): Location record identifier
  - `user_id` (uuid): User reference
  - `latitude` (double precision): GPS latitude
  - `longitude` (double precision): GPS longitude
  - `accuracy` (double precision): GPS accuracy in meters
  - `heading` (double precision): Device compass heading (0-360)
  - `is_offline_mode` (boolean): Tracking mode indicator
  - `timestamp` (timestamptz): Location capture time

  ### 4. `alerts`
  Emergency alerts and notifications
  - `id` (uuid, primary key): Alert identifier
  - `from_user_id` (uuid): User who triggered alert
  - `to_user_id` (uuid, nullable): Target user (null = broadcast)
  - `alert_type` (text): Alert category (emergency/low_battery/offline)
  - `message` (text): Alert message content
  - `latitude` (double precision): Alert location latitude
  - `longitude` (double precision): Alert location longitude
  - `battery_level` (integer): Battery level at alert time
  - `is_read` (boolean): Read status
  - `created_at` (timestamptz): Alert creation time

  ## Security (Row Level Security)

  All tables have RLS enabled with policies for:
  - Developers: Full access to all data
  - Teachers: Access to their group's students and data
  - Students: Access to own data and their teacher's info
  - Public: No access without authentication

  ## Important Notes

  1. Developer access code is hardcoded as '123456'
  2. Location updates should occur every 10 seconds when active
  3. Battery alerts trigger automatically when level < 15%
  4. Distance calculations use haversine formula (client-side)
  5. All timestamps use UTC timezone
*/

-- Create users table
CREATE TABLE IF NOT EXISTS users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  access_code text UNIQUE NOT NULL,
  role text NOT NULL CHECK (role IN ('developer', 'teacher', 'student')),
  name text NOT NULL,
  group_id uuid,
  battery_level integer DEFAULT 100 CHECK (battery_level >= 0 AND battery_level <= 100),
  is_online boolean DEFAULT true,
  last_active timestamptz DEFAULT now(),
  created_at timestamptz DEFAULT now()
);

-- Create groups table
CREATE TABLE IF NOT EXISTS groups (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  teacher_id uuid REFERENCES users(id) ON DELETE CASCADE,
  created_by uuid REFERENCES users(id),
  created_at timestamptz DEFAULT now()
);

-- Add foreign key for group_id in users
ALTER TABLE users ADD CONSTRAINT users_group_id_fkey 
  FOREIGN KEY (group_id) REFERENCES groups(id) ON DELETE SET NULL;

-- Create locations table
CREATE TABLE IF NOT EXISTS locations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  latitude double precision NOT NULL,
  longitude double precision NOT NULL,
  accuracy double precision DEFAULT 0,
  heading double precision DEFAULT 0 CHECK (heading >= 0 AND heading < 360),
  is_offline_mode boolean DEFAULT false,
  timestamp timestamptz DEFAULT now()
);

-- Create alerts table
CREATE TABLE IF NOT EXISTS alerts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  from_user_id uuid REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  to_user_id uuid REFERENCES users(id) ON DELETE CASCADE,
  alert_type text NOT NULL CHECK (alert_type IN ('emergency', 'low_battery', 'offline', 'safe', 'custom')),
  message text NOT NULL,
  latitude double precision,
  longitude double precision,
  battery_level integer,
  is_read boolean DEFAULT false,
  created_at timestamptz DEFAULT now()
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_users_access_code ON users(access_code);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE INDEX IF NOT EXISTS idx_users_group_id ON users(group_id);
CREATE INDEX IF NOT EXISTS idx_locations_user_id ON locations(user_id);
CREATE INDEX IF NOT EXISTS idx_locations_timestamp ON locations(timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_alerts_to_user_id ON alerts(to_user_id);
CREATE INDEX IF NOT EXISTS idx_alerts_is_read ON alerts(is_read);
CREATE INDEX IF NOT EXISTS idx_alerts_created_at ON alerts(created_at DESC);

-- Enable Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE alerts ENABLE ROW LEVEL SECURITY;

-- RLS Policies for users table
CREATE POLICY "Developers can view all users"
  ON users FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM users AS u
      WHERE u.id = auth.uid() AND u.role = 'developer'
    )
  );

CREATE POLICY "Teachers can view their group students"
  ON users FOR SELECT
  TO authenticated
  USING (
    role = 'developer' OR
    id = auth.uid() OR
    (role = 'student' AND group_id IN (
      SELECT group_id FROM users WHERE id = auth.uid() AND role = 'teacher'
    )) OR
    (role = 'teacher' AND id IN (
      SELECT teacher_id FROM groups WHERE id IN (
        SELECT group_id FROM users WHERE id = auth.uid()
      )
    ))
  );

CREATE POLICY "Users can view themselves"
  ON users FOR SELECT
  TO authenticated
  USING (id = auth.uid());

CREATE POLICY "Developers can insert users"
  ON users FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM users WHERE id = auth.uid() AND role = 'developer'
    )
  );

CREATE POLICY "Users can update own data"
  ON users FOR UPDATE
  TO authenticated
  USING (id = auth.uid())
  WITH CHECK (id = auth.uid());

CREATE POLICY "Developers can update all users"
  ON users FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM users WHERE id = auth.uid() AND role = 'developer'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM users WHERE id = auth.uid() AND role = 'developer'
    )
  );

CREATE POLICY "Developers can delete users"
  ON users FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM users WHERE id = auth.uid() AND role = 'developer'
    )
  );

-- RLS Policies for groups table
CREATE POLICY "Developers can view all groups"
  ON groups FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM users WHERE id = auth.uid() AND role = 'developer'
    )
  );

CREATE POLICY "Teachers can view their groups"
  ON groups FOR SELECT
  TO authenticated
  USING (
    teacher_id = auth.uid() OR
    id IN (SELECT group_id FROM users WHERE id = auth.uid())
  );

CREATE POLICY "Students can view their group"
  ON groups FOR SELECT
  TO authenticated
  USING (
    id IN (SELECT group_id FROM users WHERE id = auth.uid())
  );

CREATE POLICY "Developers can insert groups"
  ON groups FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM users WHERE id = auth.uid() AND role = 'developer'
    )
  );

CREATE POLICY "Developers can update groups"
  ON groups FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM users WHERE id = auth.uid() AND role = 'developer'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM users WHERE id = auth.uid() AND role = 'developer'
    )
  );

CREATE POLICY "Developers can delete groups"
  ON groups FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM users WHERE id = auth.uid() AND role = 'developer'
    )
  );

-- RLS Policies for locations table
CREATE POLICY "Developers can view all locations"
  ON locations FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM users WHERE id = auth.uid() AND role = 'developer'
    )
  );

CREATE POLICY "Teachers can view their group students locations"
  ON locations FOR SELECT
  TO authenticated
  USING (
    user_id IN (
      SELECT id FROM users WHERE group_id IN (
        SELECT group_id FROM users WHERE id = auth.uid() AND role = 'teacher'
      )
    ) OR
    user_id = auth.uid()
  );

CREATE POLICY "Students can view own and teacher location"
  ON locations FOR SELECT
  TO authenticated
  USING (
    user_id = auth.uid() OR
    user_id IN (
      SELECT teacher_id FROM groups WHERE id IN (
        SELECT group_id FROM users WHERE id = auth.uid()
      )
    )
  );

CREATE POLICY "Users can insert own locations"
  ON locations FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own locations"
  ON locations FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- RLS Policies for alerts table
CREATE POLICY "Users can view alerts sent to them"
  ON alerts FOR SELECT
  TO authenticated
  USING (
    to_user_id = auth.uid() OR
    to_user_id IS NULL OR
    from_user_id = auth.uid() OR
    EXISTS (
      SELECT 1 FROM users WHERE id = auth.uid() AND role = 'developer'
    )
  );

CREATE POLICY "Users can insert alerts"
  ON alerts FOR INSERT
  TO authenticated
  WITH CHECK (from_user_id = auth.uid());

CREATE POLICY "Users can update own alerts"
  ON alerts FOR UPDATE
  TO authenticated
  USING (to_user_id = auth.uid() OR from_user_id = auth.uid())
  WITH CHECK (to_user_id = auth.uid() OR from_user_id = auth.uid());

-- Insert developer account
INSERT INTO users (access_code, role, name, battery_level, is_online)
VALUES ('123456', 'developer', 'Developer Admin', 100, true)
ON CONFLICT (access_code) DO NOTHING;
