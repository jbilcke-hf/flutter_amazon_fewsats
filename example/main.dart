import 'package:flutter_amazon_fewsats/flutter_amazon_fewsats.dart';

void main() async {
  // Initialize the Amazon client
  final amazon = Amazon();
  
  try {
    // Search for products
    print('Searching for "laptop"...');
    final searchResults = await amazon.search('laptop');
    print('Search results: $searchResults');
    
    // Example shipping address
    final shippingAddress = {
      "full_name": "John Doe",
      "address": "123 Main St",
      "city": "New York",
      "state": "NY",
      "country": "US",
      "postalCode": "10001"
    };
    
    // Example user information
    final user = {
      "full_name": "John Doe",
      "email": "john@example.com",
    };
    
    // Get user information
    print('Getting user info...');
    final userInfo = await amazon.getUserInfo();
    print('User info: $userInfo');
    
    // Get user orders
    print('Getting user orders...');
    final orders = await amazon.getUserOrders();
    print('Orders: $orders');
    
    // Example: Buy a product (uncomment to test)
    // final asin = "B0C9S88QV6"; // Replace with actual ASIN
    // final result = await amazon.buyNow(asin, shippingAddress, user);
    // print('Purchase result: $result');
    
  } catch (e) {
    print('Error: $e');
  } finally {
    // Clean up
    amazon.dispose();
  }
}