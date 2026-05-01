# 🚂 RailSensus — Platform Crowdsourcing Sensus Kereta Api

<p align="center">
  <img src="frontend/assets/images/RailSensus_Logo.png" alt="RailSensus Logo" width="200"/>
</p>

**RailSensus** adalah aplikasi mobile berbasis crowdsourcing yang memungkinkan pengguna untuk melakukan sensus dan pelaporan kondisi sarana perkeretaapian di Indonesia secara kolaboratif dan real-time.

---

## 📋 Problem Statement

Saat ini, proses pendataan dan pemantauan kondisi sarana perkeretaapian (lokomotif dan kereta api) masih dilakukan secara manual dan terpusat oleh pihak pengelola. Hal ini menimbulkan beberapa permasalahan:

1. **Keterlambatan Data** — Informasi kondisi sarana tidak diperbarui secara real-time, sehingga pengambilan keputusan menjadi lambat.
2. **Keterbatasan Sumber Daya** — Jumlah petugas yang terbatas tidak mampu menjangkau seluruh armada yang tersebar di berbagai lokasi.
3. **Kurangnya Partisipasi Publik** — Masyarakat dan railfans memiliki pengetahuan yang berharga namun tidak memiliki wadah untuk berkontribusi.
4. **Validitas Data** — Tidak ada mekanisme verifikasi komunitas terhadap data yang dilaporkan.

**RailSensus** hadir sebagai solusi dengan memanfaatkan pendekatan **crowdsourcing**, di mana seluruh pengguna dapat berkontribusi melaporkan kondisi sarana kereta api, memberikan voting trust score untuk memvalidasi laporan, serta membantu admin dalam pengelolaan data secara efisien.

---

## ✨ Daftar Fitur

### 🔐 Autentikasi & Profil
- Registrasi dan login pengguna dengan JWT
- Edit profil (username, email) dan ubah password
- Upload dan hapus foto profil
- Galeri foto kontribusi pengguna
- Rate limiting pada endpoint autentikasi

### 🚄 Manajemen Sarana Lokomotif
- Daftar lokomotif dengan pencarian dan paginasi
- Tambah data lokomotif baru dengan foto
- Edit dan hapus data lokomotif
- Detail lokomotif lengkap dengan galeri foto
- Informasi depo induk, livery, sumber tenaga, dan status operasi

### 📋 Sensus Kereta Api
- Form sensus dengan pemilihan kereta dan nomor kereta
- Upload foto bukti sensus (fallback ke foto lokomotif)
- Detail sensus dengan informasi lokasi via reverse geocoding (Overpass API)
- Voting trust score (Valid/Invalid) oleh komunitas
- Data sensus otomatis kadaluarsa setelah 12 jam (cron job)
- Validasi: lokomotif tidak siap operasi tidak dapat ditambahkan

### 📊 Dashboard Pengguna
- Statistik kontribusi pribadi (total sensus, lokomotif, trust score)
- Sensus terbaru oleh pengguna
- Navigasi cepat ke fitur utama

### 🛡️ Panel Admin
- Dashboard admin dengan statistik Bento UI (total user, sensus, laporan)
- Master data kereta (CRUD dengan paginasi, multi-input nomor kereta)
- Master data depo (CRUD dengan validasi duplikasi)
- Master data pengguna (CRUD, ubah role, reset password)
- Validasi duplikasi pada nomor kereta dan kode/nama depo

### 📝 Sistem Pelaporan
- User melaporkan permintaan hapus lokomotif/sensus ke admin
- Admin menyetujui atau menolak laporan
- Riwayat laporan dengan paginasi
- Bersihkan riwayat laporan disetujui dan ditolak (terpisah)
- Laporan yang disetujui tidak terhapus dari riwayat

### 🎨 UI/UX
- Design modern dan premium dengan warna khas navy (#153D77)
- Font kustom Plus Jakarta Sans
- Custom snackbar notifikasi yang konsisten
- Custom dialog dengan desain yang seragam
- Animasi splash screen
- Shimmer loading effect
- Responsive bottom navigation bar

### 🧪 Testing
- Test suite CRUD komprehensif untuk seluruh API backend (58 test cases)
- Pengujian autentikasi, otorisasi, validasi, dan error handling

---

## 🛠️ Teknologi yang Digunakan

| Komponen | Teknologi |
|----------|-----------|
| **Frontend** | Flutter (Dart), BLoC Pattern |
| **Backend** | Node.js, Express.js |
| **Database** | MySQL, Sequelize ORM |
| **Autentikasi** | JWT (JSON Web Token), bcrypt |
| **File Upload** | Multer |
| **Geocoding** | Overpass API (OpenStreetMap) |
| **State Management** | flutter_bloc |
| **Navigasi** | GoRouter |
| **HTTP Client** | Dio |
| **Cron Job** | node-cron |
| **Validasi** | Joi |

---

## 📅 Progress Mingguan

### Minggu 1 (1 – 7 Mei 2026)
> Perencanaan dan perancangan arsitektur aplikasi

- Perancangan arsitektur sistem (backend REST API + frontend Flutter)
- Perancangan skema database (User, Lokomotif, Kereta, Sensus, Vote, Depo)
- Membuat dokumen kebutuhan fungsional dan non-fungsional

### Minggu 2 (8 – 14 Mei 2026)
> Setup proyek dan implementasi backend dasar

- Inisialisasi proyek backend Node.js dengan Express
- Konfigurasi Sequelize ORM dan koneksi database MySQL
- Membuat model dan migrasi database
- Implementasi sistem autentikasi (register/login) dengan JWT dan bcrypt

### Minggu 3 (15 – 21 Mei 2026)
> Implementasi CRUD backend dan fondasi frontend

- Membuat CRUD API lokomotif dengan upload foto
- Membuat CRUD API sensus dan voting trust score
- Inisialisasi proyek Flutter dengan arsitektur BLoC
- Membuat halaman splash, landing, login, dan register
- Implementasi navigasi GoRouter dan bottom navigation bar
- Membuat halaman daftar & detail lokomotif
- Membuat form tambah/edit lokomotif
- Membuat halaman daftar & detail sensus
- Membuat form tambah sensus dengan pemilihan kereta bertingkat
- Implementasi fitur voting trust score pada sensus

### Minggu 4 (22 – 28 Mei 2026)
> Fitur admin, profil, dan pelaporan

- Membuat halaman profil pengguna (edit profil, ubah password, foto profil)
- Membuat dashboard admin dengan statistik Bento UI
- Membuat CRUD master data kereta dengan paginasi
- Membuat CRUD master data depo dan pengguna
- Membuat sistem pelaporan penghapusan lokomotif dan sensus
- Membuat halaman manajemen laporan admin (setujui/tolak)
- Implementasi cron job pembersihan data sensus kadaluarsa
- Integrasi Overpass API untuk reverse geocoding
- Menambahkan Terms of Service

### Minggu 5 (29 Mei – 4 Juni 2026)
> Perbaikan UI card dan detail page

- Redesign UI card lokomotif dan sensus menjadi lebih premium
- Perapihan UI halaman detail lokomotif dan detail sensus
- Penerapan font Plus Jakarta Sans secara konsisten
- Perapihan UI halaman sensus feed

### Minggu 6 (5 – 11 Juni 2026)
> Perbaikan bug dan stabilitas

- Perbaikan bug rate limiting dan state management sensus
- Perbaikan validasi update sensus

### Minggu 7 (12 – 18 Juni 2026)
> Maintenance dan penyesuaian jaringan

- Penyesuaian konfigurasi base URL untuk testing di berbagai jaringan
- Perbaikan paginasi pada pencarian lokomotif

### Minggu 8 (19 – 21 Juni 2026)
> Polish final, validasi, dan testing

- Redesign form lokomotif dan sensus menjadi halaman terpisah (full-page)
- Perbaikan sinkronisasi skor trust score antara card dan detail
- Implementasi custom dialog dan custom snackbar yang konsisten
- Redesign dashboard pengguna menjadi lebih fungsional
- Redesign animasi splash screen
- Perbaikan UI halaman laporan (paginasi + bersihkan riwayat terpisah)
- Menambahkan validasi duplikasi pada master kereta dan depo
- Penambahan fitur multi-input nomor kereta
- Perbaikan route halaman form lokomotif
- Pembersihan file yang tidak terpakai (frontend & backend)
- Membuat test suite CRUD komprehensif (58 test cases)

---

## 🚀 Cara Menjalankan

### Prasyarat
- Node.js v18+
- MySQL
- Flutter SDK v3.x
- Android SDK / Emulator

### Backend
```bash
cd backend
npm install
# Konfigurasi file .env (sesuaikan DB_USERNAME, DB_PASSWORD, dll.)
npm run dev
```

### Frontend
```bash
cd frontend
flutter pub get
# Konfigurasi file .env (sesuaikan API_BASE_URL)
flutter run
```

### Testing
```bash
cd backend
node tests/crud_test.js
```

---

## 👤 Pengembang

**Arya Bagas Saputra**

---

## 📄 Lisensi

Proyek ini dibuat untuk keperluan tugas mata kuliah **Pengembangan Aplikasi Mobile Lanjut (PAML)**.
