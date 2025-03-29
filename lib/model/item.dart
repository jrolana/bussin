class Item {
  final int? id;
  final String name;
  final double price;
  final String imageUrl;

  const Item({
    this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
  });

  Map<String, Object?> toMap() {
    return {'id': id, 'name': name, 'price': price, 'imageUrl': imageUrl};
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'],
      name: map['name'],
      price: map['price'],
      imageUrl: map['imageUrl'],
    );
  }

  @override
  String toString() {
    return "Item({'id': $id, 'name': $name, 'price': $price, 'imageUrl': $imageUrl})";
  }
}
