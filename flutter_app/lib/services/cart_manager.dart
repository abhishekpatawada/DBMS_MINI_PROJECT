import 'dart:math';
import 'package:flutter/material.dart';
import '../models/models.dart';

class CartManager extends ChangeNotifier {
  // Singleton pattern
  static final CartManager instance = CartManager._internal();
  CartManager._internal();

  int? activeRestId;
  String? activeRestName;
  int? activeStoreId;
  String? activeStoreArea;
  String orderType = 'Restaurant';

  final Map<String, CartItemModel> _items = {};
  Map<String, CartItemModel> get items => Map.unmodifiable(_items);

  String? appliedCoupon;
  String deliveryAddress = "Home • Sector 62, Noida, Uttar Pradesh - 201309";

  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;

  int get totalCount => _items.values.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.values.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

  double get deliveryFee {
    if (isEmpty) return 0.0;
    return subtotal >= 499.0 ? 0.0 : 35.0;
  }

  double get taxes {
    if (isEmpty) return 0.0;
    return roundTo2(subtotal * 0.05); // 5% GST
  }

  double get discountAmount {
    if (isEmpty || appliedCoupon == null) return 0.0;
    if (appliedCoupon == "BITEHUB50") {
      // 50% off up to max ₹120
      return min(120.0, roundTo2(subtotal * 0.50));
    } else if (appliedCoupon == "FEAST20") {
      // 20% off
      return roundTo2(subtotal * 0.20);
    } else if (appliedCoupon == "FREEDEL") {
      // Free delivery
      return deliveryFee;
    }
    return 0.0;
  }

  double get grandTotal {
    if (isEmpty) return 0.0;
    return max(0.0, roundTo2(subtotal - discountAmount + deliveryFee + taxes));
  }

  static double roundTo2(double val) => (val * 100).roundToDouble() / 100;

  int getItemQuantity(String itemName) {
    return _items[itemName]?.quantity ?? 0;
  }

  bool canAddFrom({int? restId, String? restName, int? storeId, String? storeArea, required String type}) {
    if (isEmpty) return true;
    if (type == "Restaurant") {
      return activeRestId == restId;
    } else {
      return activeStoreId == storeId;
    }
  }

  void addItem({
    required String itemName,
    String? foodName,
    required double price,
    bool isVeg = true,
    String? imageUrl,
    int? restId,
    String? restName,
    int? storeId,
    String? storeArea,
    required String type,
  }) {
    // If adding from a different vendor, reset cart to new vendor
    if (!canAddFrom(restId: restId, storeId: storeId, type: type)) {
      clear();
    }

    orderType = type;
    if (type == "Restaurant") {
      activeRestId = restId;
      activeRestName = restName;
      activeStoreId = null;
      activeStoreArea = null;
    } else {
      activeStoreId = storeId;
      activeStoreArea = storeArea;
      activeRestId = null;
      activeRestName = null;
    }

    if (_items.containsKey(itemName)) {
      _items[itemName]!.quantity++;
    } else {
      _items[itemName] = CartItemModel(
        itemName: itemName,
        foodName: foodName,
        price: price,
        isVeg: isVeg,
        imageUrl: imageUrl,
        quantity: 1,
      );
    }
    notifyListeners();
  }

  void decrementItem(String itemName) {
    if (!_items.containsKey(itemName)) return;
    if (_items[itemName]!.quantity > 1) {
      _items[itemName]!.quantity--;
    } else {
      _items.remove(itemName);
    }

    if (_items.isEmpty) {
      clear();
    } else {
      notifyListeners();
    }
  }

  void removeItem(String itemName) {
    _items.remove(itemName);
    if (_items.isEmpty) {
      clear();
    } else {
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    activeRestId = null;
    activeRestName = null;
    activeStoreId = null;
    activeStoreArea = null;
    appliedCoupon = null;
    notifyListeners();
  }

  bool applyCoupon(String code) {
    final clean = code.trim().toUpperCase();
    if (clean == "BITEHUB50" || clean == "FEAST20" || clean == "FREEDEL") {
      appliedCoupon = clean;
      notifyListeners();
      return true;
    }
    return false;
  }

  void removeCoupon() {
    appliedCoupon = null;
    notifyListeners();
  }

  void setDeliveryAddress(String address) {
    deliveryAddress = address;
    notifyListeners();
  }

  List<Map<String, dynamic>> toOrderItemsPayload() {
    return _items.values.map((item) => item.toJson()).toList();
  }
}

// Global accessor
final cartManager = CartManager.instance;
