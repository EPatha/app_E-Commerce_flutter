# PRAKTIKUM #9 - SQLite Integration

## Perubahan yang Dilakukan

### 1. **Dependencies Baru**
Ditambahkan ke `pubspec.yaml`:
```yaml
sqflite: ^2.2.8+4
path: ^1.8.3
```

### 2. **Database Helper** (`lib/helpers/database_helper.dart`)
- Singleton pattern untuk manage database connection
- CRUD operations: Create, Read, Update, Delete
- Auto-seed 6 produk awal jika database kosong
- Database file: `warung_ajib.db`

### 3. **Product Model Update** (`lib/models/product.dart`)
- Tambah method `toMap()` untuk convert Product ke Map (SQLite)
- Tambah factory `fromMap()` untuk create Product dari Map
- Tambah method `copy()` untuk clone/update Product
- Hapus `demoProducts` array (diganti dengan database)

### 4. **Dashboard Screen Update** (`lib/screens/dashboard_screen.dart`)
- Load produk dari database saat initState
- Tambah loading indicator
- Tambah menu "Tambah Produk" di PopupMenu
- Setiap card produk ada menu Edit & Hapus (icon titik tiga)
- Auto-refresh setelah tambah/edit/hapus produk

### 5. **Payment Screen Update** (`lib/screens/payment_screen.dart`)
- Load produk dari database untuk display di list pesanan
- Perhitungan total tetap dinamis dari database

### 6. **Add/Edit Product Screen** (`lib/screens/add_edit_product_screen.dart`)
File baru untuk CRUD produk:
- Form input: Nama, Path Gambar, Deskripsi, Harga
- Validation untuk semua field
- Support mode Add (produk baru) dan Edit (update produk)

## Fitur CRUD Produk

### Tambah Produk
1. Tap menu titik tiga (⋮) di pojok kanan atas
2. Pilih "Tambah Produk"
3. Isi form dan tekan "Tambah Produk"

### Edit Produk
1. Tap icon titik tiga (⋮) di card produk
2. Pilih "Edit"
3. Update data dan tekan "Update Produk"

### Hapus Produk
1. Tap icon titik tiga (⋮) di card produk
2. Pilih "Hapus"
3. Konfirmasi di dialog

## Struktur Database

**Table: products**
| Column | Type | Constraint |
|--------|------|------------|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT |
| name | TEXT | NOT NULL |
| image | TEXT | NOT NULL |
| description | TEXT | NOT NULL |
| price | REAL | NOT NULL |

## Testing

Jalankan aplikasi:
```bash
flutter pub get
flutter run
```

Analyzer passed tanpa error:
```bash
flutter analyze
# No issues found!
```

## Fitur yang Sudah Diimplementasi (Sesuai Ketentuan)

✅ 1. Splashscreen  
✅ 2. Halaman login & register  
✅ 3. Dashboard daftar produk (dinamis dari SQLite)  
✅ 3a. Menu pojok kanan atas (Call Center, SMS Center, Maps, Update User & Password, **Tambah Produk**)  
✅ 3b. Tap nama produk → deskripsi produk  
✅ 3c. Tap gambar → tambah ke keranjang  
✅ 3d. Tap total penjualan → form pembayaran  
✅ **BONUS**: Edit & Hapus produk (menu di setiap card)

## Catatan Penting

- Database dibuat otomatis saat pertama kali run aplikasi
- Data awal (6 produk) di-seed otomatis jika database kosong
- Path gambar harus diisi manual (contoh: `assets/images/produk.jpg`)
- Pastikan gambar sudah ada di folder `assets/images/` dan didaftarkan di `pubspec.yaml`
