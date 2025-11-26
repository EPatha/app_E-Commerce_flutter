import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('warung_ajib.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const realType = 'REAL NOT NULL';

    await db.execute('''
CREATE TABLE products (
  id $idType,
  name $textType,
  image $textType,
  description $textType,
  price $realType
)
''');
  }

  // Create
  Future<Product> createProduct(Product product) async {
    final db = await instance.database;
    final id = await db.insert('products', product.toMap());
    return product.copy(id: id.toString());
  }

  // Read all products
  Future<List<Product>> readAllProducts() async {
    final db = await instance.database;
    const orderBy = 'id ASC';
    final result = await db.query('products', orderBy: orderBy);
    return result.map((json) => Product.fromMap(json)).toList();
  }

  // Read single product
  Future<Product?> readProduct(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Product.fromMap(maps.first);
    } else {
      return null;
    }
  }

  // Update
  Future<int> updateProduct(Product product) async {
    final db = await instance.database;
    return db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  // Delete
  Future<int> deleteProduct(String id) async {
    final db = await instance.database;
    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Close database
  Future close() async {
    final db = await instance.database;
    db.close();
  }

  // Seed initial data
  Future<void> seedInitialData() async {
    final products = await readAllProducts();
    if (products.isEmpty) {
      // Insert initial products
      await createProduct(Product(
        id: '',
        name: 'Sate',
        image: 'assets/images/Sate.jpg',
        description: 'Sate enak, bumbu kacang khas.',
        price: 25000,
      ));
      await createProduct(Product(
        id: '',
        name: 'Soto Ayam Kuning',
        image: 'assets/images/Soto-Ayam-Kuning.jpg',
        description: 'Soto hangat dengan kuah kuning.',
        price: 20000,
      ));
      await createProduct(Product(
        id: '',
        name: 'Bubur Ayam',
        image: 'assets/images/Bubur-Ayam.jpg',
        description: 'Bubur lembut dengan topping ayam.',
        price: 15000,
      ));
      await createProduct(Product(
        id: '',
        name: 'Es Teh Ajib Jumbo',
        image: 'assets/images/Estehajib-Jumbo.jpg',
        description: 'Segar, manis, porsi jumbo.',
        price: 8000,
      ));
      await createProduct(Product(
        id: '',
        name: 'Steak Enak',
        image: 'assets/images/Steak-enak.jpg',
        description: 'Steak medium rare dengan saus spesial.',
        price: 75000,
      ));
      await createProduct(Product(
        id: '',
        name: 'Lumpia',
        image: 'assets/images/Lumpia.jpg',
        description: 'Lumpia renyah dengan isi sayur dan daging, cocok untuk cemilan.',
        price: 12000,
      ));
    }
  }
}
