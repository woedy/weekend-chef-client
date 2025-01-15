import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:weekend_chef_client/Cart/models/all_cart_items_model.dart';
import 'package:weekend_chef_client/constants.dart';
import 'package:weekend_chef_client/utils/custom_ui.dart';

Future<AllCartItemsModel> get_all_cart_items({
  int page = 1,
  Map<String, String>? filters,
  String? search_query,
  String? user_id,
}) async {
  var token = await getApiPref();

  // Construct the query parameters from the filters map
  String filterQuery = '';
  if (filters != null) {
    filters.forEach((key, value) {
      filterQuery += '&$key=$value';
    });
  }

  final String url = hostName +
      'api/orders/get-all-cart-items/?search=${search_query ?? ''}&user_id=${user_id ?? ''}&page=$page$filterQuery';

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

class ListGenericsWidget extends StatefulWidget {
  const ListGenericsWidget({super.key});

  @override
  State<ListGenericsWidget> createState() => _allCartItemsScreenState();
}

class _allCartItemsScreenState extends State<ListGenericsWidget> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  Future<void>? _futureAllCartItems;
  List<CartItem> _allCartItems = [];
  bool _isLoading = false;
  int _currentPage = 1;
  int _totalPages = 1;
  Map<String, String>? _filters;
  String? _searchQuery;

  // Method to fetch cart items from the API
  Future<void> _fetchCartItems(
      {bool loadMore = false, String searchQuery = ''}) async {
    if (_isLoading) return; // Prevents multiple simultaneous API calls

    setState(() {
      _isLoading = true; // Set loading to true before making the API call
    });

    try {
      // Fetch the data from the API
      final cartItemsData = await get_all_cart_items(
        page: loadMore
            ? _currentPage + 1
            : 1, // Increment page number if loading more
        search_query: searchQuery, // Pass search query
        filters: _filters, // Pass any filters (optional)
      );

      setState(() {
        // Handle the data based on whether it's loading more or initial load
        if (loadMore) {
          _allCartItems.addAll(
            cartItemsData.data.carts.expand((cart) => cart.cartItems).toList(),
          );
          _currentPage++; // Increase current page after loading more
        } else {
          _allCartItems = cartItemsData.data.carts
              .expand((cart) => cart.cartItems)
              .toList();
          _currentPage = 1; // Reset to the first page on the initial load
        }

        // Update the total pages based on the API response
        _totalPages = cartItemsData.data.pagination.totalPages;
        _isLoading = false; // Set loading to false after data is fetched
      });
    } catch (e) {
      setState(() {
        _isLoading = false; // Set loading to false in case of an error
      });

      // Handle error gracefully
      print('Error loading cart items: $e');
      // You can show a snackbar or dialog to notify the user of the error
    }
  }

  // Call _fetchCartItems when the widget is initialized
  @override
  void initState() {
    super.initState();
    _fetchCartItems(); // Trigger initial load
  }

  // Function to apply search query
  void _applySearch(String query) {
    setState(() {
      _searchQuery = query; // Update search query
      _fetchCartItems(
          searchQuery: query); // Fetch cart items with the search query
    });
  }

  // Function to apply filters
  void _applyFilters() {
    setState(() {
      _futureAllCartItems = _fetchCartItems(); // Apply filters and refetch data
    });
  }

  // Function to reset filters and search
  void _resetFilters() {
    setState(() {
      _filters = null; // Reset filters
      _searchQuery = null;
      _currentPage = 1;
      _fetchCartItems(); // Fetch all data without filters or search
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('My Cart'),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                showSearch(
                    context: context,
                    delegate: CartSearchDelegate(_applySearch));
              },
            ),
          ],
        ),
        body: Column(
          children: [
            _isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator()) // Show loading indicator while fetching data
                : Expanded(
                    child: ListView.builder(
                      itemCount: _allCartItems.length +
                          1, // Add 1 for the "Load More" button
                      itemBuilder: (context, index) {
                        if (index == _allCartItems.length) {
                          // "Load More" button at the end of the list
                          return ElevatedButton(
                            onPressed: _currentPage < _totalPages && !_isLoading
                                ? () => _fetchCartItems(loadMore: true)
                                : null,
                            child: Text(
                                _isLoading ? 'Loading more...' : 'Load More'),
                          );
                        }
                        // Display cart item
                        final cartItem = _allCartItems[index];
                        return ListTile(
                          title: Text(cartItem.dish ?? 'No dish'),
                          subtitle: Text(
                              'Quantity: ${cartItem.quantity}, Price: ${cartItem.totalPrice}'),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
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
