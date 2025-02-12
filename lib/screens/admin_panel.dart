import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/crypto_currency.dart';
import '../services/storage_service.dart';
import '../services/coinmarketcap_service.dart';

class AdminPanel extends StatefulWidget {
  final StorageService storageService;

  const AdminPanel({super.key, required this.storageService});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  final CoinMarketCapService _coinService = CoinMarketCapService();
  List<CryptoCurrency> _availableCurrencies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrencies();
  }

  Future<void> _loadCurrencies() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      // Load current currencies from storage first
      _availableCurrencies = widget.storageService.getCryptoCurrencies();
      
      // Update with latest prices from API
      final updatedCurrencies = await _coinService.getUpdatedCryptocurrencies(_availableCurrencies);
      
      setState(() {
        _availableCurrencies = updatedCurrencies;
        _isLoading = false;
      });
      
      // Save the updated currencies back to storage
      widget.storageService.updateCurrencies(_availableCurrencies);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading cryptocurrencies: $e')),
        );
      }
    }
  }

  void _updateCurrency(int index, CryptoCurrency currency) {
    setState(() {
      _availableCurrencies[index] = currency;
    });
    widget.storageService.updateCurrency(index, currency);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Manage Cryptocurrencies',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _availableCurrencies.length,
              itemBuilder: (context, index) {
                final currency = _availableCurrencies[index];
                return CurrencyListItem(
                  currency: currency,
                  onToggle: (enabled) {
                    _updateCurrency(
                      index,
                      currency.copyWith(isEnabled: enabled),
                    );
                  },
                  onAmountChanged: (amount) {
                    _updateCurrency(
                      index,
                      currency.copyWith(amount: amount),
                    );
                  },
                );
              },
            ),
    );
  }
}

class CurrencyListItem extends StatelessWidget {
  final CryptoCurrency currency;
  final Function(bool) onToggle;
  final Function(double) onAmountChanged;

  const CurrencyListItem({
    super.key,
    required this.currency,
    required this.onToggle,
    required this.onAmountChanged,
  });

  void _showAmountDialog(BuildContext context) {
    final controller = TextEditingController(text: currency.amount.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${currency.name} Amount'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Amount',
            hintText: 'Enter amount',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(controller.text);
              if (amount != null) {
                onAmountChanged(amount);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Color(int.parse('0xFF${currency.iconColor}')),
              borderRadius: BorderRadius.circular(24),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.network(
                currency.logoUrl,
                width: 32,
                height: 32,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Text(
                      currency.icon,
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currency.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      currency.symbol,
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    TextButton(
                      onPressed: () => _showAmountDialog(context),
                      child: Text(
                        'Amount: ${currency.amount}',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Switch(
            value: currency.isEnabled,
            onChanged: onToggle,
            activeColor: const Color(0xFF9D7BEE),
          ),
        ],
      ),
    );
  }
}
