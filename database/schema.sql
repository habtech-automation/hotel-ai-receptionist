-- Hotel AI Receptionist: Supabase (Postgres) schema
-- Run this once in the Supabase SQL Editor.

-- Room types and how many rooms of each type the hotel has
create table rooms (
  id uuid primary key default gen_random_uuid(),
  room_type text not null,
  rate numeric not null,
  total_rooms int not null,
  amenities text
);

-- Reservations. status is 'confirmed' or 'cancelled'.
-- confirmation_id is only created when a booking is actually saved,
-- and the AI agent may only say "confirmed" when it gets one back.
create table bookings (
  id uuid primary key default gen_random_uuid(),
  booking_id text unique not null,
  guest_name text not null,
  room_type text not null,
  check_in date not null,
  check_out date not null,
  status text not null default 'confirmed',
  confirmation_id text unique not null,
  created_at timestamptz default now()
);

-- Requests the AI hands over to hotel staff
create table escalations (
  id uuid primary key default gen_random_uuid(),
  escalation_id text unique not null,
  guest_name text not null,
  contact text not null,
  request_details text not null,
  department text not null default 'Front Desk',
  urgency text not null default 'normal',
  status text not null default 'open',
  created_at timestamptz default now()
);

-- Every workflow failure caught by the Global Error Handler
create table error_logs (
  id uuid primary key default gen_random_uuid(),
  workflow_name text,
  workflow_id text,
  node_name text,
  error_message text,
  execution_url text,
  occurred_at timestamptz default now()
);

-- Demo rooms (match the sample knowledge base)
insert into rooms (room_type, rate, total_rooms, amenities) values
  ('Standard', 60, 10, 'Wi-Fi, AC'),
  ('Deluxe', 90, 6, 'Wi-Fi, AC, Balcony'),
  ('Suite', 150, 3, 'Wi-Fi, AC, Balcony, Living area'),
  ('Family', 120, 4, 'Wi-Fi, AC, 2 beds');
