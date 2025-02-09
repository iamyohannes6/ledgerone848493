import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Discover',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  hintText: 'Search for a provider...',
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Colors.grey),
                ),
              ),
            ),
          ),
          
          // Categories Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Categories',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Categories ScrollView
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: Row(
              children: [
                _buildCategoryChip('ALL', true),
                _buildCategoryChip('SERVICES', false),
                _buildCategoryChip('LEDGER', false),
                _buildCategoryChip('DEFI', false),
                _buildCategoryChip('STAKE/EARN/MANAGE', false),
              ],
            ),
          ),
          
          // Provider List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildProviderItem(
                  'LEDGER RECOVER',
                  'Provided by Coincover',
                  'Try for free',
                  Colors.deepPurple,
                  'L',
                ),
                _buildProviderItem(
                  'REVOKE.CASH',
                  'https://revoke.cash',
                  null,
                  Colors.orange,
                  'R',
                ),
                _buildProviderItem(
                  'STADER LABS - ETHEREUM STAKING',
                  'https://www.staderlabs.com/eth/',
                  null,
                  Colors.green,
                  'S',
                ),
                _buildProviderItem(
                  'KELP DAO - LIQUID RESTAKING',
                  'https://kelpdao.xyz/',
                  null,
                  Colors.teal,
                  'K',
                ),
                _buildProviderItem(
                  '1INCH',
                  'https://1inch.io/',
                  null,
                  Colors.black,
                  '1',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF9D7BEE) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: !isSelected ? Border.all(color: Colors.grey[300]!) : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildProviderItem(String title, String subtitle, String? actionText, Color iconColor, String iconText) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                iconText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
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
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (actionText != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF9D7BEE),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                actionText,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
} 