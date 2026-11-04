import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GalleryImageItem {
  final String title;
  final String category;
  final String imageUrl;
  final bool isVeg;

  const GalleryImageItem({
    required this.title,
    required this.category,
    required this.imageUrl,
    this.isVeg = true,
  });
}

class ItemImageHelper {
  // ===========================================================================
  // CURATED RESTAURANT FOOD GALLERY
  // ===========================================================================
  static const List<GalleryImageItem> foodGalleryItems = [
    // Biryani & Rice
    GalleryImageItem(
      title: "Hyderabadi Chicken Biryani",
      category: "Biryani",
      imageUrl: "https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=500&auto=format&fit=crop&q=80",
      isVeg: false,
    ),
    GalleryImageItem(
      title: "Veg Dum Biryani",
      category: "Biryani",
      imageUrl: "https://images.unsplash.com/photo-1642821373181-696a54913e9a?w=500&auto=format&fit=crop&q=80",
      isVeg: true,
    ),
    GalleryImageItem(
      title: "Chicken Fried Rice",
      category: "Biryani",
      imageUrl: "https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=500&auto=format&fit=crop&q=80",
      isVeg: false,
    ),

    // Pizzas
    GalleryImageItem(
      title: "Classic Margherita Pizza",
      category: "Pizza",
      imageUrl: "https://images.unsplash.com/photo-1513104890138-7c749659a591?w=500&auto=format&fit=crop&q=80",
      isVeg: true,
    ),
    GalleryImageItem(
      title: "Farmhouse Veggie Pizza",
      category: "Pizza",
      imageUrl: "https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=500&auto=format&fit=crop&q=80",
      isVeg: true,
    ),
    GalleryImageItem(
      title: "Spicy Pepperoni Pizza",
      category: "Pizza",
      imageUrl: "https://images.unsplash.com/photo-1628840042765-356cda07504e?w=500&auto=format&fit=crop&q=80",
      isVeg: false,
    ),

    // Burgers
    GalleryImageItem(
      title: "Crispy Veg Supreme Burger",
      category: "Burgers",
      imageUrl: "https://images.unsplash.com/photo-1550547660-d9450f859349?w=500&auto=format&fit=crop&q=80",
      isVeg: true,
    ),
    GalleryImageItem(
      title: "Crunchy Chicken Burger",
      category: "Burgers",
      imageUrl: "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500&auto=format&fit=crop&q=80",
      isVeg: false,
    ),
    GalleryImageItem(
      title: "Golden French Fries",
      category: "Burgers",
      imageUrl: "https://images.unsplash.com/photo-1576107232684-1279f3908594?w=500&auto=format&fit=crop&q=80",
      isVeg: true,
    ),

    // Curries & Indian Main
    GalleryImageItem(
      title: "Paneer Butter Masala",
      category: "Curries",
      imageUrl: "https://images.unsplash.com/photo-1631452180519-c014fe946bc7?w=500&auto=format&fit=crop&q=80",
      isVeg: true,
    ),
    GalleryImageItem(
      title: "Creamy Butter Chicken",
      category: "Curries",
      imageUrl: "https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?w=500&auto=format&fit=crop&q=80",
      isVeg: false,
    ),
    GalleryImageItem(
      title: "Dal Makhani Handi",
      category: "Curries",
      imageUrl: "https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=500&auto=format&fit=crop&q=80",
      isVeg: true,
    ),
    GalleryImageItem(
      title: "Chole Bhature",
      category: "Curries",
      imageUrl: "https://images.unsplash.com/photo-1626132647523-66f5bf380027?w=500&auto=format&fit=crop&q=80",
      isVeg: true,
    ),
    GalleryImageItem(
      title: "Spicy Fish Curry",
      category: "Curries",
      imageUrl: "https://images.unsplash.com/photo-1534422298391-e4f8c172dddb?w=500&auto=format&fit=crop&q=80",
      isVeg: false,
    ),

    // Breads
    GalleryImageItem(
      title: "Butter Garlic Naan",
      category: "Breads",
      imageUrl: "https://images.unsplash.com/photo-1601050690597-df0568f70950?w=500&auto=format&fit=crop&q=80",
      isVeg: true,
    ),
    GalleryImageItem(
      title: "Tandoori Roti",
      category: "Breads",
      imageUrl: "https://images.unsplash.com/photo-1626777552726-4a6b54c97e46?w=500&auto=format&fit=crop&q=80",
      isVeg: true,
    ),

    // Starters & Rolls
    GalleryImageItem(
      title: "Smoky Chicken Tikka",
      category: "Starters",
      imageUrl: "https://images.unsplash.com/photo-1599488615731-7e5c2823ff28?w=500&auto=format&fit=crop&q=80",
      isVeg: false,
    ),
    GalleryImageItem(
      title: "Paneer Tikka Platter",
      category: "Starters",
      imageUrl: "https://images.unsplash.com/photo-1567188040759-fb8a883dc6d8?w=500&auto=format&fit=crop&q=80",
      isVeg: true,
    ),
    GalleryImageItem(
      title: "Crispy Chicken Wings",
      category: "Starters",
      imageUrl: "https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=500&auto=format&fit=crop&q=80",
      isVeg: false,
    ),
    GalleryImageItem(
      title: "Chicken Shawarma Wrap",
      category: "Starters",
      imageUrl: "https://images.unsplash.com/photo-1529006557810-274b9b2fc783?w=500&auto=format&fit=crop&q=80",
      isVeg: false,
    ),
    GalleryImageItem(
      title: "Falafel Roll Wrap",
      category: "Starters",
      imageUrl: "https://images.unsplash.com/photo-1626700051175-6818013e1d4f?w=500&auto=format&fit=crop&q=80",
      isVeg: true,
    ),
    GalleryImageItem(
      title: "Steamed Dimsums & Momos",
      category: "Starters",
      imageUrl: "https://images.unsplash.com/photo-1625246333195-78d9c38ad449?w=500&auto=format&fit=crop&q=80",
      isVeg: true,
    ),

    // South Indian
    GalleryImageItem(
      title: "Crispy Masala Dosa",
      category: "South Indian",
      imageUrl: "https://images.unsplash.com/photo-1668236543090-82eba5ee5976?w=500&auto=format&fit=crop&q=80",
      isVeg: true,
    ),
    GalleryImageItem(
      title: "Idli Vada Sambar Combo",
      category: "South Indian",
      imageUrl: "https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=500&auto=format&fit=crop&q=80",
      isVeg: true,
    ),

    // Pastas & Chinese
    GalleryImageItem(
      title: "Creamy White Sauce Pasta",
      category: "Pasta & Chinese",
      imageUrl: "https://images.unsplash.com/photo-1621996346565-e3d5d6281292?w=500&auto=format&fit=crop&q=80",
      isVeg: true,
    ),
    GalleryImageItem(
      title: "Spicy Hakka Noodles",
      category: "Pasta & Chinese",
      imageUrl: "https://images.unsplash.com/photo-1585032226651-759b368d7246?w=500&auto=format&fit=crop&q=80",
      isVeg: true,
    ),
    GalleryImageItem(
      title: "Veg Manchurian Dry",
      category: "Pasta & Chinese",
      imageUrl: "https://images.unsplash.com/photo-1525755662778-989d0524087e?w=500&auto=format&fit=crop&q=80",
      isVeg: true,
    ),
    GalleryImageItem(
      title: "Chilli Chicken Gravy",
      category: "Pasta & Chinese",
      imageUrl: "https://images.unsplash.com/photo-1567620832903-9fc6debc209f?w=500&auto=format&fit=crop&q=80",
      isVeg: false,
    ),

    // Desserts & Beverages
    GalleryImageItem(
      title: "Warm Chocolate Brownie",
      category: "Desserts & Drinks",
      imageUrl: "https://images.unsplash.com/photo-1606313564200-e75d5e30476c?w=500&auto=format&fit=crop&q=80",
      isVeg: true,
    ),
    GalleryImageItem(
      title: "Gulab Jamun with Pistachio",
      category: "Desserts & Drinks",
      imageUrl: "https://images.unsplash.com/photo-1605197140578-831db621a206?w=500&auto=format&fit=crop&q=80",
      isVeg: true,
    ),
    GalleryImageItem(
      title: "Iced Cold Coffee with Foam",
      category: "Desserts & Drinks",
      imageUrl: "https://images.unsplash.com/photo-1517256064527-09c73fc73e38?w=500&auto=format&fit=crop&q=80",
      isVeg: true,
    ),
    GalleryImageItem(
      title: "Chilled Mango Lassi",
      category: "Desserts & Drinks",
      imageUrl: "https://images.unsplash.com/photo-1546173159-315724a31696?w=500&auto=format&fit=crop&q=80",
      isVeg: true,
    ),
    GalleryImageItem(
      title: "Street Pav Bhaji",
      category: "Starters",
      imageUrl: "https://images.unsplash.com/photo-1606491956689-2ea866880c84?w=500&auto=format&fit=crop&q=80",
      isVeg: true,
    ),
  ];

  // ===========================================================================
  // CURATED DARK STORE GROCERY GALLERY
  // ===========================================================================
  static const List<GalleryImageItem> groceryGalleryItems = [
    // Dairy & Eggs
    GalleryImageItem(
      title: "Amul Fresh Butter 500g",
      category: "Dairy & Eggs",
      imageUrl: "https://images.unsplash.com/photo-1589985270826-4b7bb135bc9d?w=500&auto=format&fit=crop&q=80",
    ),
    GalleryImageItem(
      title: "Pasteurized Milk 1L Pack",
      category: "Dairy & Eggs",
      imageUrl: "https://images.unsplash.com/photo-1550583724-b2692b85b150?w=500&auto=format&fit=crop&q=80",
    ),
    GalleryImageItem(
      title: "Farm Fresh Organic Eggs (6/12 pcs)",
      category: "Dairy & Eggs",
      imageUrl: "https://images.unsplash.com/photo-1516448620398-c5f44bf9f441?w=500&auto=format&fit=crop&q=80",
    ),
    GalleryImageItem(
      title: "Amul Cheese Slices 200g",
      category: "Dairy & Eggs",
      imageUrl: "https://images.unsplash.com/photo-1618160702438-9b02ab6515c9?w=500&auto=format&fit=crop&q=80",
    ),
    GalleryImageItem(
      title: "Fresh Malai Paneer 200g",
      category: "Dairy & Eggs",
      imageUrl: "https://images.unsplash.com/photo-1631452180519-c014fe946bc7?w=500&auto=format&fit=crop&q=80",
    ),
    GalleryImageItem(
      title: "Greek Fruit Yogurt 100g",
      category: "Dairy & Eggs",
      imageUrl: "https://images.unsplash.com/photo-1488477181946-6428a0291777?w=500&auto=format&fit=crop&q=80",
    ),

    // Bakery & Breakfast
    GalleryImageItem(
      title: "Whole Wheat Brown Bread 400g",
      category: "Bakery",
      imageUrl: "https://images.unsplash.com/photo-1509440159596-0249088772ff?w=500&auto=format&fit=crop&q=80",
    ),
    GalleryImageItem(
      title: "Maggi 2-Minute Noodles 280g",
      category: "Bakery",
      imageUrl: "https://images.unsplash.com/photo-1612927601601-6638404737ce?w=500&auto=format&fit=crop&q=80",
    ),
    GalleryImageItem(
      title: "Nutella Hazelnut Cocoa Spread 350g",
      category: "Bakery",
      imageUrl: "https://images.unsplash.com/photo-1541592106381-b31e9677c0e5?w=500&auto=format&fit=crop&q=80",
    ),
    GalleryImageItem(
      title: "Classic Tomato Ketchup 1kg",
      category: "Bakery",
      imageUrl: "https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=500&auto=format&fit=crop&q=80",
    ),

    // Staples & Grains
    GalleryImageItem(
      title: "Aashirvaad Shudh Chakki Atta 5kg",
      category: "Staples",
      imageUrl: "https://images.unsplash.com/photo-1509440159596-0249088772ff?w=500&auto=format&fit=crop&q=80",
    ),
    GalleryImageItem(
      title: "India Gate Basmati Rice 5kg",
      category: "Staples",
      imageUrl: "https://images.unsplash.com/photo-1586201375761-83865001e31c?w=500&auto=format&fit=crop&q=80",
    ),
    GalleryImageItem(
      title: "Fortune Refined Sunflower Oil 1L",
      category: "Staples",
      imageUrl: "https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=500&auto=format&fit=crop&q=80",
    ),
    GalleryImageItem(
      title: "Tata Sampann Toor Dal 1kg",
      category: "Staples",
      imageUrl: "https://images.unsplash.com/photo-1585994192701-512cb59f0f97?w=500&auto=format&fit=crop&q=80",
    ),
    GalleryImageItem(
      title: "Tata Salt Iodized 1kg",
      category: "Staples",
      imageUrl: "https://images.unsplash.com/photo-1518110925495-5fe2fda0442c?w=500&auto=format&fit=crop&q=80",
    ),
    GalleryImageItem(
      title: "Madhur Refined Pure Sugar 1kg",
      category: "Staples",
      imageUrl: "https://images.unsplash.com/photo-1587735243615-c03f25aaff15?w=500&auto=format&fit=crop&q=80",
    ),

    // Snacks & Beverages
    GalleryImageItem(
      title: "Lays Classic Salted Chips 50g",
      category: "Snacks",
      imageUrl: "https://images.unsplash.com/photo-1566478989037-eec170784d0b?w=500&auto=format&fit=crop&q=80",
    ),
    GalleryImageItem(
      title: "Oreo Vanilla Creme Cookies 120g",
      category: "Snacks",
      imageUrl: "https://images.unsplash.com/photo-1558961363-fa8fdf82db35?w=500&auto=format&fit=crop&q=80",
    ),
    GalleryImageItem(
      title: "Cadbury Dairy Milk Silk 150g",
      category: "Snacks",
      imageUrl: "https://images.unsplash.com/photo-1549007994-cb92caebd54b?w=500&auto=format&fit=crop&q=80",
    ),
    GalleryImageItem(
      title: "Nescafe Classic Instant Coffee 100g",
      category: "Snacks",
      imageUrl: "https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=500&auto=format&fit=crop&q=80",
    ),
    GalleryImageItem(
      title: "Taj Mahal Premium Tea 500g",
      category: "Snacks",
      imageUrl: "https://images.unsplash.com/photo-1576092768241-dec231879fc3?w=500&auto=format&fit=crop&q=80",
    ),

    // Fresh Produce
    GalleryImageItem(
      title: "Fresh Farm Red Onions 1kg",
      category: "Fresh Produce",
      imageUrl: "https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=500&auto=format&fit=crop&q=80",
    ),
    GalleryImageItem(
      title: "Fresh Golden Potatoes 1kg",
      category: "Fresh Produce",
      imageUrl: "https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=500&auto=format&fit=crop&q=80",
    ),
    GalleryImageItem(
      title: "Fresh Juicy Tomatoes 1kg",
      category: "Fresh Produce",
      imageUrl: "https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=500&auto=format&fit=crop&q=80",
    ),

    // Personal & Home Care
    GalleryImageItem(
      title: "Dettol Original Bath Soap (3 pcs)",
      category: "Personal & Home",
      imageUrl: "https://images.unsplash.com/photo-1608248597359-364e0a4f5263?w=500&auto=format&fit=crop&q=80",
    ),
    GalleryImageItem(
      title: "Colgate Strong Teeth 150g",
      category: "Personal & Home",
      imageUrl: "https://images.unsplash.com/photo-1559591937-e62fb330f248?w=500&auto=format&fit=crop&q=80",
    ),
    GalleryImageItem(
      title: "Head & Shoulders Shampoo 340ml",
      category: "Personal & Home",
      imageUrl: "https://images.unsplash.com/photo-1535585209827-a15fcdbc4c2d?w=500&auto=format&fit=crop&q=80",
    ),
    GalleryImageItem(
      title: "Vim Lemon Dishwash Gel 750ml",
      category: "Personal & Home",
      imageUrl: "https://images.unsplash.com/photo-1585421514284-efb74c2b69ba?w=500&auto=format&fit=crop&q=80",
    ),
  ];

  // ===========================================================================
  // RESOLVE IMAGE URL (From DB if available, else best keyword match)
  // ===========================================================================
  static String resolveItemImage(String? customUrl, String itemName, {String? category, bool isGrocery = false}) {
    if (customUrl != null && customUrl.trim().isNotEmpty && customUrl.startsWith("http")) {
      return customUrl.trim();
    }

    final query = "${itemName.toLowerCase()} ${(category ?? '').toLowerCase()}";
    final catalog = isGrocery ? groceryGalleryItems : foodGalleryItems;

    for (final item in catalog) {
      final title = item.title.toLowerCase();
      // Check title keywords
      final words = title.split(RegExp(r'\s+'));
      for (final word in words) {
        if (word.length >= 4 && query.contains(word)) {
          return item.imageUrl;
        }
      }
    }

    // Default fallbacks
    if (isGrocery) {
      return "https://images.unsplash.com/photo-1542838132-92c53300491e?w=500&auto=format&fit=crop&q=80";
    }
    return "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&auto=format&fit=crop&q=80";
  }

  static const List<String> curatedRestaurantBanners = [
    "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800&auto=format&fit=crop&q=80",  // 1: Royal Palace (Fine Dining Banquet)
    "https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=800&auto=format&fit=crop&q=80",  // 2: Spice House (Indian Curries & Spices)
    "https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=800&auto=format&fit=crop&q=80",  // 3: Taste of Bawarchi (Authentic Biryani & Kebabs)
    "https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=800&auto=format&fit=crop&q=80",  // 4: The Golden Junction (Warm Gourmet Bistro)
    "https://images.unsplash.com/photo-1552566626-52f8b828add9?w=800&auto=format&fit=crop&q=80",  // 5: Urban Tales (Modern Aesthetic Cafe & Brunch)
    "https://images.unsplash.com/photo-1601050690597-df0568f70950?w=800&auto=format&fit=crop&q=80",  // 6: Flavors of Street (Sizzling Street Food & Tandoor)
    "https://images.unsplash.com/photo-1513104890138-7c749659a591?w=800&auto=format&fit=crop&q=80",  // 7: Grand Plate (Italian Artisan Pizzeria & Pasta)
    "https://images.unsplash.com/photo-1626777552726-4a6b54c97e46?w=800&auto=format&fit=crop&q=80",  // 8: Desi Diner (Punjabi Highway Dhaba)
    "https://images.unsplash.com/photo-1544025162-d76694265947?w=800&auto=format&fit=crop&q=80",  // 9: Kitchen Grill (Smoked Charcoal BBQ & Steaks)
    "https://images.unsplash.com/photo-1631452180519-c014fe946bc7?w=800&auto=format&fit=crop&q=80",  // 10: Saffron Hub (Saffron Royal Mughlai)
    "https://images.unsplash.com/photo-1668236543090-82eba5ee5976?w=800&auto=format&fit=crop&q=80",  // 11: Crispy Dosa & South Indian
    "https://images.unsplash.com/photo-1585032226651-759b368d7246?w=800&auto=format&fit=crop&q=80",  // 12: Dimsum & Asian Wok Noodles
    "https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=800&auto=format&fit=crop&q=80",  // 13: Artisan Desserts & Bakery
    "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=800&auto=format&fit=crop&q=80",  // 14: Gourmet Juicy Burgers & Shakes
    "https://images.unsplash.com/photo-1540420773420-3366772f4999?w=800&auto=format&fit=crop&q=80",  // 15: Fresh Mediterranean & Salad Bar
    "https://images.unsplash.com/photo-1579027989536-b7b1f875659b?w=800&auto=format&fit=crop&q=80",  // 16: Sizzling Tacos & Mexican
    "https://images.unsplash.com/photo-1590846406792-0adc7f938f1d?w=800&auto=format&fit=crop&q=80",  // 17: Rooftop Lounge & Cocktails
  ];

  static String getBannerForRestaurant(String rName, {int? restId, String? imageUrl}) {
    if (imageUrl != null && imageUrl.trim().isNotEmpty) {
      return imageUrl.trim();
    }

    final lower = rName.toLowerCase();
    if (lower.contains("royal") || lower.contains("palace")) {
      return curatedRestaurantBanners[0];
    }
    if (lower.contains("spice") || lower.contains("house") || lower.contains("curry")) {
      return curatedRestaurantBanners[1];
    }
    if (lower.contains("bawarchi") || lower.contains("biryani") || lower.contains("darbar") || lower.contains("behrouz")) {
      return curatedRestaurantBanners[2];
    }
    if (lower.contains("golden") || lower.contains("junction")) {
      return curatedRestaurantBanners[3];
    }
    if (lower.contains("urban") || lower.contains("tales") || lower.contains("cafe") || lower.contains("bistro")) {
      return curatedRestaurantBanners[4];
    }
    if (lower.contains("flavor") || lower.contains("street") || lower.contains("chaat")) {
      return curatedRestaurantBanners[5];
    }
    if (lower.contains("grand") || lower.contains("plate") || lower.contains("pizza") || lower.contains("italian")) {
      return curatedRestaurantBanners[6];
    }
    if (lower.contains("desi") || lower.contains("diner") || lower.contains("dhaba") || lower.contains("punjabi")) {
      return curatedRestaurantBanners[7];
    }
    if (lower.contains("grill") || lower.contains("kitchen") || lower.contains("bbq") || lower.contains("smoke")) {
      return curatedRestaurantBanners[8];
    }
    if (lower.contains("saffron") || lower.contains("hub") || lower.contains("mughlai")) {
      return curatedRestaurantBanners[9];
    }
    if (lower.contains("south") || lower.contains("dosa") || lower.contains("idli") || lower.contains("sagar")) {
      return curatedRestaurantBanners[10];
    }
    if (lower.contains("chinese") || lower.contains("noodle") || lower.contains("wok") || lower.contains("momo") || lower.contains("asian")) {
      return curatedRestaurantBanners[11];
    }
    if (lower.contains("sweet") || lower.contains("dessert") || lower.contains("baker") || lower.contains("cake") || lower.contains("pastry")) {
      return curatedRestaurantBanners[12];
    }
    if (lower.contains("burger") || lower.contains("king") || lower.contains("mcdonald")) {
      return curatedRestaurantBanners[13];
    }
    if (lower.contains("salad") || lower.contains("healthy") || lower.contains("bowl") || lower.contains("green")) {
      return curatedRestaurantBanners[14];
    }

    // Deterministic distinct banner selection based on restId or name hash
    final index = (restId != null && restId > 0)
        ? (restId - 1) % curatedRestaurantBanners.length
        : rName.hashCode.abs() % curatedRestaurantBanners.length;
    return curatedRestaurantBanners[index];
  }

  // ===========================================================================
  // INTERACTIVE GALLERY PICKER BOTTOM SHEET
  // ===========================================================================
  static void showGalleryPickerModal({
    required BuildContext context,
    required bool isGrocery,
    required String currentImageUrl,
    required Function(String selectedUrl) onImageSelected,
  }) {
    final catalog = isGrocery ? groceryGalleryItems : foodGalleryItems;
    final categories = ["All", ...catalog.map((e) => e.category).toSet()];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        String selectedCategory = "All";
        String searchQuery = "";
        final customUrlController = TextEditingController(text: currentImageUrl);

        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final filteredItems = catalog.where((item) {
              final matchCat = selectedCategory == "All" || item.category == selectedCategory;
              final matchSearch = searchQuery.isEmpty ||
                  item.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
                  item.category.toLowerCase().contains(searchQuery.toLowerCase());
              return matchCat && matchSearch;
            }).toList();

            return DraggableScrollableSheet(
              initialChildSize: 0.85,
              maxChildSize: 0.95,
              minChildSize: 0.5,
              expand: false,
              builder: (ctx, scrollController) {
                return Column(
                  children: [
                    // Handle Bar
                    Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text("📸", style: TextStyle(fontSize: 20)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isGrocery ? "Select Grocery Photo" : "Select Dish Photo",
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                ),
                                Text(
                                  "Tap any photo to select, or paste a custom link",
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                    ),

                    // Custom URL Input Box
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: customUrlController,
                                style: const TextStyle(fontSize: 13),
                                decoration: const InputDecoration(
                                  hintText: "Or paste custom image link (https://...)",
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4F46E5),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () {
                                final text = customUrlController.text.trim();
                                if (text.isNotEmpty) {
                                  onImageSelected(text);
                                  Navigator.pop(ctx);
                                }
                              },
                              child: const Text("Use Link", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Search Input
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                      child: TextField(
                        onChanged: (val) => setModalState(() => searchQuery = val),
                        decoration: InputDecoration(
                          hintText: "Search in gallery...",
                          prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF64748B)),
                          filled: true,
                          fillColor: const Color(0xFFF1F5F9),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                    ),

                    // Category Filter Chips
                    SizedBox(
                      height: 42,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (ctx, i) {
                          final cat = categories[i];
                          final isSelected = cat == selectedCategory;
                          return ChoiceChip(
                            label: Text(cat, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
                            selected: isSelected,
                            selectedColor: const Color(0xFF4F46E5),
                            labelStyle: TextStyle(color: isSelected ? Colors.white : const Color(0xFF334155)),
                            backgroundColor: const Color(0xFFF1F5F9),
                            onSelected: (val) => setModalState(() => selectedCategory = cat),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Photos Grid
                    Expanded(
                      child: filteredItems.isEmpty
                          ? Center(
                              child: Text(
                                "No photos matching '$searchQuery'",
                                style: const TextStyle(color: Colors.grey),
                              ),
                            )
                          : GridView.builder(
                              controller: scrollController,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 0.85,
                              ),
                              itemCount: filteredItems.length,
                              itemBuilder: (ctx, i) {
                                final item = filteredItems[i];
                                final isChosen = currentImageUrl == item.imageUrl;

                                return InkWell(
                                  borderRadius: BorderRadius.circular(14),
                                  onTap: () {
                                    onImageSelected(item.imageUrl);
                                    Navigator.pop(ctx);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: isChosen ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0),
                                        width: isChosen ? 3 : 1,
                                      ),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Image.network(
                                          item.imageUrl,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (ctx, child, progress) {
                                            if (progress == null) return child;
                                            return Container(
                                              color: const Color(0xFFF1F5F9),
                                              child: const Center(
                                                child: SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child: CircularProgressIndicator(strokeWidth: 2),
                                                ),
                                              ),
                                            );
                                          },
                                          errorBuilder: (ctx, _, __) => Container(
                                            color: Colors.grey.shade200,
                                            child: const Icon(Icons.broken_image, size: 24, color: Colors.grey),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 0,
                                          left: 0,
                                          right: 0,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                              ),
                                            ),
                                            child: Text(
                                              item.title,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                        if (isChosen)
                                          Positioned(
                                            top: 6,
                                            right: 6,
                                            child: Container(
                                              padding: const EdgeInsets.all(3),
                                              decoration: const BoxDecoration(
                                                color: Color(0xFF4F46E5),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(Icons.check, size: 12, color: Colors.white),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

// =============================================================================
// FAST RESILIENT IMAGE CACHE & REUSABLE CACHED NETWORK IMAGE WIDGET
// =============================================================================

/// Global memory cache holding downloaded image bytes for instant re-use without re-downloading
class AppImageCache {
  static final Map<String, Uint8List> _cache = {};
  static final Map<String, Future<Uint8List?>> _inFlight = {};

  static bool contains(String url) => _cache.containsKey(url);
  static Uint8List? get(String url) => _cache[url];

  static Future<Uint8List?> getOrFetch(String url) async {
    final clean = url.trim();
    if (clean.isEmpty) return null;

    if (_cache.containsKey(clean)) {
      return _cache[clean];
    }
    if (_inFlight.containsKey(clean)) {
      return await _inFlight[clean];
    }

    final future = _downloadBytes(clean);
    _inFlight[clean] = future;
    try {
      final bytes = await future;
      if (bytes != null && bytes.isNotEmpty) {
        _cache[clean] = bytes;
      }
      return bytes;
    } finally {
      _inFlight.remove(clean);
    }
  }

  static Future<Uint8List?> _downloadBytes(String url) async {
    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200 && res.bodyBytes.isNotEmpty) {
        return res.bodyBytes;
      }
    } catch (_) {}
    return null;
  }
}

/// A resilient cached network image widget that uses Flutter's native image engine,
/// avoids browser CORS blocks on Web, and caches in memory across all screens.
class AppCachedNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const AppCachedNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final cleanUrl = imageUrl.trim();
    if (cleanUrl.isEmpty) {
      return _buildFallback();
    }

    Widget content = Image.network(
      cleanUrl,
      width: width,
      height: height,
      fit: fit,
      gaplessPlayback: true,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholder ??
            Container(
              width: width,
              height: height,
              color: const Color(0xFFF1F5F9),
              child: const Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF6366F1)),
                ),
              ),
            );
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ?? _buildFallback();
      },
    );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: content);
    }
    return content;
  }

  Widget _buildFallback() {
    Widget fallback = errorWidget ??
        Container(
          width: width,
          height: height,
          color: const Color(0xFFEEF2FF),
          child: const Center(
            child: Icon(Icons.restaurant, color: Color(0xFF4F46E5), size: 28),
          ),
        );
    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: fallback);
    }
    return fallback;
  }
}

// =============================================================================
// REUSABLE ITEM IMAGE WIDGET (With shimmer/loader & graceful fallback)
// =============================================================================
class ItemImageWidget extends StatelessWidget {
  final String? imageUrl;
  final String itemName;
  final String? category;
  final bool isGrocery;
  final double width;
  final double height;
  final double borderRadius;
  final BoxFit fit;

  const ItemImageWidget({
    super.key,
    required this.imageUrl,
    required this.itemName,
    this.category,
    this.isGrocery = false,
    this.width = 68,
    this.height = 68,
    this.borderRadius = 12,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = ItemImageHelper.resolveItemImage(
      imageUrl,
      itemName,
      category: category,
      isGrocery: isGrocery,
    );

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F2EA),
        borderRadius: BorderRadius.circular(2.0),
        border: Border.all(color: const Color(0xFF111111), width: 2.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(1.0),
        child: AppCachedNetworkImage(
          imageUrl: resolvedUrl,
          width: width,
          height: height,
          fit: fit,
          placeholder: Container(
            width: width,
            height: height,
            color: const Color(0xFFEFFF00),
            child: const Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF111111),
                ),
              ),
            ),
          ),
          errorWidget: Container(
            width: width,
            height: height,
            color: const Color(0xFFF5F2EA),
            child: Center(
              child: Text(
                isGrocery ? "🏬" : "🍽️",
                style: TextStyle(fontSize: width * 0.35),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
