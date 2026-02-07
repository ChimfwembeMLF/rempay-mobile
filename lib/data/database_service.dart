import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// SQLite database service for persisting local data
/// Note: Not available on web - operations will silently fail
class DatabaseService {
  static const String _dbName = 'rempay.db';
  static const int _version = 1;
  
  static final DatabaseService _instance = DatabaseService._internal();
  
  factory DatabaseService() {
    return _instance;
  }
  
  DatabaseService._internal();
  
  static Database? _database;
  static bool _initialized = false;
  
  Future<Database?> get database async {
    if (kIsWeb) {
      // SQLite not supported on web
      return null;
    }
    if (_database == null) {
      await _initDatabase();
    }
    return _database;
  }
  
  /// Initialize the database (call this once at app startup)
  Future<void> initialize() async {
    if (kIsWeb) {
      print('SQLite not available on web - skipping database initialization');
      _initialized = true;
      return;
    }
    if (_initialized) return;
    try {
      await _initDatabase();
      _initialized = true;
    } catch (e) {
      print('Error initializing database: $e');
      rethrow;
    }
  }
  
  Future<void> _initDatabase() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, _dbName);
      
      _database = await openDatabase(
        path,
        version: _version,
        onCreate: _onCreate,
      );
    } catch (e) {
      print('Error opening database: $e');
      rethrow;
    }
  }
  
  Future<void> _onCreate(Database db, int version) async {
    try {
      // Create tables
      await db.execute('''
        CREATE TABLE transactions (
          id TEXT PRIMARY KEY,
          reference TEXT NOT NULL,
          amount REAL NOT NULL,
          currency TEXT NOT NULL,
          status TEXT NOT NULL,
          type TEXT NOT NULL,
          createdAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL,
          metadata TEXT
        )
      ''');
      
      await db.execute('''
        CREATE TABLE merchant_account (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          currency TEXT NOT NULL,
          availableBalance REAL NOT NULL,
          pendingBalance REAL NOT NULL,
          lastUpdated TEXT NOT NULL
        )
      ''');
      
      await db.execute('''
        CREATE TABLE cached_data (
          key TEXT PRIMARY KEY,
          value TEXT NOT NULL,
          timestamp TEXT NOT NULL,
          expiresAt TEXT
        )
      ''');
    } catch (e) {
      print('Error creating tables: $e');
      rethrow;
    }
  }
  
  /// Save a transaction
  Future<void> saveTransaction(Map<String, dynamic> transaction) async {
    if (kIsWeb) return;
    try {
      final db = await database;
      if (db == null) return;
      await db.insert(
        'transactions',
        transaction,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error saving transaction: $e');
      // Don't rethrow - database operations are non-critical
    }
  }
  
  /// Get all transactions
  Future<List<Map<String, dynamic>>> getTransactions() async {
    if (kIsWeb) return [];
    try {
      final db = await database;
      if (db == null) return [];
      return db.query(
        'transactions',
        orderBy: 'createdAt DESC',
      );
    } catch (e) {
      print('Error getting transactions: $e');
      return [];
    }
  }
  
  /// Delete transaction
  Future<void> deleteTransaction(String id) async {
    if (kIsWeb) return;
    try {
      final db = await database;
      if (db == null) return;
      await db.delete(
        'transactions',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error deleting transaction: $e');
    }
  }
  
  /// Save merchant account
  Future<void> saveMerchantAccount(Map<String, dynamic> account) async {
    if (kIsWeb) return;
    try {
      final db = await database;
      if (db == null) return;
      await db.insert(
        'merchant_account',
        account,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error saving merchant account: $e');
    }
  }
  
  /// Get merchant account
  Future<Map<String, dynamic>?> getMerchantAccount(String id) async {
    if (kIsWeb) return null;
    try {
      final db = await database;
      if (db == null) return null;
      final result = await db.query(
        'merchant_account',
        where: 'id = ?',
        whereArgs: [id],
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      print('Error getting merchant account: $e');
      return null;
    }
  }
  
  /// Cache data with optional expiration
  Future<void> cacheData(
    String key,
    String value, {
    Duration? ttl,
  }) async {
    if (kIsWeb) return;
    try {
      final db = await database;
      if (db == null) return;
      final expiresAt = ttl != null
          ? DateTime.now().add(ttl).toIso8601String()
          : null;
      
      await db.insert(
        'cached_data',
        {
          'key': key,
          'value': value,
          'timestamp': DateTime.now().toIso8601String(),
          'expiresAt': expiresAt,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error caching data: $e');
    }
  }
  
  /// Get cached data (checks expiration)
  Future<String?> getCachedData(String key) async {
    if (kIsWeb) return null;
    try {
      final db = await database;
      if (db == null) return null;
      final result = await db.query(
        'cached_data',
        where: 'key = ?',
        whereArgs: [key],
      );
      
      if (result.isEmpty) {
        return null;
      }
      
      final cached = result.first;
      final expiresAt = cached['expiresAt'] as String?;
      
      // Check if expired
      if (expiresAt != null) {
        final expireTime = DateTime.parse(expiresAt);
        if (DateTime.now().isAfter(expireTime)) {
          // Expired, delete it
          await clearCachedData(key);
          return null;
        }
      }
      
      return cached['value'] as String?;
    } catch (e) {
      print('Error getting cached data: $e');
      return null;
    }
  }
  
  /// Clear specific cached data
  Future<void> clearCachedData(String key) async {
    if (kIsWeb) return;
    try {
      final db = await database;
      if (db == null) return;
      await db.delete(
        'cached_data',
        where: 'key = ?',
        whereArgs: [key],
      );
    } catch (e) {
      print('Error clearing cached data: $e');
    }
  }
  
  /// Clear all expired cached data
  Future<void> clearExpiredCache() async {
    if (kIsWeb) return;
    try {
      final db = await database;
      if (db == null) return;
      await db.delete(
        'cached_data',
        where: 'expiresAt IS NOT NULL AND expiresAt < ?',
        whereArgs: [DateTime.now().toIso8601String()],
      );
    } catch (e) {
      print('Error clearing expired cache: $e');
    }
  }
  
  /// Clear all data
  Future<void> clear() async {
    if (kIsWeb) return;
    try {
      final db = await database;
      if (db == null) return;
      await db.delete('transactions');
      await db.delete('merchant_account');
      await db.delete('cached_data');
    } catch (e) {
      print('Error clearing database: $e');
    }
  }
  
  /// Close database
  Future<void> close() async {
    if (kIsWeb) return;
    try {
      if (_database != null) {
        await _database!.close();
        _database = null;
        _initialized = false;
      }
    } catch (e) {
      print('Error closing database: $e');
    }
  }
}
