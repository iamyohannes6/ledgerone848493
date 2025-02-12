import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'models/crypto_currency.dart';
import 'services/storage_service.dart';
import 'services/coinmarketcap_service.dart';
import 'screens/admin_panel.dart';
import 'screens/discover_screen.dart';
import 'screens/earn_screen.dart';
import 'screens/ledger_screen.dart';
import 'screens/wallet/nft_screen.dart';
import 'screens/wallet/market_screen.dart';
import 'models/portfolio_history.dart';

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
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1A1B1F),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF9D7BEE),
          secondary: Color(0xFF9D7BEE),
          background: Color(0xFF1A1B1F),
          surface: Color(0xFF2A2B2F),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1B1F),
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(color: Colors.white),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
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
  int _selectedTabIndex = 0;
  String _selectedTimePeriod = '1D';
  final List<String> _tabs = ['Crypto', 'NFTs', 'Market'];
  late List<CryptoCurrency> _currencies;
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
    initialRefreshStatus: RefreshStatus.idle,
    initialLoadStatus: LoadStatus.idle,
  );
  final CoinMarketCapService _coinService = CoinMarketCapService();

  @override
  void initState() {
    super.initState();
    _currencies = widget.storageService.getCryptoCurrencies();
    _fetchLatestPrices();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _fetchLatestPrices() async {
    try {
      // First get the latest data from storage
      _currencies = widget.storageService.getCryptoCurrencies();
      
      // Then update with latest prices
      final updatedCurrencies = await _coinService.getUpdatedCryptocurrencies(_currencies);
      
      setState(() {
        _currencies = updatedCurrencies;
      });
      
      // Save the updated prices back to storage
      widget.storageService.updateCurrencies(updatedCurrencies);
    } catch (e) {
      debugPrint('Error fetching prices: $e');
    }
  }

  void _refreshData() {
    setState(() {
      _currencies = widget.storageService.getCryptoCurrencies();
    });
  }

  Future<void> _onRefresh() async {
    try {
      await _fetchLatestPrices();
      _refreshController.refreshCompleted();
    } catch (e) {
      _refreshController.refreshFailed();
    }
  }

  Widget _getScreen(int index) {
    switch (index) {
      case 0:
        return _buildWalletContent();
      case 1:
        return const EarnScreen();
      case 2:
        // Swap screen - will be implemented later
        return const Center(child: Text('Swap Screen'));
      case 3:
        return const DiscoverScreen();
      case 4:
        return const LedgerScreen();
      default:
        return _buildWalletContent();
    }
  }

  Widget _getTabContent(int index) {
    switch (index) {
      case 0:
        return _buildCryptoContent();
      case 1:
        return const NFTScreen();
      case 2:
        return const MarketScreen();
      default:
        return _buildCryptoContent();
    }
  }

  Widget _buildWalletContent() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: _tabs.map((tab) {
              final isSelected = _tabs.indexOf(tab) == _selectedTabIndex;
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedTabIndex = _tabs.indexOf(tab);
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF8F79E0) : const Color(0xFF554868),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tab,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: _getTabContent(_selectedTabIndex),
        ),
      ],
    );
  }

  Widget _buildCryptoContent() {
    final enabledCurrencies = _currencies.where((c) => c.isEnabled).toList();
    final timePeriods = ['1D', '1W', '1M', '1Y', 'ALL'];
    final actions = [
      {'icon': Icons.add, 'label': 'Buy'},
      {'icon': Icons.swap_horiz, 'label': 'Swap'},
      {'icon': Icons.arrow_upward, 'label': 'Send'},
      {'icon': Icons.arrow_downward, 'label': 'Receive'},
      {'icon': Icons.account_balance, 'label': 'Earn'},
    ];

    // Get portfolio history data for the selected period
    final historyData = widget.storageService.getPortfolioHistory(_selectedTimePeriod);
    
    // Convert history data to chart points
    final List<FlSpot> spots = [];
    if (historyData.isNotEmpty) {
      final minTime = historyData.first.timestamp.millisecondsSinceEpoch.toDouble();
      final timeRange = historyData.last.timestamp.millisecondsSinceEpoch - historyData.first.timestamp.millisecondsSinceEpoch;
      
      spots.addAll(
        historyData.map((point) {
          final x = (point.timestamp.millisecondsSinceEpoch - minTime) / timeRange * 11;
          return FlSpot(x, point.value);
        }),
      );
    } else {
      // If no data, show a flat line
      spots.addAll([
        const FlSpot(0, 0),
        const FlSpot(11, 0),
      ]);
    }
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 32),
            Text(
              '\$${_calculateTotalBalance().toStringAsFixed(2)}',
              style: GoogleFonts.inter(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 100,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
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
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Time period buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: timePeriods.map((period) {
                final isSelected = period == _selectedTimePeriod;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTimePeriod = period;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF2A2B2F) : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      period,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            // Action buttons
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: actions.map((action) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Container(
                      width: 96,
                      height: 82,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2B2F),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            action['icon'] as IconData,
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            action['label'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 32),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: enabledCurrencies.length,
              itemBuilder: (context, index) {
                final currency = enabledCurrencies[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 58),
                  child: _CryptoListItem(
                    icon: currency.icon,
                    name: currency.name,
                    symbol: currency.symbol,
                    amount: currency.amount.toString(),
                    value: '\$${currency.value.toStringAsFixed(2)}',
                    percentChange24h: currency.percentChange24h,
                    iconColor: Color(int.parse('0xFF${currency.iconColor}')),
                    logoUrl: currency.logoUrl,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  double _calculateTotalBalance() {
    return _currencies.fold(0.0, (sum, currency) => sum + (currency.amount * currency.value));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.3],
          colors: [
            Color(0xFF503C6B),
            Color(0xFF151018),
          ],
        ),
      ),
      child: SmartRefresher(
        controller: _refreshController,
        onRefresh: _onRefresh,
        enablePullDown: true,
        header: const ClassicHeader(
          refreshStyle: RefreshStyle.Behind,
          idleText: '',
          refreshingText: '',
          completeText: '',
          failedText: '',
          releaseText: '',
          spacing: 0,
          height: 0,
        ),
        physics: const BouncingScrollPhysics(),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Row(
              children: [
                Text(
                  'Wallet',
                  style: GoogleFonts.inter(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.visibility_outlined, color: Colors.white),
              ],
            ),
            actions: [
              const Icon(Icons.credit_card, color: Colors.white),
              const SizedBox(width: 16),
              const Icon(Icons.waves, color: Colors.white),
              const SizedBox(width: 16),
              const Icon(Icons.notifications_outlined, color: Colors.white),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: Colors.white),
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
          body: _getScreen(_selectedIndex),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF1A1B1F),
            ),
            child: BottomAppBar(
              height: 60,
              padding: EdgeInsets.zero,
              shape: const CircularNotchedRectangle(),
              notchMargin: 8.0,
              elevation: 0,
              color: Colors.transparent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, 'Wallet', Icons.account_balance_wallet_outlined),
                  _buildNavItem(1, 'Earn', Icons.show_chart),
                  const SizedBox(width: 40),
                  _buildNavItem(3, 'Discover', Icons.public),
                  _buildNavItem(4, 'Ledger', Icons.credit_card),
                ],
              ),
            ),
          ),
          floatingActionButton: SizedBox(
            height: 56,
            width: 56,
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  _selectedIndex = 2;
                });
              },
              backgroundColor: const Color(0xFF9D7BEE),
              shape: const CircleBorder(),
              child: const Icon(Icons.swap_horiz, size: 28, color: Colors.white),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String label, IconData icon) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: SizedBox(
        height: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF9D7BEE) : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF9D7BEE) : Colors.grey,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
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
  final double percentChange24h;
  final Color iconColor;
  final String logoUrl;

  const _CryptoListItem({
    required this.icon,
    required this.name,
    required this.symbol,
    required this.amount,
    required this.value,
    required this.percentChange24h,
    required this.iconColor,
    required this.logoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        symbol == 'USDT'
            ? SizedBox(
                width: 58,
                height: 58,
                child: Stack(
                  children: [
                    Positioned(
                      right: 0,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: iconColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Image.network(
                            logoUrl,
                            width: 28,
                            height: 28,
                            errorBuilder: (context, error, stackTrace) {
                              return Text(
                                icon,
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2B2F),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: iconColor,
                            width: 2,
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            '\$',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: iconColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Image.network(
                    logoUrl,
                    width: 36,
                    height: 36,
                    errorBuilder: (context, error, stackTrace) {
                      return Text(
                        icon,
                        style: const TextStyle(
                          fontSize: 28,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
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
                name,
                style: const TextStyle(
                  fontSize: 16,
                  height: 24/16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                '$amount $symbol',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  height: 24/14,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                height: 24/16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            Text(
              '${percentChange24h >= 0 ? '+' : ''}${percentChange24h.toStringAsFixed(2)}%',
              style: TextStyle(
                fontSize: 14,
                height: 24/14,
                color: percentChange24h >= 0 ? const Color(0xFF00FFA3) : const Color(0xFFFF4D4D),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

