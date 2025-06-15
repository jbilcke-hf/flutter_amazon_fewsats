# flutter_amazon_fewsats

Flutter SDK to interact with the Amazon-Fewsats Marketplace API.

This package provides methods to interact with the Amazon-Fewsats Marketplace API, including product search, cart management, and checkout functionality.

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_amazon_fewsats: ^0.0.7
```

Then run:

```bash
flutter pub get
```

## Usage

### Basic Setup

```dart
import 'package:flutter_amazon_fewsats/flutter_amazon_fewsats.dart';

void main() async {
  // Initialize the Amazon client
  final amazon = Amazon();
  
  // Use the client...
  
  // Don't forget to dispose when done
  amazon.dispose();
}
```

### Search for Products

```dart
final searchResults = await amazon.search('laptop');
print('Search results: $searchResults');
```

### Purchase a Product

```dart
final shippingAddress = {
  "full_name": "John Doe",
  "address": "123 Main St",
  "city": "New York",
  "state": "NY",
  "country": "US",
  "postalCode": "10001"
};

final user = {
  "full_name": "John Doe",
  "email": "john@example.com",
};

final asin = "B0C9S88QV6"; // Product ASIN
final result = await amazon.buyNow(asin, shippingAddress, user);
print('Purchase result: $result');
```

### Get User Orders

```dart
final orders = await amazon.getUserOrders();
print('Orders: $orders');
```

### Get Order Details

```dart
// By external ID
final order = await amazon.getOrderByExternalId('order_123');

// By payment token
final order2 = await amazon.getOrderByPaymentToken('payment_token_123');
```

### Advanced Usage with X402 Payment Protocol

```dart
final result = await amazon.buyNowWithX402(
  asin,
  shippingAddress,
  user,
  quantity: 2,
  xPayment: 'payment_info',
);
```

## API Reference

### Amazon Class

The main client class for interacting with the Amazon-Fewsats Marketplace API.

#### Constructor

```dart
Amazon({
  String baseUrl = "https://amazon-backend.replit.app/api/v1",
  String? privateKey,
})
```

#### Methods

- `search(String query, {String domain = "amazon.com"})` - Search for products
- `buyNow(String asin, Map<String, dynamic> shippingAddress, Map<String, dynamic> user, {String? productUrl, int quantity = 1})` - Purchase a product
- `buyNowWithX402(...)` - Purchase with X402 payment protocol
- `getUserOrders()` - Get all user orders
- `getOrderByExternalId(String externalId)` - Get order by external ID
- `getOrderByPaymentToken(String paymentToken)` - Get order by payment token
- `getUserInfo()` - Get user profile and shipping addresses
- `dispose()` - Clean up resources

## Configuration

The package automatically manages cryptographic keys for authentication. Keys are stored securely in the application's support directory.

## License

This project is licensed under the same terms as the original Python library.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.