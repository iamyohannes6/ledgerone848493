import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/crypto_currency.dart';

class CoinMarketCapService {
  // In development, use localhost. In production, use the Netlify domain
  static String get _baseUrl {
    const isProd = bool.fromEnvironment('dart.vm.product');
    return isProd 
        ? '/api'
        : 'http://localhost:8888/.netlify/functions';
  }

  Future<List<CryptoCurrency>> getAvailableCryptocurrencies() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/getCryptoData/cryptocurrencies'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => CryptoCurrency.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load cryptocurrencies');
      }
    } catch (e) {
      print('Error fetching cryptocurrencies: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getLatestPrices() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/getCryptoData/prices'));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load prices');
      }
    } catch (e) {
      print('Error fetching prices: $e');
      rethrow;
    }
  }

  Future<List<CryptoCurrency>> getUpdatedCryptocurrencies(List<CryptoCurrency> currencies) async {
    try {
      final prices = await getLatestPrices();
      
      return currencies.map((currency) {
        final priceData = prices[currency.symbol];
        if (priceData != null) {
          return currency.copyWith(
            value: priceData['price'],
            percentChange24h: priceData['percentChange24h'],
          );
        }
        return currency;
      }).toList();
    } catch (e) {
      print('Error updating cryptocurrencies: $e');
      return currencies;
    }
  }
} 