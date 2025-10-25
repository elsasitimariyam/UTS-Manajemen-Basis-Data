-- =======================================================
-- 1. CLEANUP (Untuk memastikan skrip dapat dijalankan ulang)
-- =======================================================

-- Pindahkan kepemilikan objek apa pun sebelum menghapus role/user (Penting!)
ALTER TABLE IF EXISTS SALAM.mahasiswa OWNER TO postgres;

-- Hapus User/Role yang sudah dibuat
DROP USER IF EXISTS bi_dev;
DROP USER IF EXISTS data_engineer_user;
DROP ROLE IF EXISTS backend_dev;
DROP ROLE IF EXISTS data_engineer;
DROP ROLE IF EXISTS bi_dev; -- Hapus duplikat jika ada

-- Hapus Skema dan semua objek di dalamnya (CASCADE)
DROP SCHEMA IF EXISTS SALAM CASCADE;


-- =======================================================
-- 2. SOAL 3: SKEMA DAN TABEL
-- =======================================================
-- Buat skema SALAM
CREATE SCHEMA SALAM;

-- Buat tabel mahasiswa (TANPA primary key, unique, atau check constraint)
CREATE TABLE SALAM.mahasiswa (
    nim VARCHAR(15), 
    nama VARCHAR(100), 
    angkatan INT,
    ipk NUMERIC(3, 2)
);

-- Masukkan data sampel untuk pengujian
INSERT INTO SALAM.mahasiswa (nim, nama) VALUES ('999', 'Data Bukti');


-- =======================================================
-- 3. SOAL 4: DEFINISI ROLES DAN USERS
-- =======================================================

-- A. Role: backend_dev (CRUD semua table)
CREATE ROLE backend_dev NOLOGIN;
CREATE USER backend_dev_user WITH PASSWORD 'backend_pass'; -- Asumsi user dibuat
GRANT backend_dev TO backend_dev_user;

-- B. Role: bi_dev (Read/Select semua table/view)
CREATE ROLE bi_dev NOLOGIN;
CREATE USER bi_dev_user WITH PASSWORD 'bidev_pass';
GRANT bi_dev TO bi_dev_user;

-- C. Role: data_engineer (CREATE, MODIFY, DROP semua objects, CRUD semua table)
CREATE ROLE data_engineer NOLOGIN;
CREATE USER data_engineer_user WITH PASSWORD 'dataeng_pass';
GRANT data_engineer TO data_engineer_user;


-- =======================================================
-- 4. SOAL 4: GRANT HAK AKSES
-- =======================================================

-- A. Backend_dev (CRUD)
GRANT ALL PRIVILEGES ON DATABASE db_elsa TO backend_dev; -- Asumsi database db_elsa
GRANT ALL PRIVILEGES ON SCHEMA SALAM TO backend_dev;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA SALAM TO backend_dev;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA SALAM TO backend_dev;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA SALAM GRANT ALL ON TABLES TO backend_dev;


-- B. BI_DEV (READ/SELECT ONLY)
-- HAK AKSES PENTING: USAGE pada skema dan SELECT pada tabel
GRANT USAGE ON SCHEMA SALAM TO bi_dev;
GRANT SELECT ON ALL TABLES IN SCHEMA SALAM TO bi_dev;


-- C. DATA_ENGINEER (ALL PRIVILEGES)
-- HAK AKSES PENTING: USAGE pada skema, ALL pada database dan skema
GRANT ALL PRIVILEGES ON DATABASE db_elsa TO data_engineer;
GRANT ALL PRIVILEGES ON SCHEMA SALAM TO data_engineer;

-- Semua hak pada objek yang sudah ada
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA SALAM TO data_engineer;

-- Semua hak pada objek baru (dari pemilik skema: postgres)
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA SALAM GRANT ALL ON TABLES TO data_engineer;

-- KOREKSI FINAL PENTING: Pindahkan Kepemilikan Tabel ke Role Data Engineer (karena ALTER TABLE gagal tanpa ini)
ALTER TABLE SALAM.mahasiswa OWNER TO data_engineer;