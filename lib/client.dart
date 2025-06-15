import 'dart:convert';
import 'package:http/http.dart' as http;
import 'crypto.dart';
import 'config.dart';

/// Client for the Amazon-Fewsats Marketplace API.
/// 
/// This client provides methods to interact with the Amazon-Fewsats Marketplace API,
/// including product search, cart management, and checkout functionality.
class Amazon {
  final String baseUrl;
  late KeyPair _keyPair;
  late http.Client _client;

  Amazon({
    this.baseUrl = "https://amazon-backend.replit.app/api/v1",
    String? privateKey,
  }) {
    _initializeClient(privateKey);
  }

  Future<void> _initializeClient(String? privateKey) async {
    final config = await getConfig();
    
    if (privateKey != null && privateKey.isNotEmpty) {
      _keyPair = fromPkHex(privateKey);
    } else if (config.priv.isNotEmpty) {
      _keyPair = fromPkHex(config.priv);
    } else {
      _keyPair = generateKeys();
      await saveConfigFromMap({'priv': privKeyHex(_keyPair.privateKey)});
    }
    
    _client = http.Client();
  }

  /// Make a request to the Amazon-Fewsats Backend API.
  Future<http.Response> _makeRequest(
    String method,
    String endpoint, {
    Map<String, String>? params,
    Map<String, dynamic>? jsonData,
    Map<String, String>? additionalHeaders,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final finalUrl = params != null ? url.replace(queryParameters: params) : url;
    
    final headers = <String, String>{
      'user-id': pubKeyHex(_keyPair.publicKey),
      'Content-Type': 'application/json',
      ...?additionalHeaders,
    };

    http.Response response;
    
    switch (method.toUpperCase()) {
      case 'GET':
        response = await _client.get(finalUrl, headers: headers).timeout(timeout);
        break;
      case 'POST':
        final body = jsonData != null ? jsonEncode(jsonData) : null;
        response = await _client.post(finalUrl, headers: headers, body: body).timeout(timeout);
        break;
      default:
        throw ArgumentError('Unsupported HTTP method: $method');
    }
    
    return response;
  }

  /// Search for products.
  /// 
  /// Args:
  ///   query: The search query.
  ///   domain: The amazon domain to search on (e.g. "amazon.com" or "amazon.es")
  /// 
  /// Returns:
  ///   The search results.
  Future<Map<String, dynamic>> search(String query, {String domain = "amazon.com"}) async {
    final response = await _makeRequest(
      'GET',
      'search',
      params: {
        'q': query,
        'domain': domain,
      },
    );
    return jsonDecode(response.body);
  }

  /// Purchase a product directly.
  /// 
  /// Args:
  ///   asin: The product asin.
  ///   quantity: The quantity to purchase.
  ///   shippingAddress: The shipping address.
  ///   user: The user information.
  ///   productUrl: The URL of the product in amazon.
  /// 
  /// Example:
  ///   ```dart
  ///   final shippingAddress = {
  ///     "full_name": "John Doe",
  ///     "address": "123 Main St",
  ///     "city": "New York",
  ///     "state": "NY",
  ///     "country": "US",
  ///     "postalCode": "10001"
  ///   };
  ///   
  ///   final user = {
  ///     "full_name": "John Doe",
  ///     "email": "john@example.com",
  ///   };
  ///   
  ///   await amazon.buyNow(asin, shippingAddress, user, productUrl: productUrl);
  ///   ```
  /// 
  /// Returns:
  ///   The payment information.
  Future<Map<String, dynamic>> buyNow(
    String asin,
    Map<String, dynamic> shippingAddress,
    Map<String, dynamic> user, {
    String? productUrl,
    int quantity = 1,
  }) async {
    final requestData = {
      'external_id': asin,
      'quantity': quantity,
      'shipping_address': shippingAddress,
      'user': user,
      'product_url': productUrl,
    };

    final response = await _makeRequest('POST', 'buy-now', jsonData: requestData);
    return jsonDecode(response.body);
  }

  /// Purchase a product directly with x402 payment protocol.
  /// 
  /// Args:
  ///   asin: The product asin.
  ///   quantity: The quantity to purchase.
  ///   shippingAddress: The shipping address.
  ///   user: The user information.
  ///   productUrl: The URL of the product in amazon.
  ///   xPayment: Optional X-PAYMENT header value.
  /// 
  /// Returns:
  ///   The payment information.
  Future<Map<String, dynamic>> buyNowWithX402(
    String asin,
    Map<String, dynamic> shippingAddress,
    Map<String, dynamic> user, {
    int quantity = 1,
    String? xPayment,
    String productUrl = '',
  }) async {
    final requestData = {
      'external_id': asin,
      'quantity': quantity,
      'shipping_address': shippingAddress,
      'user': user,
      'product_url': productUrl,
    };

    final headers = <String, String>{
      'Payment-Protocol': 'x402',
    };
    
    if (xPayment != null) {
      headers['X-PAYMENT'] = xPayment;
    }

    final response = await _makeRequest(
      'POST',
      'buy-now',
      jsonData: requestData,
      additionalHeaders: headers,
    );
    return jsonDecode(response.body);
  }

  /// Get all orders for the current user.
  /// 
  /// Returns:
  ///   A list of orders.
  Future<List<Map<String, dynamic>>> getUserOrders() async {
    final response = await _makeRequest('GET', 'users/orders');
    return List<Map<String, dynamic>>.from(jsonDecode(response.body));
  }

  /// Get details for a specific order.
  /// 
  /// Args:
  ///   externalId: The external ID of the order.
  /// 
  /// Returns:
  ///   The order details.
  Future<Map<String, dynamic>> getOrderByExternalId(String externalId) async {
    final response = await _makeRequest('GET', 'orders/$externalId');
    return jsonDecode(response.body);
  }

  /// Get details for a specific order.
  /// 
  /// Args:
  ///   paymentToken: The payment context token of the order.
  /// 
  /// Returns:
  ///   The order details.
  Future<Map<String, dynamic>> getOrderByPaymentToken(String paymentToken) async {
    final response = await _makeRequest('GET', 'payments/$paymentToken');
    return jsonDecode(response.body);
  }

  /// Get the current user's profile and shipping addresses.
  /// 
  /// Returns:
  ///   Map containing user profile info (full_name, email) and list of shipping addresses
  Future<Map<String, dynamic>> getUserInfo() async {
    final response = await _makeRequest('GET', 'user/info');
    return jsonDecode(response.body);
  }

  /// Dispose of the HTTP client when done
  void dispose() {
    _client.close();
  }
}