CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ==========================================
-- 1. MANAJEMEN PENGGUNA SENTRAL
-- ==========================================

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(50) CHECK (role IN ('patient', 'health_worker')) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE patients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    full_name VARCHAR(255) NOT NULL,
    icu_discharge_date DATE NOT NULL
);

CREATE TABLE health_workers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    full_name VARCHAR(255) NOT NULL,
    specialization VARCHAR(255)
);

-- ==========================================
-- 2. ENGINE ASESMEN KLINIS (P0)
-- ==========================================

CREATE TABLE assessments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
    type VARCHAR(50) CHECK (type IN ('PHQ-9', 'GAD-7')) NOT NULL,
    total_score INT NOT NULL,
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================
-- 3. TRACKER KEPATUHAN HARIAN (P1)
-- ==========================================

CREATE TABLE daily_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
    mood_emoji VARCHAR(50),
    logged_at DATE DEFAULT CURRENT_DATE,
    -- Mencegah pasien submit jurnal mood lebih dari 1 kali di hari yang sama
    UNIQUE(patient_id, logged_at) 
);

CREATE TABLE medications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
    medicine_name VARCHAR(255) NOT NULL,
    time_of_day VARCHAR(50) CHECK (time_of_day IN ('morning', 'afternoon', 'night')) NOT NULL
);

CREATE TABLE medication_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    medication_id UUID NOT NULL REFERENCES medications(id) ON DELETE CASCADE,
    status BOOLEAN DEFAULT FALSE,
    logged_at DATE DEFAULT CURRENT_DATE,
    -- Mencegah duplikasi centang obat di hari yang sama
    UNIQUE(medication_id, logged_at) 
);

-- ==========================================
-- INDEXING (Optimalisasi Query Dasar)
-- ==========================================
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_assessments_patient_id ON assessments(patient_id);
CREATE INDEX idx_medications_patient_id ON medications(patient_id);