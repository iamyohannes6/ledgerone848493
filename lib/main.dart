import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'models/crypto_currency.dart';
import 'services/storage_service.dart';
import 'screens/admin_panel.dart';

void main() {
  final storageService = StorageService();
  runApp(MyApp(storageService: storageService));
}

class MyApp extends StatelessWidget {
  final StorageService storageService;

  const MyApp({super.key, required this.storageService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Live Ledger',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF9D7BEE),
          secondary: const Color(0xFF9D7BEE),
          background: Colors.white,
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: WalletScreen(storageService: storageService),
    );
  }
}

class WalletScreen extends StatefulWidget {
  final StorageService storageService;

  const WalletScreen({super.key, required this.storageService});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  int _selectedIndex = 0;
  final List<String> _tabs = ['Crypto', 'NFTs', 'Market'];
  late List<CryptoCurrency> _currencies;

  @override
  void initState() {
    super.initState();
    _currencies = widget.storageService.getCryptoCurrencies();
  }

  void _refreshData() {
    setState(() {
      _currencies = widget.storageService.getCryptoCurrencies();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Text(
              'Wallet',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.visibility_outlined),
          ],
        ),
        actions: [
          const Icon(Icons.credit_card),
          const SizedBox(width: 16),
          const Icon(Icons.waves),
          const SizedBox(width: 16),
          const Icon(Icons.notifications_outlined),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AdminPanel(storageService: widget.storageService),
                ),
              );
              _refreshData();
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: _tabs.map((tab) {
                final isSelected = _tabs.indexOf(tab) == 0;
                return Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF9D7BEE) : Colors.transparent,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      tab,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 32),
          // Balance
          Text(
            '\$${widget.storageService.getTotalBalance().toStringAsFixed(2)}',
            style: GoogleFonts.inter(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 32),
          // Chart
          SizedBox(
            height: 100,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 3),
                      FlSpot(2.6, 2),
                      FlSpot(4.9, 5),
                      FlSpot(6.8, 2.5),
                      FlSpot(8, 4),
                      FlSpot(9.5, 3),
                      FlSpot(11, 4),
                    ],
                    isCurved: true,
                    color: const Color(0xFF9D7BEE),
                    barWidth: 2,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF9D7BEE).withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          // Crypto List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _currencies.length,
              itemBuilder: (context, index) {
                final currency = _currencies[index];
                return _CryptoListItem(
                  icon: currency.icon,
                  name: currency.name,
                  symbol: currency.symbol,
                  amount: currency.amount.toString(),
                  value: '\$${currency.value.toStringAsFixed(2)}',
                  iconColor: Color(int.parse('0x${currency.iconColor}')),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Stack(
        children: [
          Container(
            height: 80,
            color: const Color.fromARGB(255, 101, 101, 101),
          ),
          Container(
            height: 95,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color.fromARGB(255, 255, 255, 255),
                  const Color.fromARGB(255, 172, 172, 172),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.0),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: CurvedNavigationBar(
              backgroundColor: Colors.transparent,
              color: Colors.white,
              buttonBackgroundColor: const Color(0xFF9D7BEE),
              height: 75,
              letIndexChange: (index) => true,
              animationCurve: Curves.easeInOut,
              animationDuration: const Duration(milliseconds: 300),
              items: [
                _buildNavItem(
                    0, 'Wallet', Icons.account_balance_wallet_outlined),
                _buildNavItem(1, 'Earn', Icons.show_chart),
                _buildNavItem(2, 'Swap', Icons.swap_horiz),
                _buildNavItem(3, 'Discover', Icons.public),
                _buildNavItem(4, 'Ledger', Icons.credit_card),
              ],
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              index: _selectedIndex,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String label, IconData icon) {
    final isSelected = _selectedIndex == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.all(isSelected ? 16 : 8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? const Color(0xFF9D7BEE) : Colors.transparent,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.white : Colors.grey[400],
            size: isSelected ? 32 : 24,
          ),
          if (!isSelected) ...[
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CryptoListItem extends StatelessWidget {
  final String icon;
  final String name;
  final String symbol;
  final String amount;
  final String value;
  final Color iconColor;

  const _CryptoListItem({
    required this.icon,
    required this.name,
    required this.symbol,
    required this.amount,
    required this.value,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Text(
                icon,
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$amount $symbol',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
