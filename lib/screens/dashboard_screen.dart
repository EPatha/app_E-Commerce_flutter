import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/product.dart';
import 'product_detail_screen.dart';
import 'payment_screen.dart';
import 'update_user_screen.dart';

class DashboardScreen extends StatefulWidget {
  static const routeName = '/dashboard';
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final Map<String, int> _cart = {};

  double get _total => _cart.entries.fold(0.0, (prev, e) {
        final p = demoProducts.firstWhere((prod) => prod.id == e.key);
        return prev + p.price * e.value;
      });

  Future<void> _addProduct(Product p, {int qty = 1}) async {
    setState(() {
      _cart[p.id] = (_cart[p.id] ?? 0) + qty;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${p.name} added')));
  }

  Future<void> _openDialer(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cannot open dialer')));
    }
  }

  Future<void> _sendSms(String phone) async {
    final uri = Uri.parse('sms:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cannot open SMS')));
    }
  }

  Future<void> _openMaps(String query) async {
    final encoded = Uri.encodeComponent(query);
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encoded');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cannot open Maps')));
    }
  }

  void _onMenuSelected(String value) async {
    switch (value) {
      case 'call':
        _openDialer('+628123456789');
        break;
      case 'sms':
        _sendSms('+628123456789');
        break;
      case 'maps':
        _openMaps('Warung Ajib, Bandungrejo, Mranggen, Demak');
        break;
      case 'update':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const UpdateUserScreen()));
        break;
      // no-op for logout here; logout available via Update User screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          // Quick access button to open Maps link
          IconButton(
            icon: const Icon(Icons.map),
            tooltip: 'Open Maps',
            onPressed: () async {
              final uri = Uri.parse('https://maps.app.goo.gl/kY9gDUAED5oakMrB8');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cannot open Maps')));
              }
            },
          ),
          // Quick access button to update username/password
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Update User & Password',
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const UpdateUserScreen())),
          ),
          PopupMenuButton<String>(
            onSelected: _onMenuSelected,
            itemBuilder: (ctx) => const [
              PopupMenuItem(value: 'call', child: Text('Call Center')),
              PopupMenuItem(value: 'sms', child: Text('SMS Center')),
              PopupMenuItem(value: 'maps', child: Text('Lokasi/Maps')),
              PopupMenuItem(value: 'update', child: Text('Update User & Password')),
            ],
          )
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.78,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: demoProducts.length,
        itemBuilder: (context, index) {
          final p = demoProducts[index];
          return Card(
            elevation: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _addProduct(p, qty: 1), // tap image to add to total
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      child: Image.asset(p.image, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Center(child: Icon(Icons.image_not_supported))),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          // open detail and wait for possible add-to-cart result
                          final result = await Navigator.of(context).pushNamed(ProductDetailScreen.routeName, arguments: p);
                          if (result is Product) {
                            _addProduct(result);
                          }
                        },
                        child: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 4),
                      Text('Rp ${p.price.toStringAsFixed(0)}', style: const TextStyle(color: Colors.green)),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: GestureDetector(
        onTap: () {
          // open payment form
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => PaymentScreen(total: _total)));
        },
        child: Container(
          color: Colors.blueGrey[50],
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text('Rp ${_total.toStringAsFixed(0)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
            ],
          ),
        ),
      ),
    );
  }
}
