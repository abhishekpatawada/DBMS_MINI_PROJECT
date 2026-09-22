import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ApiService {
  // Configurable API base URL (Default for local development)
  static String baseUrl = "http://localhost:8000/api";

  // --- AUTH ---
  static Future<Map<String, dynamic>> login(String role, String phoneOrId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'role': role, 'phone_or_id': phoneOrId}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Login failed');
    }
  }

  static Future<Map<String, dynamic>> registerUser(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register/user'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Registration failed');
    }
  }

  static Future<Map<String, dynamic>> registerAgent(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register/agent'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Registration failed');
    }
  }

  static Future<Map<String, dynamic>> registerRestaurant(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register/restaurant'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Registration failed');
    }
  }

  static Future<Map<String, dynamic>> registerDarkStore(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register/dark-store'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Registration failed');
    }
  }

  // --- USERS ---
  static Future<List<UserModel>> getUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/users'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => UserModel.fromJson(e)).toList();
    }
    return [];
  }

  static Future<bool> updateUser(int userId, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/$userId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return response.statusCode == 200;
  }

  static Future<bool> deleteUser(int userId) async {
    final response = await http.delete(Uri.parse('$baseUrl/users/$userId'));
    return response.statusCode == 200;
  }

  // --- RESTAURANTS & MENU ---
  static Future<List<RestaurantModel>> getRestaurants() async {
    final response = await http.get(Uri.parse('$baseUrl/restaurants'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => RestaurantModel.fromJson(e)).toList();
    }
    return [];
  }

  static Future<List<RestaurantItemModel>> getRestaurantMenu(int restId) async {
    final response = await http.get(Uri.parse('$baseUrl/restaurants/$restId/menu'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => RestaurantItemModel.fromJson(e)).toList();
    }
    return [];
  }

  static Future<bool> addMenuItem(int restId, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/restaurants/$restId/menu'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return response.statusCode == 200;
  }

  static Future<bool> updateMenuItem(int restId, String itemName, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/restaurants/$restId/menu/$itemName'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return response.statusCode == 200;
  }

  static Future<bool> deleteMenuItem(int restId, String itemName) async {
    final response = await http.delete(Uri.parse('$baseUrl/restaurants/$restId/menu/$itemName'));
    return response.statusCode == 200;
  }

  // --- DARK STORES & GROCERIES ---
  static Future<List<DarkStoreModel>> getDarkStores() async {
    final response = await http.get(Uri.parse('$baseUrl/dark-stores'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => DarkStoreModel.fromJson(e)).toList();
    }
    return [];
  }

  static Future<List<GroceryItemModel>> getStoreGroceries(int storeId) async {
    final response = await http.get(Uri.parse('$baseUrl/dark-stores/$storeId/groceries'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => GroceryItemModel.fromJson(e)).toList();
    }
    return [];
  }

  static Future<bool> addGroceryItem(int storeId, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/dark-stores/$storeId/groceries'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return response.statusCode == 200;
  }

  static Future<bool> updateGroceryItem(int storeId, String itemName, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/dark-stores/$storeId/groceries/$itemName'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return response.statusCode == 200;
  }

  static Future<bool> deleteGroceryItem(int storeId, String itemName) async {
    final response = await http.delete(Uri.parse('$baseUrl/dark-stores/$storeId/groceries/$itemName'));
    return response.statusCode == 200;
  }

  // --- DELIVERY AGENTS ---
  static Future<List<DeliveryAgentModel>> getDeliveryAgents() async {
    final response = await http.get(Uri.parse('$baseUrl/delivery-agents'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => DeliveryAgentModel.fromJson(e)).toList();
    }
    return [];
  }

  static Future<List<OrderModel>> getAgentOrders(int agentId) async {
    final response = await http.get(Uri.parse('$baseUrl/delivery-agents/$agentId/orders'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => OrderModel.fromJson(e)).toList();
    }
    return [];
  }

  // --- ORDERS ---
  static Future<List<OrderModel>> getOrders() async {
    final response = await http.get(Uri.parse('$baseUrl/orders'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => OrderModel.fromJson(e)).toList();
    }
    return [];
  }

  static Future<List<OrderModel>> getUserOrders(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/orders/user/$userId'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => OrderModel.fromJson(e)).toList();
    }
    return [];
  }

  static Future<bool> placeOrder(Map<String, dynamic> orderPayload) async {
    final response = await http.post(
      Uri.parse('$baseUrl/orders'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(orderPayload),
    );
    return response.statusCode == 200;
  }

  static Future<bool> updateOrderStatus(int orderId, String status) async {
    final response = await http.put(
      Uri.parse('$baseUrl/orders/$orderId/status'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': status}),
    );
    return response.statusCode == 200;
  }

  static Future<bool> deleteOrder(int orderId) async {
    final response = await http.delete(Uri.parse('$baseUrl/orders/$orderId'));
    return response.statusCode == 200;
  }

  // --- SQL VISUALIZER & WORKBENCH ---
  static Future<Map<String, dynamic>> getSchemaMetadata() async {
    final response = await http.get(Uri.parse('$baseUrl/visualizer/schema'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception("Failed to load database schema metadata");
  }

  static Future<List<dynamic>> getPresetQueries() async {
    final response = await http.get(Uri.parse('$baseUrl/visualizer/presets'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['presets'] ?? [];
    }
    return [];
  }

  static Future<Map<String, dynamic>> executeSql(String query, {int maxRows = 100}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/visualizer/execute'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'query': query, 'max_rows': maxRows}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    final err = jsonDecode(response.body);
    throw Exception(err['detail'] ?? 'Query execution failed');
  }
}
