import 'package:flutter/material.dart';

class MarketScreen extends StatelessWidget {
  const MarketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                border: InputBorder.none,
                icon: Icon(Icons.search, color: Colors.grey),
              ),
            ),
          ),
        ),

        // Filter Options
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              _buildFilterOption(Icons.star_border, 'Sort Rank', 'down', true),
              _buildFilterOption(null, 'Time', '24H', false),
              _buildFilterOption(null, 'Currency', 'USD', false),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Market List
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildMarketItem('Bitcoin', 'BTC', '\$95,941', '-2.11%', '1', '\$1.9 tn', '฿'),
              _buildMarketItem('Ethereum', 'ETH', '\$2,601.3', '-4.07%', '2', '\$313.59 bn', 'Ξ'),
              _buildMarketItem('Tether USD', 'USDT', '\$1', '-0.06%', '3', '\$141.63 bn', '₮'),
              _buildMarketItem('XRP', 'XRP', '\$2.39', '-3.42%', '4', '\$138.18 bn', '✕'),
              _buildMarketItem('Solana', 'SOL', '\$194.1', '-1.83%', '5', '\$94.69 bn', '◎'),
              _buildMarketItem('BNB', 'BNB', '\$603.91', '+3.51%', '6', '\$87.96 bn', 'BNB'),
              _buildMarketItem('USDC', 'USDC', '\$1', '-0.01%', '7', '\$56.02 bn', '\$'),
              _buildMarketItem('Dogecoin', 'DOGE', '\$0.25', '-1.82%', '8', '\$36.88 bn', 'Ð'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterOption(IconData? icon, String label, String value, bool isFirst) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[800],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              color: const Color(0xFF9D7BEE),
              fontWeight: FontWeight.w500,
            ),
          ),
          if (label == 'Sort Rank')
            Icon(
              Icons.arrow_downward,
              size: 16,
              color: Colors.grey[600],
            ),
        ],
      ),
    );
  }

  Widget _buildMarketItem(String name, String symbol, String price, String change, 
      String rank, String marketCap, String icon) {
    final isPositive = change.startsWith('+');
    final changeColor = isPositive ? Colors.green : Colors.red;
    final changeIcon = isPositive ? Icons.arrow_upward : Icons.arrow_downward;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF9D7BEE).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                icon,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        rank,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  marketCap,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Row(
                children: [
                  Icon(
                    changeIcon,
                    size: 14,
                    color: changeColor,
                  ),
                  Text(
                    change,
                    style: TextStyle(
                      color: changeColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
} 