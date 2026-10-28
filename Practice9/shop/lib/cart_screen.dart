import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/cart.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  Future<void> _clear(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear the cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (!context.mounted) return;
    if (ok == true) {
      context.read<Cart>().clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        actions: [
          IconButton(
            tooltip: 'Clear cart',
            onPressed: () => _clear(context),
            icon: const Icon(Icons.delete_sweep),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<Cart>(
              builder: (context, cart, _) => ListView(
                children: [
                  for (final b in cart.items)
                    ListTile(
                      title: Text(b.title),
                      subtitle: Text('${b.price} ₸  ×${cart.qtyOf(b)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () => cart.increment(b),
                            icon: const Icon(Icons.add),
                          ),
                          IconButton(
                            onPressed: () => cart.remove(b),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          Consumer<Cart>(
            builder: (context, cart, child) => Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  child!,
                  const Spacer(),
                  Text(
                    '${cart.total} ₸',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.receipt_long),
                SizedBox(width: 8),
                Text('Total'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
