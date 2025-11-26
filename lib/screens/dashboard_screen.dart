import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/product.dart';
import '../helpers/database_helper.dart';
import 'product_detail_screen.dart';
import 'payment_screen.dart';
import 'update_user_screen.dart';
import 'add_edit_product_screen.dart';

class DashboardScreen extends StatefulWidget {
  static const routeName = '/dashboard';
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final Map<String, int> _cart = {};
  List<Product> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    await DatabaseHelper.instance.seedInitialData();
    final products = await DatabaseHelper.instance.readAllProducts();
    setState(() {
      _products = products;
      _isLoading = false;
    });
  }

  double get _total => _cart.entries.fold(0.0, (prev, e) {
        final p = _products.firstWhere((prod) => prod.id == e.key, orElse: () => Product(id: '', name: '', image: '', description: '', price: 0));
        return prev + p.price * e.value;
      });

  Future<void> _addProduct(Product p, {int qty = 1}) async {
    setState(() {
      _cart[p.id] = (_cart[p.id] ?? 0) + qty;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${p.name} added')));
  }

  Future<void> _openDialer(String phone) async {
    // Normalize phone to digits-only for tel: URIs
    final cleaned = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final candidates = <Uri>[
      Uri.parse('tel:$cleaned'),
      Uri.parse('tel:+$cleaned'),
    ];

    for (final uri in candidates) {
      try {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return;
        }
      } catch (_) {
        // ignore and try next
      }
    }

    // Final fallback: show SnackBar with phone number so user can dial manually
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cannot open dialer. Please call manually: $cleaned')));
  }

  Future<void> _sendSms(String phone) async {
    // Use the generic open WhatsApp helper which tries the app scheme first and falls back to web.
    final cleaned = phone.replaceAll(RegExp(r'[^0-9]'), '');
    await _openWhatsAppNumber(cleaned);
  }

  Future<void> _openWhatsAppNumber(String cleanedNumber) async {
    // Try app scheme first
    final schemeUri = Uri.parse('whatsapp://send?phone=$cleanedNumber');
    try {
      if (await canLaunchUrl(schemeUri)) {
        await launchUrl(schemeUri);
        return;
      }
    } catch (_) {
      // ignore and fallback to web URL
    }

    // Fallback to web (wa.me)
    final webUri = Uri.parse('https://wa.me/$cleanedNumber');
    if (await canLaunchUrl(webUri)) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
      return;
    }

    // Final fallback: show SnackBar with URL so user can copy/open manually
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cannot open WhatsApp. Open manually: https://wa.me/$cleanedNumber')));
  }

 

  void _onMenuSelected(String value) async {
    switch (value) {
      case 'call':
        _openDialer('+6281225723525');
        break;
      case 'sms':
        // SMS Center should open WhatsApp to the seller number per request
        _sendSms('+6281225723525');
        break;
      case 'maps':
        // Open the same short maps link as the AppBar icon
        try {
          final uri = Uri.parse('https://maps.app.goo.gl/kY9gDUAED5oakMrB8');
              final messenger = ScaffoldMessenger.of(context);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } else {
                if (mounted) messenger.showSnackBar(const SnackBar(content: Text('Cannot open Maps')));
              }
        } catch (_) {
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cannot open Maps')));
        }
        break;
      case 'update':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const UpdateUserScreen()));
        break;
      case 'add_product':
        final result = await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddEditProductScreen()),
        );
        if (result == true) _loadProducts();
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
                  final messenger = ScaffoldMessenger.of(context);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } else {
                    if (!mounted) return;
                    messenger.showSnackBar(const SnackBar(content: Text('Cannot open Maps')));
                  }
            },
          ),
          // Quick access button to open WhatsApp chat/call to seller
          IconButton(
            icon: const Icon(Icons.call),
            tooltip: 'Call Center (WhatsApp)',
            onPressed: () async {
              // Make this phone icon perform a direct call to the seller number
              await _openDialer('+6281225723525');
            },
          ),
          // Quick access button to open WhatsApp chat (seller number)
          IconButton(
            icon: const Icon(Icons.chat, color: Colors.green),
            tooltip: 'Chat via WhatsApp',
            onPressed: () async {
              await _openWhatsAppNumber('6281225723525');
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
              PopupMenuItem(value: 'add_product', child: Row(
                children: [
                  Icon(Icons.add, size: 20),
                  SizedBox(width: 8),
                  Text('Tambah Produk'),
                ],
              )),
            ],
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Belum ada produk'),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final result = await Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const AddEditProductScreen()),
                          );
                          if (result == true) _loadProducts();
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Tambah Produk'),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.78,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final p = _products[index];
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
                        onTap: () => _openProductDetail(p),
                        child: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Rp ${p.price.toStringAsFixed(0)}', style: const TextStyle(color: Colors.green)),
                          PopupMenuButton<String>(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.more_vert, size: 20),
                            onSelected: (value) async {
                              if (value == 'edit') {
                                final result = await Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => AddEditProductScreen(product: p)),
                                );
                                if (result == true) _loadProducts();
                              } else if (value == 'delete') {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('Hapus Produk'),
                                    content: Text('Yakin ingin menghapus ${p.name}?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await DatabaseHelper.instance.deleteProduct(p.id);
                                  _loadProducts();
                                  final messenger = ScaffoldMessenger.of(context);
                                  if (mounted) {
                                    messenger.showSnackBar(
                                      const SnackBar(content: Text('Produk berhasil dihapus')),
                                    );
                                  }
                                }
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(value: 'edit', child: Text('Edit')),
                              PopupMenuItem(value: 'delete', child: Text('Hapus', style: TextStyle(color: Colors.red))),
                            ],
                          ),
                        ],
                      ),
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
          // open payment form and pass a reset callback to clear cart
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => PaymentScreen(
                cart: Map<String,int>.from(_cart),
                onReset: () {
                  setState(() {
                    _cart.clear();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Keranjang telah direset')));
                },
              )));
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

  Future<void> _openProductDetail(Product p) async {
    final navigator = Navigator.of(context);
    final result = await navigator.push(MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p)));
    if (result is Product) {
      _addProduct(result);
    }
  }
}
