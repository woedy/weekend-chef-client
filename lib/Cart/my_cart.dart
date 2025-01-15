import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:weekend_chef_client/Cart/cart_details.dart';
import 'package:weekend_chef_client/Cart/models/all_cart_items_model.dart';
import 'package:weekend_chef_client/constants.dart';
import 'package:weekend_chef_client/utils/custom_ui.dart';

Future<AllCartItemsModel> get_all_cart_items({
  int page = 1,
  Map<String, String>? filters,
  String? search_query,
}) async {
  var token = await getApiPref();
  var user_id = await getUserIDPref();


  // Construct the query parameters from the filters map
  String filterQuery = '';
  if (filters != null) {
    filters.forEach((key, value) {
      filterQuery += '&$key=$value';
    });
  }

  final String url = hostName +
      'api/orders/get-all-cart-items/?search=${search_query ?? ''}&user_id=${user_id.toString() ?? ''}&page=$page$filterQuery';

  final response = await http.get(
    Uri.parse(url),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      'Authorization': 'Token $token',
    },
  );

  if (response.statusCode == 200) {
    print(response.body);
    return AllCartItemsModel.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load data');
  }
}

class MyCartWidget extends StatefulWidget {
  const MyCartWidget({super.key});

  @override
  State<MyCartWidget> createState() => _allCartItemsScreenState();
}

class _allCartItemsScreenState extends State<MyCartWidget> {
  List<CartItem> _allCartItems = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCartItems(); // Fetch data on init
  }

  Future<void> _fetchCartItems() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final cartItemsData = await get_all_cart_items();

      setState(() {
        _allCartItems =
            cartItemsData.data.carts.expand((cart) => cart.cartItems).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading cart items: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Cart')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _allCartItems.length,
              itemBuilder: (context, index) {
                final cartItem = _allCartItems[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CartDetailsWidget(dish_id: 'DI-5659LBHC-SH'),
                      ),
                    );
                  },
                  child: Card(
                    margin: EdgeInsets.all(12),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        // Image contained within the Expanded widget
                        Expanded(
                          flex: 2,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  12), // To round the corners of the image
                              image: DecorationImage(
                                image: NetworkImage(
                                    hostNameMedia + cartItem.dishCoverPhoto),
                                fit: BoxFit.cover,
                              ),
                            ),
                            height: 120, // Set a fixed height for the image
                          ),
                        ),
                        // Expanded section for the dish details
                        Expanded(
                          flex: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cartItem.dishName,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundImage: NetworkImage(
                                        hostNameMedia + cartItem.chefPhoto,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        cartItem.chefName,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                if (cartItem.chefLocation != null)
                                  Text(
                                    cartItem.chefLocation!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                SizedBox(height: 8),
                                Text(
                                  'Quantity: ${cartItem.quantity} x ${cartItem.value}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Total Price: \$${cartItem.totalPrice}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class CartSearchDelegate extends SearchDelegate<String> {
  final Function(String) onSearch;

  CartSearchDelegate(this.onSearch);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = ''; // Clear the search query
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    onSearch(query); // Apply search
    return Center(child: Text('Searching for "$query"'));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container(); // You can add suggestions if necessary
  }
}
