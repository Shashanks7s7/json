import 'package:flutter/cupertino.dart';
import 'package:p_resturant/models/ordertype.dart';
import 'package:p_resturant/models/payment_mode.dart';
import 'package:p_resturant/models/product.dart';
import 'package:p_resturant/models/product_adon.dart';
import 'package:p_resturant/models/product_adon_mapping_info.dart';
import 'package:p_resturant/models/productscategory.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as d;

class MyDatabase {
  static final MyDatabase instance = MyDatabase._init();
  MyDatabase._init();
  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) {
      return _database;
    }
    _database = await _initDB('productcategory.db');
    return _database!;
  }

  Future<Database> _initDB(String filepath) async {
    final dbPath = await getDatabasesPath();
    final path = d.join(dbPath, filepath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    final textType = 'TEXT NOT NULL';
    final integerType='INTEGER NOT NULL';
    final boolType='BOOLEAN NOT NULL';
    final realType = 'REAL NOT NULL';

    await db.execute('''CREATE TABLE $tableProductsCategory (
    ${ProductsCategoryField.productCategoryID} $idType,
    ${ProductsCategoryField.categoryName} $textType,
    ${ProductsCategoryField.categoryCode} $textType
  )''');
    await db.execute('''CREATE TABLE $tableProductAdon (
    ${ProductAdonField.productAdonID} $idType,
    ${ProductAdonField.adonName} $textType,
    ${ProductAdonField.adonCode} $textType
  )''');
   
    await db.execute('''CREATE TABLE $tableProduct (
    ${ProductField.productID} $idType,
    ${ProductField.productName} $textType,
    ${ProductField.productCode} $textType,
    ${ProductField.unitPrice} $realType,
    ${ProductField.image} $textType,
    ${ProductField.localName} $textType,
    ${ProductField.productCategoryID} $integerType,
    FOREIGN KEY(${ProductField.productCategoryID}) REFERENCES $tableProductsCategory (${ProductsCategoryField.productCategoryID})

  )''');
   await db.execute('''CREATE TABLE $tableProductAdonMappingInfo (
    ${ProductAdonMappingInfoField.productAdonID} $integerType,
    ${ProductAdonMappingInfoField.productID} $integerType,
    FOREIGN KEY(${ProductAdonMappingInfoField.productAdonID}) REFERENCES $tableProductAdon (${ProductAdonField.productAdonID}),
    FOREIGN KEY(${ProductAdonMappingInfoField.productID}) REFERENCES $tableProduct (${ProductField.productID})
  
   )''');
    await db.execute('''CREATE TABLE $tableOrderType (
    ${OrderTypeField.orderTypeID} $idType,
    ${OrderTypeField.orderTypeName} $textType,
    ${OrderTypeField.orderTypeCode} $textType
  )''');
   await db.execute('''CREATE TABLE $tablePaymentMode (
    ${PaymentModeField.paymentModeID} $idType,
    ${PaymentModeField.name} $textType,
    ${PaymentModeField.code} $textType
  )''');
  }

  Future<ProductsCategory?> createprocat(ProductsCategory procat) async {
    final db = await instance.database;
    final id = await db!.insert(tableProductsCategory, procat.toJson());
    return procat.copy(id: id);
  }

  Future<ProductAdon?> createadon(ProductAdon procat) async {
    final db = await instance.database;
    final id = await db!.insert(tableProductAdon, procat.toJson());
    return procat.copy(id: id);
  }

  Future<Product?> createproduct(Product product) async {
    final db = await instance.database;
    final id = await db!.insert(tableProduct, product.toJson());
    return product.copy(id: id);
  }

  Future<ProductsCategory?> readprocat(int id) async {
    final db = await instance.database;
    final maps = await db!.query(tableProductsCategory,
        columns: ProductsCategoryField.values,
        where: '${ProductsCategoryField.productCategoryID} = ?',
        whereArgs: [id]);
    if (maps.isNotEmpty) {
      return ProductsCategory.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Product>> readAllproducts() async {
    final db = await instance.database;
    final result = await db!.query(tableProduct);
    return result.map((json) => Product.fromJson(json)).toList();
  }

  Future<List<ProductsCategory>> readAllprocat() async {
    final db = await instance.database;
    final result = await db!.query(tableProductsCategory);
    return result.map((json) => ProductsCategory.fromJson(json)).toList();
  }

  Future<List<ProductAdon>> readAlladon() async {
    final db = await instance.database;
    final result = await db!.query(tableProductAdon);
    return result.map((json) => ProductAdon.fromJson(json)).toList();
  }

  Future<int> updateprocat(ProductsCategory procat) async {
    final db = await instance.database;
    return db!.update(tableProductsCategory, procat.toJson(),
        where: '${ProductsCategoryField.productCategoryID} = ?',
        whereArgs: [procat.productCategoryID]);
  }

  Future<int> deleteprocat(int id) async {
    final db = await instance.database;
    return await db!.delete(tableProductsCategory,
        where: '${ProductsCategoryField.productCategoryID} = ?',
        whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db!.close();
  }
}
