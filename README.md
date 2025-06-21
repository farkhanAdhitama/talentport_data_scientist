# Talenport Data Scientist Project

## Struktur Proyek

- `analysis.sql` : Analisis data menggunakan SQL.
- `notebooks/` : Notebook Jupyter untuk EDA, modelling, dan interpretasi.
- `validation.R` : Validasi model dan analisis statistik menggunakan R.
- `data/` : Dataset yang digunakan.

---

## Cara Menjalankan

### 1. Menjalankan `analysis.sql`

1. Pastikan Anda memiliki SQLite atau DBMS yang sesuai.
2. Buka database, Jika menggunakan SQLite di VScode, cari `SQLite : Open Database`
3. Buka `analysis.sql`, lalu run query

---

### 2. Menjalankan Notebook Jupyter

1. Pastikan Python dan Jupyter Notebook sudah terpasang.
2. Pastikan dependensi sudah terinstall
3. Jalankan notebook
4. Buka dan eksekusi file di folder `notebooks/` seperti `B_modelling.ipynb`.

---

### 3. Menjalankan Validasi R (`validation.R`)

1. Pastikan R sudah terpasang di komputer Anda. Bisa gunakan extension R di vscode
2. Install package yang diperlukan (otomatis di-handle di script).
3. Jalankan script:
   ```sh
   Rscript validation.R
   ```
   Jika menggunakan VScode, gunakan `run source` atau `ctrl + shift + S`

## Catatan

- Pastikan file data tersedia di folder `data/
- Pastikan sudah menginstal R

---
