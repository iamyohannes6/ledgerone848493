import 'package:flutter/material.dart';
import '../models/crypto_currency.dart';
import '../services/storage_service.dart';

class AdminPanel extends StatefulWidget {
  final StorageService storageService;

  const AdminPanel({super.key, required this.storageService});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  late List<CryptoCurrency> _currencies;

  @override
  void initState() {
    super.initState();
    _currencies = widget.storageService.getCryptoCurrencies();
  }

  void _updateCurrency(int index) async {
    final currency = _currencies[index];
    final result = await showDialog<CryptoCurrency>(
      context: context,
      builder: (context) => EditCurrencyDialog(currency: currency),
    );

    if (result != null) {
      await widget.storageService.updateCryptoCurrency(result);
      setState(() {
        _currencies = widget.storageService.getCryptoCurrencies();
      });
    }
  }

  void _addCurrency() async {
    final result = await showDialog<CryptoCurrency>(
      context: context,
      builder: (context) => const AddCurrencyDialog(),
    );

    if (result != null) {
      try {
        await widget.storageService.addCryptoCurrency(result);
        setState(() {
          _currencies = widget.storageService.getCryptoCurrencies();
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: const Color(0xFF9D7BEE),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _addCurrency(),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _currencies.length,
        itemBuilder: (context, index) {
          final currency = _currencies[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Color(int.parse('0x${currency.iconColor}')),
              child: Text(
                currency.icon,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(currency.name),
            subtitle: Text('${currency.amount} ${currency.symbol}'),
            trailing: Text(
              '\$${(currency.value).toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () => _updateCurrency(index),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.grey[100],
        child: Text(
          'Total Balance: \$${widget.storageService.getTotalBalance().toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class EditCurrencyDialog extends StatefulWidget {
  final CryptoCurrency currency;

  const EditCurrencyDialog({super.key, required this.currency});

  @override
  State<EditCurrencyDialog> createState() => _EditCurrencyDialogState();
}

class _EditCurrencyDialogState extends State<EditCurrencyDialog> {
  late TextEditingController _amountController;
  late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.currency.amount.toString(),
    );
    _priceController = TextEditingController(
      text: widget.currency.price.toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit ${widget.currency.name}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _amountController,
            decoration: const InputDecoration(labelText: 'Amount'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          TextField(
            controller: _priceController,
            decoration: const InputDecoration(labelText: 'Price (USD)'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final updatedCurrency = CryptoCurrency(
              icon: widget.currency.icon,
              name: widget.currency.name,
              symbol: widget.currency.symbol,
              amount: double.parse(_amountController.text),
              price: double.parse(_priceController.text),
              iconColor: widget.currency.iconColor,
            );
            Navigator.pop(context, updatedCurrency);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}

class AddCurrencyDialog extends StatefulWidget {
  const AddCurrencyDialog({super.key});

  @override
  State<AddCurrencyDialog> createState() => _AddCurrencyDialogState();
}

class _AddCurrencyDialogState extends State<AddCurrencyDialog> {
  final _formKey = GlobalKey<FormState>();
  final _iconController = TextEditingController();
  final _nameController = TextEditingController();
  final _symbolController = TextEditingController();
  final _priceController = TextEditingController();
  final _iconColorController = TextEditingController(text: 'FF9D7BEE');

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Currency'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _iconController,
                decoration: const InputDecoration(labelText: 'Icon Symbol (e.g., ₿)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an icon symbol';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name (e.g., Bitcoin)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _symbolController,
                decoration: const InputDecoration(labelText: 'Symbol (e.g., BTC)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a symbol';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price (USD)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _iconColorController,
                decoration: const InputDecoration(
                  labelText: 'Icon Color (hex, e.g., FF9D7BEE)',
                  hintText: 'FF9D7BEE',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a color';
                  }
                  if (!RegExp(r'^[0-9A-Fa-f]{8}$').hasMatch(value)) {
                    return 'Please enter a valid 8-digit hex color';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final newCurrency = CryptoCurrency(
                icon: _iconController.text,
                name: _nameController.text,
                symbol: _symbolController.text.toUpperCase(),
                amount: 0,
                price: double.parse(_priceController.text),
                iconColor: _iconColorController.text,
              );
              Navigator.pop(context, newCurrency);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _iconController.dispose();
    _nameController.dispose();
    _symbolController.dispose();
    _priceController.dispose();
    _iconColorController.dispose();
    super.dispose();
  }
}
