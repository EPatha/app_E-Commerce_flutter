class Product {
  final String id;
  final String name;
  final String image;
  final String description;
  final double price;

  Product({
    required this.id,
    required this.name,
    required this.image,
    required this.description,
    required this.price,
  });
}

final List<Product> demoProducts = [
  Product(
    id: '1',
    name: 'Sate',
    image: 'assets/images/Sate.jpg',
    description: 'Sate enak, bumbu kacang khas.',
    price: 25000,
  ),
  Product(
    id: '2',
    name: 'Soto Ayam Kuning',
    image: 'assets/images/Soto-Ayam-Kuning.jpg',
    description: 'Soto hangat dengan kuah kuning.',
    price: 20000,
  ),
  Product(
    id: '3',
    name: 'Bubur Ayam',
    image: 'assets/images/Bubur-Ayam.jpg',
    description: 'Bubur lembut dengan topping ayam.',
    price: 15000,
  ),
  Product(
    id: '4',
    name: 'Es Teh Ajib Jumbo',
    image: 'assets/images/Estehajib-Jumbo.jpg',
    description: 'Segar, manis, porsi jumbo.',
    price: 8000,
  ),
  Product(
    id: '5',
    name: 'Steak Enak',
    image: 'assets/images/Steak-enak.jpg',
    description: 'Steak medium rare dengan saus spesial.',
    price: 75000,
  ),
];
