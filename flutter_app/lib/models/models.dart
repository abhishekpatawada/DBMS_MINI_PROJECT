class UserModel {
  final int userId;
  final String userName;
  final String userPhone;
  final String? street;
  final String? area;
  final String? state;
  final String? pincode;

  UserModel({
    required this.userId,
    required this.userName,
    required this.userPhone,
    this.street,
    this.area,
    this.state,
    this.pincode,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['User_Id'] ?? json['userId'] ?? 0,
      userName: json['User_Name'] ?? json['userName'] ?? '',
      userPhone: json['User_Phone'] ?? json['userPhone'] ?? '',
      street: json['Street'] ?? json['street'],
      area: json['Area'] ?? json['area'],
      state: json['State'] ?? json['state'],
      pincode: json['Pincode'] ?? json['pincode'],
    );
  }
}

class DeliveryAgentModel {
  final int agentId;
  final String agentName;
  final String agentPhone;
  final String? vehicleNo;
  final String? vType;
  final bool hasLicense;
  final double rating;

  DeliveryAgentModel({
    required this.agentId,
    required this.agentName,
    required this.agentPhone,
    this.vehicleNo,
    this.vType,
    required this.hasLicense,
    required this.rating,
  });

  factory DeliveryAgentModel.fromJson(Map<String, dynamic> json) {
    return DeliveryAgentModel(
      agentId: json['Agent_Id'] ?? json['agentId'] ?? 0,
      agentName: json['Agent_Name'] ?? json['agentName'] ?? '',
      agentPhone: json['Agent_Phone'] ?? json['agentPhone'] ?? '',
      vehicleNo: json['VehicleNO'] ?? json['vehicleNo'],
      vType: json['V_Type'] ?? json['vType'],
      hasLicense: json['Has_license'] == 1 || json['Has_license'] == true || json['hasLicense'] == true,
      rating: double.tryParse(json['Rating']?.toString() ?? '5.0') ?? 5.0,
    );
  }
}

class RestaurantModel {
  final int restId;
  final String rName;
  final String rLocation;
  final String? rPhone;
  final double rRating;
  final String? imageUrl;

  RestaurantModel({
    required this.restId,
    required this.rName,
    required this.rLocation,
    this.rPhone,
    required this.rRating,
    this.imageUrl,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      restId: json['Rest_Id'] ?? json['restId'] ?? 0,
      rName: json['RName'] ?? json['rname'] ?? '',
      rLocation: json['RLocation'] ?? json['rlocation'] ?? '',
      rPhone: json['RPhone'] ?? json['rphone'],
      rRating: double.tryParse(json['RRating']?.toString() ?? '4.0') ?? 4.0,
      imageUrl: json['Image_Url'] ?? json['imageUrl'] ?? json['Banner_Url'],
    );
  }
}

class RestaurantItemModel {
  final int restId;
  final String itemName;
  final String? foodName;
  final bool isVeg;
  final double basePrice;
  final double discount;
  final double finalPrice;
  final String? imageUrl;
  final String? restaurantName;
  final String? restaurantLocation;
  final double? restaurantRating;

  RestaurantItemModel({
    required this.restId,
    required this.itemName,
    this.foodName,
    required this.isVeg,
    required this.basePrice,
    required this.discount,
    required this.finalPrice,
    this.imageUrl,
    this.restaurantName,
    this.restaurantLocation,
    this.restaurantRating,
  });

  factory RestaurantItemModel.fromJson(Map<String, dynamic> json) {
    final base = double.tryParse(json['BasePrice']?.toString() ?? '0.0') ?? 0.0;
    final disc = double.tryParse(json['Discount']?.toString() ?? '0.0') ?? 0.0;
    final fin = double.tryParse(json['FinalPrice']?.toString() ?? '') ?? (base - (base * disc / 100));

    return RestaurantItemModel(
      restId: json['Rest_Id'] ?? json['restId'] ?? 0,
      itemName: json['Item_Name'] ?? json['itemName'] ?? '',
      foodName: json['Food_Name'] ?? json['foodName'],
      isVeg: json['Is_Veg'] == 1 || json['Is_Veg'] == true,
      basePrice: base,
      discount: disc,
      finalPrice: fin,
      imageUrl: json['Image_Url'] ?? json['image_url'] ?? json['imageUrl'],
      restaurantName: json['Restaurant_Name'] ?? json['restaurantName'] ?? json['RName'],
      restaurantLocation: json['Restaurant_Location'] ?? json['restaurantLocation'] ?? json['RLocation'],
      restaurantRating: double.tryParse(json['Restaurant_Rating']?.toString() ?? json['RRating']?.toString() ?? ''),
    );
  }
}

class DarkStoreModel {
  final int storeId;
  final String? dsStreet;
  final String? dsArea;
  final String? dsState;
  final String? dsPincode;

  DarkStoreModel({
    required this.storeId,
    this.dsStreet,
    this.dsArea,
    this.dsState,
    this.dsPincode,
  });

  factory DarkStoreModel.fromJson(Map<String, dynamic> json) {
    return DarkStoreModel(
      storeId: json['Store_Id'] ?? json['storeId'] ?? 0,
      dsStreet: json['DS_Street'] ?? json['dsStreet'],
      dsArea: json['DS_Area'] ?? json['dsArea'],
      dsState: json['DS_State'] ?? json['dsState'],
      dsPincode: json['DS_Pincode'] ?? json['dsPincode'],
    );
  }
}

class GroceryItemModel {
  final int storeId;
  final String itemName;
  final double price;
  final int availableCount;
  final String? imageUrl;
  final String? storeArea;
  final String? storeStreet;
  final String? storeState;
  final String? storePincode;

  GroceryItemModel({
    required this.storeId,
    required this.itemName,
    required this.price,
    required this.availableCount,
    this.imageUrl,
    this.storeArea,
    this.storeStreet,
    this.storeState,
    this.storePincode,
  });

  factory GroceryItemModel.fromJson(Map<String, dynamic> json) {
    return GroceryItemModel(
      storeId: json['Store_Id'] ?? json['storeId'] ?? 0,
      itemName: json['Item_Name'] ?? json['itemName'] ?? '',
      price: double.tryParse(json['Price']?.toString() ?? '0.0') ?? 0.0,
      availableCount: json['Available_count'] ?? json['availableCount'] ?? 0,
      imageUrl: json['Image_Url'] ?? json['image_url'] ?? json['imageUrl'],
      storeArea: json['DS_Area'] ?? json['dsArea'] ?? json['storeArea'],
      storeStreet: json['DS_Street'] ?? json['dsStreet'] ?? json['storeStreet'],
      storeState: json['DS_State'] ?? json['dsState'] ?? json['storeState'],
      storePincode: json['DS_Pincode'] ?? json['dsPincode'] ?? json['storePincode'],
    );
  }
}

class OrderModel {
  final int orderId;
  final int userId;
  final String? userName;
  final String? userPhone;
  final int? agentId;
  final String? agentName;
  final String? agentPhone;
  final String? agentVehicle;
  final double? agentRating;
  final int? restId;
  final String? restName;
  final int? storeId;
  final String? storeArea;
  final String orderType;
  final String orderStatus;
  final double totalAmount;
  final String? orderDate;
  final String? paymentMethod;
  final String? paymentStatus;
  final String? deliveryAddr;

  OrderModel({
    required this.orderId,
    required this.userId,
    this.userName,
    this.userPhone,
    this.agentId,
    this.agentName,
    this.agentPhone,
    this.agentVehicle,
    this.agentRating,
    this.restId,
    this.restName,
    this.storeId,
    this.storeArea,
    required this.orderType,
    required this.orderStatus,
    required this.totalAmount,
    this.orderDate,
    this.paymentMethod,
    this.paymentStatus,
    this.deliveryAddr,
  });

  String get deliveryAddress => deliveryAddr ?? '';

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderId: json['Order_Id'] ?? json['orderId'] ?? 0,
      userId: json['User_Id'] ?? json['userId'] ?? 0,
      userName: json['User_Name'] ?? json['userName'],
      userPhone: json['User_Phone'] ?? json['userPhone'],
      agentId: json['Agent_Id'] ?? json['agentId'],
      agentName: json['Agent_Name'] ?? json['agentName'],
      agentPhone: json['Agent_Phone'] ?? json['agentPhone'],
      agentVehicle: json['Agent_Vehicle'] ?? json['VehicleNO'] ?? json['vehicleNo'],
      agentRating: double.tryParse(json['Agent_Rating']?.toString() ?? json['Rating']?.toString() ?? '5.0'),
      restId: json['Rest_Id'] ?? json['restId'],
      restName: json['Rest_Name'] ?? json['restName'] ?? json['RName'],
      storeId: json['Store_Id'] ?? json['storeId'],
      storeArea: json['Store_Area'] ?? json['storeArea'] ?? json['DS_Area'],
      orderType: json['Order_Type'] ?? json['orderType'] ?? 'Restaurant',
      orderStatus: json['Order_Status'] ?? json['orderStatus'] ?? 'Placed',
      totalAmount: double.tryParse(json['Total_Amount']?.toString() ?? '0.0') ?? 0.0,
      orderDate: json['Order_Date']?.toString() ?? json['PlacedAt']?.toString(),
      paymentMethod: json['Payment_Method'] ?? json['paymentMethod'],
      paymentStatus: json['Payment_Status'] ?? json['paymentStatus'],
      deliveryAddr: json['Delivery_Addr'] ?? json['deliveryAddr'] ?? json['Delivery_Address'],
    );
  }
}

class CartItemModel {
  final String itemName;
  final String? foodName;
  final double price;
  final bool isVeg;
  final String? imageUrl;
  int quantity;

  CartItemModel({
    required this.itemName,
    this.foodName,
    required this.price,
    this.isVeg = true,
    this.imageUrl,
    this.quantity = 1,
  });

  Map<String, dynamic> toJson() => {
        'name': itemName,
        'quantity': quantity,
        'price': price,
      };
}

