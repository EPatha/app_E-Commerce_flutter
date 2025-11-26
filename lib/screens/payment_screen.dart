import 'package:flutter/material.dart';
import '../models/product.dart';
import '../helpers/database_helper.dart';

class PaymentScreen extends StatefulWidget {
  static const routeName = '/payment';
  final Map<String, int> cart;
  final VoidCallback? onReset;
  const PaymentScreen({Key? key, this.cart = const {}, this.onReset}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _payController = TextEditingController();
  double? _change;
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final products = await DatabaseHelper.instance.readAllProducts();
    setState(() {
      _products = products;
    });
  }

  double get _totalFromCart {
    double t = 0.0;
    widget.cart.forEach((id, qty) {
      final p = _products.firstWhere((prod) => prod.id == id, orElse: () => Product(id: id, name: 'Unknown', image: '', description: '', price: 0.0));
      t += p.price * qty;
    });
    return t;
  }

  void _processPayment() {
    final text = _payController.text.replaceAll(',', '').trim();
    final paid = double.tryParse(text);
    if (paid == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Masukkan jumlah pembayaran yang valid')));
      return;
    }
    final total = _totalFromCart;
    if (paid < total) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Jumlah pembayaran kurang')));
      return;
    }
    setState(() {
      _change = paid - total;
    });
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Pembayaran Diterima'),
        content: Text('Total: Rp ${total.toStringAsFixed(0)}\nDibayar: Rp ${paid.toStringAsFixed(0)}\nKembali: Rp ${_change!.toStringAsFixed(0)}'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = _totalFromCart;

    return Scaffold(
      appBar: AppBar(title: const Text('Pembayaran')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Daftar Pesanan:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            // list ordered products
            if (widget.cart.isEmpty)
              const Text('Belum ada produk dipesan.'),
            if (widget.cart.isNotEmpty)
              SizedBox(
                height: 160,
                child: ListView(
                  children: widget.cart.entries.map((e) {
                    final p = _products.firstWhere((prod) => prod.id == e.key, orElse: () => Product(id: e.key, name: 'Unknown', image: '', description: '', price: 0.0));
                    final subtotal = p.price * e.value;
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(p.name),
                      subtitle: Text('Qty: ${e.value}  •  Rp ${p.price.toStringAsFixed(0)}'),
                      trailing: Text('Rp ${subtotal.toStringAsFixed(0)}'),
                    );
                  }).toList(),
                ),
              ),

            const SizedBox(height: 8),
            Text('Total Transaksi:\nRp ${total.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            TextField(
              controller: _payController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Jumlah Pembayaran', prefixText: 'Rp '),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(onPressed: _processPayment, child: const Text('Bayar')),
                const SizedBox(width: 8),
                OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Kembali')),
                const SizedBox(width: 8),
                if (widget.onReset != null)
                  TextButton(
                    onPressed: () async {
                      final navigator = Navigator.of(context);
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Reset Pesanan'),
                          content: const Text('Yakin ingin mereset total/keranjang?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Batal')),
                            TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Reset')),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        // Always trigger the reset callback; pop using captured navigator
                        widget.onReset!();
                        navigator.pop();
                      }
                    },
                    child: const Text('Reset', style: TextStyle(color: Colors.red)),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (_change != null) Text('Kembali: Rp ${_change!.toStringAsFixed(0)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
