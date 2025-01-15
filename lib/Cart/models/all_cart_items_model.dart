import 'dart:convert';

class AllCartItemsModel {
  final String message;
  final CartData data;

  AllCartItemsModel({required this.message, required this.data});

  factory AllCartItemsModel.fromJson(Map<String, dynamic> json) {
    return AllCartItemsModel(
      message: json['message'],
      data: CartData.fromJson(json['data']),
    );
  }
}

class CartData {
  final List<Cart> carts;
  final Pagination pagination;

  CartData({required this.carts, required this.pagination});

  factory CartData.fromJson(Map<String, dynamic> json) {
    var list = json['carts'] as List;
    List<Cart> cartList = list.map((i) => Cart.fromJson(i)).toList();

    return CartData(
      carts: cartList,
      pagination: Pagination.fromJson(json['pagination']),
    );
  }
}

class Cart {
  final int cartId;
  final String createdAt;
  final List<CartItem> cartItems;

  Cart({
    required this.cartId,
    required this.createdAt,
    required this.cartItems,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    var list = json['cart_items'] as List;
    List<CartItem> cartItemsList = list.map((i) => CartItem.fromJson(i)).toList();

    return Cart(
      cartId: json['cart_id'],
      createdAt: json['created_at'],
      cartItems: cartItemsList,
    );
  }
}

class CartItem {
  final int id;
  final String dishName;
  final String dishCoverPhoto;
  final int quantity;
  final String value;
  final String chefName;
  final String? chefLocation; // Can be null
  final String chefPhoto;
  final double totalPrice;

  CartItem({
    required this.id,
    required this.dishName,
    required this.dishCoverPhoto,
    required this.quantity,
    required this.value,
    required this.chefName,
    this.chefLocation,
    required this.chefPhoto,
    required this.totalPrice,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      dishName: json['dish_name'],
      dishCoverPhoto: json['dish_cover_photo'],
      quantity: json['quantity'],
      value: json['value'],
      chefName: json['chef_name'],
      chefLocation: json['chef_location'],
      chefPhoto: json['chef_photo'],
      totalPrice: json['total_price'],
    );
  }
}

class Pagination {
  final int pageNumber;
  final int totalPages;
  final String? next;
  final String? previous;

  Pagination({
    required this.pageNumber,
    required this.totalPages,
    this.next,
    this.previous,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      pageNumber: json['page_number'],
      totalPages: json['total_pages'],
      next: json['next'],
      previous: json['previous'],
    );
  }
}
