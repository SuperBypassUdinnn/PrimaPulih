# PrimaPulih

**Platform Monitoring Pemulihan Pasca-ICU**

PrimaPulih adalah aplikasi telemedicine terpadu yang didesain khusus untuk mendampingi penyintas perawatan intensif (ICU) pada masa pemulihan. Aplikasi ini menjembatani komunikasi asinkron antara pasien dan tenaga kesehatan dengan fokus pada pencatatan psikologis mandiri (PHQ-9 & GAD-7) serta rutinitas harian pasien secara sederhana dan efisien.

## Fitur Utama

* **Autentikasi & Manajemen Akun**: Pemisahan hak akses antara Pasien dan Tenaga Kesehatan (Health Worker).
* **Asesmen Psikologis Mandiri (P0)**: Pengisian instrumen skrining terstandar PHQ-9 (Depresi) dan GAD-7 (Kecemasan) oleh pasien via aplikasi.
* **Dashboard Tenaga Kesehatan (P0)**: Tenaga kesehatan dapat melihat daftar pasien, skor asesmen, dan rekam jejak kondisinya.
* **Mood Tracker Harian (P1)**: Pasien dapat mencatat jurnal afeksi (mood) setiap harinya.
* **Checklist Obat (P1)**: Pencatatan kepatuhan konsumsi obat pasien secara mandiri.

## Tech Stack

* **Frontend**: Flutter (Mobile App)
* **Backend**: Golang (menggunakan Fiber Framework)
* **Database**: PostgreSQL
* **Infrastruktur**: Docker & Docker Compose

## Cara Menjalankan Proyek (Lokal)

Proyek ini telah dikonfigurasi menggunakan Docker Compose, sehingga proses setup sangat mudah dan tidak memerlukan instalasi manual untuk Go maupun PostgreSQL di komputer Anda.

### Prasyarat
Komputer telah terpasang Docker dan Docker Compose.

### Langkah Instalasi

1. **Buka Terminal di Direktori Proyek**
   Pastikan Anda berada di root direktori PrimaPulih.

2. **Jalankan Docker Compose**
   Perintah ini akan mendownload image, menginisialisasi database PostgreSQL (termasuk menjalankan skema tabel awal), dan melakukan build untuk backend Golang secara bersamaan.
   ```bash
   docker compose up -d --build
   ```

3. **Verifikasi**
   Setelah kontainer selesai dibangun dan berjalan, backend API sudah aktif dan dapat diakses pada alamat:
   ```
   http://localhost:8080
   ```
   Database PostgreSQL berjalan pada port 5435.

### (Opsional) Pengembangan Backend Tanpa Docker (Native)
Jika Anda ingin mengubah kode Golang dan menjalankannya secara native:
1. Pastikan service database via Docker sudah menyala.
2. Pindah ke folder backend:
   ```bash
   cd backend_go
   ```
3. Unduh dependency Go:
   ```bash
   go mod tidy
   ```
4. Jalankan aplikasi:
   ```bash
   go run main.go
   ```

## Ringkasan API Endpoints

Semua endpoint berawalan `http://localhost:8080/api/`. Endpoint yang diproteksi memerlukan Header `Authorization: Bearer <token>`.

### Auth (Publik)
* `POST /auth/register` : Mendaftarkan pengguna baru (Role: patient atau health_worker).
* `POST /auth/login` : Autentikasi untuk mendapatkan token JWT.

### Asesmen (P0)
* `POST /assessments` : Submit hasil asesmen (Akses: Patient).
* `GET /assessments` : Melihat riwayat skor asesmen pasien (Akses: Health Worker).

### Jurnal Harian & Obat (P1)
* `POST /daily-logs` : Submit jurnal mood hari ini (Akses: Patient).
* `GET /daily-logs` : Mengambil data riwayat mood.
* `POST /medications` : Menambahkan master daftar obat.
* `GET /medications` : Mengambil master daftar obat pasien.
* `POST /medication-logs` : Mencentang obat yang telah diminum pada hari tersebut (Akses: Patient).

## Catatan Tambahan
Struktur skema database proyek ini berada di direktori `database/0001_initial_schema.sql` dan secara otomatis dieksekusi oleh PostgreSQL saat kontainer pertama kali dijalankan.
