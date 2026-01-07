import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  /// Fiat → Fiat
  static Future<double> convertCurrency(
      String from, String to, double amount) async {
    final url =
        'https://api.exchangerate.host/convert?from=$from&to=$to&amount=$amount';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) throw Exception('Currency API failed');

    final data = json.decode(response.body);
    if (data['result'] == null) return 0;

    return (data['result'] as num).toDouble();
  }

  /// Crypto → Fiat
  static Future<double> convertCrypto(
      String crypto, String to, double amount) async {
    final idMap = {
      'BTC': 'bitcoin',
      'ETH': 'ethereum',
      'LTC': 'litecoin',
      'DOGE': 'dogecoin',
      'ADA': 'cardano',
      'BNB': 'binancecoin',
      'XRP': 'ripple',
      'SOL': 'solana',
      'DOT': 'polkadot',
    };

    if (!idMap.containsKey(crypto)) return 0;

    final url =
        'https://api.coingecko.com/api/v3/simple/price?ids=${idMap[crypto]}&vs_currencies=${to.toLowerCase()}';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) throw Exception('Crypto API failed');

    final data = json.decode(response.body);

    if (data[idMap[crypto]] == null ||
        data[idMap[crypto]][to.toLowerCase()] == null) return 0;

    final price = (data[idMap[crypto]][to.toLowerCase()] as num).toDouble();
    return price * amount;
  }
}
