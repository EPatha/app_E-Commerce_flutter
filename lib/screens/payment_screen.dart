import 'package:flutter/material.dart';

class PaymentScreen extends StatefulWidget {
  static const routeName = '/payment';
  final double total;
  final VoidCallback? onReset;
  const PaymentScreen({Key? key, this.total = 0.0, this.onReset}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _payController = TextEditingController();
  double? _change;

  void _processPayment() {
    final text = _payController.text.replaceAll(',', '').trim();
    final paid = double.tryParse(text);
    if (paid == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Masukkan jumlah pembayaran yang valid')));
      return;
    }
    if (paid < widget.total) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Jumlah pembayaran kurang')));
      return;
    }
    setState(() {
      _change = paid - widget.total;
    });
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Pembayaran Diterima'),
        content: Text('Total: Rp ${widget.total.toStringAsFixed(0)}\nDibayar: Rp ${paid.toStringAsFixed(0)}\nKembali: Rp ${_change!.toStringAsFixed(0)}'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pembayaran')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Transaksi:\nRp ${widget.total.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18)),
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
                        widget.onReset!();
                        Navigator.of(context).pop();
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
