class Product {
  final int? id;
  final String barcode;
  final String sku;
  final String name;
  final double price; // This will be selling amount
  final double purchasingAmount;
  final int stock;
  final String? description;
  final String? imagePath;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    this.id,
    required this.barcode,
    this.sku = '',
    required this.name,
    required this.price,
    this.purchasingAmount = 0.0,
    this.stock = 0,
    this.description,
    this.imagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'barcode': barcode,
      'sku': sku,
      'name': name,
      'price': price,
      'purchasing_amount': purchasingAmount,
      'stock': stock,
      'description': description,
      'image_path': imagePath,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int?,
      barcode: map['barcode'] as String,
      sku: map['sku'] as String? ?? '',
      name: map['name'] as String,
      price: (map['price'] as num).toDouble(),
      purchasingAmount: (map['purchasing_amount'] as num?)?.toDouble() ?? 0.0,
      stock: map['stock'] as int? ?? 0,
      description: map['description'] as String?,
      imagePath: map['image_path'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Product copyWith({
    int? id,
    String? barcode,
    String? sku,
    String? name,
    double? price,
    double? purchasingAmount,
    int? stock,
    String? description,
    String? imagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      barcode: barcode ?? this.barcode,
      sku: sku ?? this.sku,
      name: name ?? this.name,
      price: price ?? this.price,
      purchasingAmount: purchasingAmount ?? this.purchasingAmount,
      stock: stock ?? this.stock,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
