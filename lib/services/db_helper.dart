import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/property.dart';
import '../models/booking.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'rental_app.db');
    return await openDatabase(
      path,
      version: 3, // UPGRADED to v3 for rentalType + bookingCode
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        password TEXT NOT NULL,
        role TEXT NOT NULL
      )
    ''');

    // Properties table with new columns
    await db.execute('''
      CREATE TABLE properties (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        location TEXT NOT NULL,
        price REAL NOT NULL,
        description TEXT,
        imagePath TEXT,
        status TEXT DEFAULT 'available',
        ownerId INTEGER,
        createdAt TEXT,
        FOREIGN KEY (ownerId) REFERENCES users(id)
      )
    ''');

    // Bookings table (NEW!)
    await db.execute('''
      CREATE TABLE bookings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        propertyId INTEGER NOT NULL,
        tenantId INTEGER NOT NULL,
        startDate TEXT NOT NULL,
        endDate TEXT NOT NULL,
        totalPrice REAL NOT NULL,
        rentalType TEXT DEFAULT 'daily',
        bookingCode TEXT NOT NULL,
        status TEXT DEFAULT 'pending',
        createdAt TEXT,
        FOREIGN KEY (propertyId) REFERENCES properties(id),
        FOREIGN KEY (tenantId) REFERENCES users(id)
      )
    ''');

    // Default users
    await db.insert('users', {'username': 'owner', 'password': '123', 'role': 'owner'});
    await db.insert('users', {'username': 'tenant', 'password': '123', 'role': 'tenant'});
    await db.insert('users', {'username': 'guest', 'password': 'guest', 'role': 'guest'});
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Migration from v1 to v2
      // Add new columns to properties
      await db.execute('ALTER TABLE properties ADD COLUMN status TEXT DEFAULT "available"');
      await db.execute('ALTER TABLE properties ADD COLUMN ownerId INTEGER');
      await db.execute('ALTER TABLE properties ADD COLUMN createdAt TEXT');
      
      // Create bookings table (v1→v2 without rentalType/bookingCode)
      await db.execute('''
        CREATE TABLE bookings (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          propertyId INTEGER NOT NULL,
          tenantId INTEGER NOT NULL,
          startDate TEXT NOT NULL,
          endDate TEXT NOT NULL,
          totalPrice REAL NOT NULL,
          status TEXT DEFAULT 'pending',
          createdAt TEXT,
          FOREIGN KEY (propertyId) REFERENCES properties(id),
          FOREIGN KEY (tenantId) REFERENCES users(id)
        )
      ''');
    }
    
    if (oldVersion < 3) {
      // Migration from v2 to v3 - Add missing columns
      try {
        await db.execute('ALTER TABLE bookings ADD COLUMN rentalType TEXT DEFAULT "daily"');
      } catch (e) {
        print('rentalType column may already exist');
      }
      
      try {
        await db.execute('ALTER TABLE bookings ADD COLUMN bookingCode TEXT DEFAULT ""');
      } catch (e) {
        print('bookingCode column may already exist');
      }
    }
  }

  // ---------------- CRUD USER ----------------
  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<User?> getUser(String username, String password) async {
    final db = await database;
    final res = await db.query('users',
        where: 'username = ? AND password = ?', whereArgs: [username, password]);
    if (res.isNotEmpty) return User.fromMap(res.first);
    return null;
  }

  // ---------------- CRUD PROPERTY ----------------
  Future<int> insertProperty(Property property) async {
    final db = await database;
    return await db.insert('properties', property.toMap());
  }

  Future<List<Property>> getAllProperties() async {
    final db = await database;
    final res = await db.query('properties');
    return res.map((e) => Property.fromMap(e)).toList();
  }

  Future<int> updateProperty(Property property) async {
    final db = await database;
    return await db.update('properties', property.toMap(),
        where: 'id = ?', whereArgs: [property.id]);
  }

  Future<int> deleteProperty(int id) async {
    final db = await database;
    return await db.delete('properties', where: 'id = ?', whereArgs: [id]);
  }

  // ---------------- CRUD BOOKING ----------------
  Future<int> insertBooking(Booking booking) async {
    final db = await database;
    return await db.insert('bookings', booking.toMap());
  }

  Future<List<Booking>> getAllBookings() async {
    final db = await database;
    final res = await db.query('bookings', orderBy: 'createdAt DESC');
    return res.map((e) => Booking.fromMap(e)).toList();
  }

  Future<List<Booking>> getBookingsByTenant(int tenantId) async {
    final db = await database;
    final res = await db.query('bookings',
        where: 'tenantId = ?', whereArgs: [tenantId], orderBy: 'createdAt DESC');
    return res.map((e) => Booking.fromMap(e)).toList();
  }

  Future<List<Booking>> getBookingsByProperty(int propertyId) async {
    final db = await database;
    final res = await db.query('bookings',
        where: 'propertyId = ?', whereArgs: [propertyId], orderBy: 'createdAt DESC');
    return res.map((e) => Booking.fromMap(e)).toList();
  }

  Future<List<Booking>> getPendingBookingsForOwner(int ownerId) async {
    final db = await database;
    // Join bookings with properties to find ALL bookings for owner's properties
    final res = await db.rawQuery('''
      SELECT b.* FROM bookings b
      INNER JOIN properties p ON b.propertyId = p.id
      WHERE p.ownerId = ?
      ORDER BY b.createdAt DESC
    ''', [ownerId]);
    return res.map((e) => Booking.fromMap(e)).toList();
  }

  Future<int> updateBookingStatus(int id, String status) async {
    final db = await database;
    return await db.update('bookings', {'status': status},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteBooking(int id) async {
    final db = await database;
    return await db.delete('bookings', where: 'id = ?', whereArgs: [id]);
  }

  // ---------------- HELPER METHODS ----------------
  Future<int> updatePropertyStatus(int id, String status) async {
    final db = await database;
    return await db.update('properties', {'status': status},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<User?> getUserById(int id) async {
    final db = await database;
    final res = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (res.isNotEmpty) return User.fromMap(res.first);
    return null;
  }

  Future<Property?> getPropertyById(int id) async {
    final db = await database;
    final res = await db.query('properties', where: 'id = ?', whereArgs: [id]);
    if (res.isNotEmpty) return Property.fromMap(res.first);
    return null;
  }

  Future<List<Property>> getAvailableProperties() async {
    final db = await database;
    final res = await db.query('properties',
        where: 'status = ?', whereArgs: ['available']);
    return res.map((e) => Property.fromMap(e)).toList();
  }

  // Get booking by unique code (for guest check-in)
  Future<Booking?> getBookingByCode(String bookingCode) async {
    final db = await database;
    final res = await db.query('bookings',
        where: 'bookingCode = ?', whereArgs: [bookingCode]);
    if (res.isNotEmpty) return Booking.fromMap(res.first);
    return null;
  }

  // Generate unique 8-character booking code
  String generateBookingCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    var code = '';
    for (var i = 0; i < 8; i++) {
      code += chars[(random + i) % chars.length];
    }
    return code;
  }
}
