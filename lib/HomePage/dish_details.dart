import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:weekend_chef_client/Cart/my_cart.dart';
import 'package:weekend_chef_client/Components/generic_loading_dialogbox.dart';
import 'package:weekend_chef_client/HomePage/HomePage.dart';
import 'package:weekend_chef_client/HomePage/dish_map_view.dart';
import 'package:weekend_chef_client/HomePage/models/dish_detail_model.dart';
import 'package:weekend_chef_client/chef/chef_details.dart';
import 'package:weekend_chef_client/constants.dart';
import 'package:http/http.dart' as http;

Future<DishDetailModel> get_dish_detail_data(String dish_id) async {
  var token = await getApiPref();
  var userId = await getUserIDPref();

  final response = await http.get(
    Uri.parse(
        "${hostName}api/clients/get-client-dish-details/?dish_id=$dish_id&user_id=$userId"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      //'Authorization': 'Token ' + token.toString()
      'Authorization': 'Token ea2056b5ab6e2f98f69d7192b9a21577c3dc55e8'
    },
  );
  print(response.statusCode);
  if (response.statusCode == 200 || response.statusCode == 201) {
    print(jsonDecode(response.body));
    final result = json.decode(response.body);

    return DishDetailModel.fromJson(jsonDecode(response.body));
  } else if (response.statusCode == 422) {
    print(jsonDecode(response.body));
    return DishDetailModel.fromJson(jsonDecode(response.body));
  } else if (response.statusCode == 403) {
    print(jsonDecode(response.body));
    return DishDetailModel.fromJson(jsonDecode(response.body));
  } else if (response.statusCode == 400) {
    print(jsonDecode(response.body));
    return DishDetailModel.fromJson(jsonDecode(response.body));
  } else if (response.statusCode == 401) {
    print(jsonDecode(response.body));
    return DishDetailModel.fromJson(jsonDecode(response.body));
  } else {
    //throw Exception('Failed to load data');
    print(jsonDecode(response.body));
    return DishDetailModel.fromJson(jsonDecode(response.body));
  }
}

class DishDetailsWidget extends StatefulWidget {
  final dish_id;
  const DishDetailsWidget({super.key, required this.dish_id});

  @override
  State<DishDetailsWidget> createState() => _DishDetailsWidgetState();
}

class _DishDetailsWidgetState extends State<DishDetailsWidget>
    with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  int _selectedChefIndex = -1; // Variable to store the selected index

  Future<DishDetailModel>? _futureDishDetail;
  // Chef Radius
  double _radius = 5.0;
  TabController? _tabController;

  //Cart data
  List<Custom> customData = [];
  int _quantity = 1; // Initialize the quantity
  String _selectedChef = ''; // Initialize the selected chef

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(length: 2, vsync: this);
    _futureDishDetail = get_dish_detail_data(widget.dish_id);
  }

  // Method to increment the radius value
  void _incrementRadius() {
    setState(() {
      _radius += 5.0; // Increase by 5 (or modify this value as needed)
    });
  }

  // Method to decrement the radius value
  void _decrementRadius() {
    setState(() {
      if (_radius > 0) {
        _radius -= 5.0; // Decrease by 5 (or modify this value as needed)
      }
    });
  }

  // Show a success dialog
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('Item added to the cart successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Show an error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Make a POST request
  Future<void> _makePostRequest(data) async {
    var requestBody = {
      "dish_id": data['dish_id'],
      "chef_id": data['chef_id'],
      "user_id": data['user_id'],
      "quantity": data['quantity'],
      "is_custom": data['is_custom'],
      "customizations": data['customizations'],
    };

    // Show loading dialog before making the request
    LoadingDialogBox(
      text: 'Please wait...',
    );

    try {
      // Make the POST request

      final response = await http.post(
        Uri.parse("${hostName}api/orders/add-cart-item/"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          //'Authorization': 'Token ' + token.toString()
          'Authorization': 'Token ea2056b5ab6e2f98f69d7192b9a21577c3dc55e8'
        },
        body: jsonEncode(requestBody),
      );

      // Hide the loading dialog once the request is completed
      Navigator.of(context).pop(); // Close the loading dialog

      // Check the response
      if (response.statusCode == 200) {
        // Success
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const HomePageWidget()));
        _showSuccessDialog();
      } else {
        // Server error or invalid data
        print(response.body);
        _showErrorDialog(
            'Failed to add item to the cart. Please try again later.');
      }
    } catch (e) {
      // Network error
      Navigator.of(context).pop(); // Close the loading dialog
      _showErrorDialog(
          'An error occurred. Please check your internet connection and try again.');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return (_futureDishDetail == null) ? buildColumn() : buildFutureBuilder();
  }

  buildColumn() {
    return Scaffold(
      body: Container(),
    );
  }

  FutureBuilder<DishDetailModel> buildFutureBuilder() {
    return FutureBuilder<DishDetailModel>(
        future: _futureDishDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingDialogBox(
              text: 'Please Wait..',
            );
          } else if (snapshot.hasData) {
            var data = snapshot.data!;

            var dishData = data.data!.dish;
            var chefs = data.data!.closestChef;
            var ingredients = data.data!.dish!.ingredients;
            var relatedFood = data.data!.relatedFoods;
            customData = data.data!.custom!;

            if (data.message == "Successful") {
              return GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                child: Scaffold(
                  key: scaffoldKey,
                  backgroundColor: Colors.white,
                  body: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          hostNameMedia + dishData!.coverPhoto.toString(),
                          width: double.infinity,
                          height: 241,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10.0),
                        margin: const EdgeInsets.only(top: 40),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                      color: bookPrimary,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: const Icon(
                                    Icons.arrow_back,
                                    size: 25,
                                    color: Colors.white,
                                  ),
                                )),
                            Text(
                              "Dish Details",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white),
                            ),
                            Icon(
                              Icons.search,
                              size: 20,
                              color: bookPrimary,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 200, 0, 0),
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(0),
                              bottomRight: Radius.circular(0),
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    20, 20, 20, 0),
                                child: Container(
                                  decoration: BoxDecoration(),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            dishData!.name.toString(),
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              fontSize: 24,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'Ghc ',
                                                style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  color: Color(0xFF209220),
                                                  fontSize: 10,
                                                  letterSpacing: 0.0,
                                                ),
                                              ),
                                              Text(
                                                dishData!.basePrice.toString(),
                                                style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  color: Color(0xFF209220),
                                                  fontSize: 17,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Divider(
                                        thickness: 2,
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            dishData!.value.toString(),
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              letterSpacing: 0.0,
                                            ),
                                          ),
                                          if (dishData!.customizable ==
                                              true) ...[
                                            InkWell(
                                              onTap: () {
                                                _showCustomBottomModal(context);
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 3),
                                                decoration: BoxDecoration(
                                                    color: bookPrimary,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: Text(
                                                  'Customizable',
                                                  style: TextStyle(
                                                    fontFamily: 'Inter',
                                                    color: Color.fromARGB(
                                                        255, 255, 255, 255),
                                                    fontSize: 10,
                                                    letterSpacing: 0.0,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                  ),
                                  child: Column(
                                    children: [
                                      Align(
                                        alignment: Alignment(0, 0),
                                        child: TabBar(
                                          labelColor: Colors.black,
                                          unselectedLabelColor: Colors.grey,
                                          labelStyle: TextStyle(
                                            fontFamily: 'Inter Tight',
                                            fontSize: 13,
                                            letterSpacing: 0.0,
                                          ),
                                          unselectedLabelStyle: TextStyle(
                                            fontFamily: 'Inter Tight',
                                            fontSize: 13,
                                            letterSpacing: 0.0,
                                          ),
                                          indicatorColor: Color(0xFFF94638),
                                          indicatorWeight: 3,
                                          tabs: [
                                            Tab(
                                              text: 'Available Chefs',
                                            ),
                                            Tab(
                                              text: 'Ingredients',
                                            ),
                                          ],
                                          controller: _tabController,
                                          onTap: (i) async {
                                            [
                                              () async {},
                                              () async {},
                                            ][i]();
                                          },
                                        ),
                                      ),
                                      Expanded(
                                        child: TabBarView(
                                          controller: _tabController,
                                          children: [
                                            Column(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Expanded(
                                                  flex: 3,
                                                  child: Container(
                                                      width: double.infinity,
                                                      height: 100,
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                      ),
                                                      child: ListView.builder(
                                                        padding:
                                                            EdgeInsets.zero,
                                                        shrinkWrap: true,
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        itemCount:
                                                            chefs!.length,
                                                        itemBuilder:
                                                            (context, index) {
                                                          return Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        5,
                                                                        5,
                                                                        5,
                                                                        5),
                                                            child:
                                                                GestureDetector(
                                                              onTap: () {
                                                                setState(() {
                                                                  // Toggle selection state
                                                                  if (_selectedChefIndex ==
                                                                      index) {
                                                                    _selectedChefIndex =
                                                                        -1; // Deselect if already selected
                                                                    setState(
                                                                        () {
                                                                      _selectedChef =
                                                                          '';
                                                                    });
                                                                  } else {
                                                                    _selectedChefIndex =
                                                                        index; // Select the tapped item

                                                                    setState(
                                                                        () {
                                                                      _selectedChef = chefs[
                                                                              index]
                                                                          .chefId!
                                                                          .toString();
                                                                    });
                                                                  }
                                                                });
                                                              },
                                                              child: Container(
                                                                width: 130,
                                                                height: 100,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                                child: Stack(
                                                                  children: [
                                                                    Align(
                                                                      alignment:
                                                                          AlignmentDirectional(
                                                                              0,
                                                                              1),
                                                                      child:
                                                                          Container(
                                                                        width: double
                                                                            .infinity,
                                                                        height:
                                                                            115,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color: _selectedChefIndex == index
                                                                              ? Color(0xFFF94638)
                                                                              : Colors.transparent, // Default color
                                                                          borderRadius:
                                                                              BorderRadius.circular(14),
                                                                        ),
                                                                        child:
                                                                            Padding(
                                                                          padding: EdgeInsetsDirectional.fromSTEB(
                                                                              0,
                                                                              0,
                                                                              0,
                                                                              10),
                                                                          child:
                                                                              Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.max,
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.end,
                                                                            children: [
                                                                              Padding(
                                                                                padding: EdgeInsetsDirectional.fromSTEB(5, 0, 5, 5),
                                                                                child: Text(
                                                                                  chefs[index].user!.firstName!.toString() + ' ' + chefs[index].user!.lastName!.toString(),
                                                                                  textAlign: TextAlign.center,
                                                                                  style: TextStyle(
                                                                                    fontFamily: 'Inter',
                                                                                    color: _selectedChefIndex == index ? Colors.white : Colors.black,
                                                                                    fontSize: 13,
                                                                                    letterSpacing: 0.0,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Padding(
                                                                                padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 5),
                                                                                child: Text(
                                                                                  chefs[index].kitchenLocation.toString(),
                                                                                  style: TextStyle(
                                                                                    fontFamily: 'Inter',
                                                                                    color: _selectedChefIndex == index ? Colors.white : Colors.black,
                                                                                    fontSize: 9,
                                                                                    letterSpacing: 0.0,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Padding(
                                                                                padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 5),
                                                                                child: Text(
                                                                                  '5 km',
                                                                                  style: TextStyle(
                                                                                    fontFamily: 'Inter',
                                                                                    color: _selectedChefIndex == index ? Colors.white : Colors.black,
                                                                                    fontSize: 9,
                                                                                    letterSpacing: 0.0,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Align(
                                                                      alignment:
                                                                          AlignmentDirectional(
                                                                              0,
                                                                              -0.8),
                                                                      child:
                                                                          InkWell(
                                                                        onTap:
                                                                            () {
                                                                          Navigator.push(
                                                                              context,
                                                                              MaterialPageRoute(builder: (context) => ChefDetailsWidget()));
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          width:
                                                                              95,
                                                                          height:
                                                                              95,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                Colors.white,
                                                                            image:
                                                                                DecorationImage(
                                                                              fit: BoxFit.cover,
                                                                              image: NetworkImage(hostNameMedia + chefs[index].user!.photo!.toString()),
                                                                            ),
                                                                            shape:
                                                                                BoxShape.circle,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      )),
                                                ),
                                                Expanded(
                                                  flex: 6,
                                                  child: Container(
                                                    width: double.infinity,
                                                    height: 100,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                    ),
                                                    child: Stack(
                                                      children: [
                                                        Container(
                                                          width:
                                                              double.infinity,
                                                          height:
                                                              double.infinity,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.white,
                                                            image:
                                                                DecorationImage(
                                                              fit: BoxFit.cover,
                                                              image:
                                                                  Image.network(
                                                                'https://images.unsplash.com/photo-1524661135-423995f22d0b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHNlYXJjaHwyfHxtYXB8ZW58MHx8fHwxNzM0MTkzNzExfDA&ixlib=rb-4.0.3&q=80&w=1080',
                                                              ).image,
                                                            ),
                                                          ),
                                                        ),
                                                        Align(
                                                          alignment:
                                                              AlignmentDirectional(
                                                                  1, -1),
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        0,
                                                                        5,
                                                                        5,
                                                                        0),
                                                            child: Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Color(
                                                                    0x68FFFFFF),
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    blurRadius:
                                                                        4,
                                                                    color: Color(
                                                                        0x33000000),
                                                                    offset:
                                                                        Offset(
                                                                      0,
                                                                      2,
                                                                    ),
                                                                  )
                                                                ],
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .only(
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          5),
                                                                  bottomRight: Radius
                                                                      .circular(
                                                                          5),
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          5),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          5),
                                                                ),
                                                              ),
                                                              child: Padding(
                                                                padding:
                                                                    EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            5,
                                                                            5,
                                                                            5,
                                                                            5),
                                                                child: Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: [
                                                                    // Decrement Button
                                                                    GestureDetector(
                                                                      onTap:
                                                                          _decrementRadius,
                                                                      child:
                                                                          Container(
                                                                        width:
                                                                            25,
                                                                        height:
                                                                            25,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              Color(0xFFF94638),
                                                                          borderRadius:
                                                                              BorderRadius.circular(5),
                                                                        ),
                                                                        child:
                                                                            Align(
                                                                          alignment:
                                                                              Alignment.center,
                                                                          child:
                                                                              Text(
                                                                            '-',
                                                                            style:
                                                                                TextStyle(
                                                                              fontFamily: 'Inter',
                                                                              color: Colors.white,
                                                                              letterSpacing: 0.0,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                      padding: EdgeInsetsDirectional
                                                                          .fromSTEB(
                                                                              5,
                                                                              0,
                                                                              5,
                                                                              0),
                                                                      child:
                                                                          Text(
                                                                        'Radius: ${_radius.toStringAsFixed(1)} km', // Displaying the radius
                                                                        style:
                                                                            TextStyle(
                                                                          fontFamily:
                                                                              'Inter',
                                                                          fontSize:
                                                                              10,
                                                                          letterSpacing:
                                                                              0.0,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    // Increment Button
                                                                    GestureDetector(
                                                                      onTap:
                                                                          _incrementRadius,
                                                                      child:
                                                                          Container(
                                                                        width:
                                                                            25,
                                                                        height:
                                                                            25,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              Color(0xFFF94638),
                                                                          borderRadius:
                                                                              BorderRadius.circular(5),
                                                                        ),
                                                                        child:
                                                                            Align(
                                                                          alignment:
                                                                              Alignment.center,
                                                                          child:
                                                                              Text(
                                                                            '+',
                                                                            style:
                                                                                TextStyle(
                                                                              fontFamily: 'Inter',
                                                                              color: Colors.white,
                                                                              letterSpacing: 0.0,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Align(
                                                          alignment:
                                                              AlignmentDirectional(
                                                                  0, 1),
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        20,
                                                                        0,
                                                                        20,
                                                                        20),
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .end,
                                                              children: [
                                                                Visibility(
                                                                  visible: relatedFood !=
                                                                          null &&
                                                                      relatedFood
                                                                          .isNotEmpty, // Only show when relatedFood is not empty
                                                                  child:
                                                                      InkWell(
                                                                    onTap: () {
                                                                      _showRelatedBottomModal(
                                                                          context,
                                                                          relatedFood);
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      padding: EdgeInsets.symmetric(
                                                                          horizontal:
                                                                              25,
                                                                          vertical:
                                                                              5),
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: Colors
                                                                            .green,
                                                                        borderRadius:
                                                                            BorderRadius.circular(10),
                                                                      ),
                                                                      child:
                                                                          Row(
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        children: [
                                                                          Text(
                                                                            'Best With',
                                                                            style:
                                                                                TextStyle(
                                                                              fontFamily: 'Inter',
                                                                              color: Color.fromARGB(255, 255, 255, 255),
                                                                              fontSize: 12,
                                                                              letterSpacing: 0.0,
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                              width: 10),
                                                                          CircleAvatar(
                                                                            backgroundImage: (relatedFood != null && relatedFood.isNotEmpty && relatedFood.first.coverPhoto != null)
                                                                                ? NetworkImage(hostNameMedia + relatedFood.first.coverPhoto!.toString())
                                                                                : NetworkImage('default_image_url'), // Fallback image if null or empty
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 20,
                                                                ),
                                                                Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    InkWell(
                                                                      onTap:
                                                                          () async {
                                                                        // Print to debug
                                                                        print(
                                                                            '####### CART ######');

                                                                        // Get the user ID
                                                                        var userId =
                                                                            await getUserIDPref();

                                                                        // Check if any customizations have quantities greater than 0
                                                                        var is_custom = customData.any((item) =>
                                                                            item.quantity >
                                                                            0);

                                                                        // Check if chef is null and display an error message if necessary
                                                                        if (_selectedChef ==
                                                                            '') {
                                                                          // Show an error Snackbar if chef is null
                                                                          ScaffoldMessenger.of(context)
                                                                              .showSnackBar(
                                                                            SnackBar(
                                                                              content: Text('Please select a chef before adding to the cart.'),
                                                                              backgroundColor: Colors.red,
                                                                            ),
                                                                          );
                                                                          return; // Exit early to prevent further actions
                                                                        }

                                                                        // Construct the data to send
                                                                        var data =
                                                                            {
                                                                          "dish_id": dishData!
                                                                              .dishId
                                                                              .toString(),
                                                                          "chef_id":
                                                                              _selectedChef, // Use chefId or clientId
                                                                          "user_id":
                                                                              userId,
                                                                          "quantity":
                                                                              _quantity,
                                                                          "is_custom":
                                                                              is_custom,
                                                                          "customizations": customData
                                                                              .map((e) => {
                                                                                    "custom_option_id": e.customOptionId,
                                                                                    "quantity": e.quantity
                                                                                  })
                                                                              .toList()
                                                                        };

                                                                        // Print the data for debugging
                                                                        print(
                                                                            data);

                                                                        _makePostRequest(
                                                                            data);
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        width:
                                                                            150,
                                                                        height:
                                                                            40,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              Colors.white,
                                                                          borderRadius:
                                                                              BorderRadius.only(
                                                                            bottomLeft:
                                                                                Radius.circular(10),
                                                                            bottomRight:
                                                                                Radius.circular(0),
                                                                            topLeft:
                                                                                Radius.circular(0),
                                                                            topRight:
                                                                                Radius.circular(10),
                                                                          ),
                                                                          border:
                                                                              Border.all(
                                                                            color:
                                                                                Color(0xFFF94638),
                                                                            width:
                                                                                1,
                                                                          ),
                                                                        ),
                                                                        child:
                                                                            Align(
                                                                          alignment: AlignmentDirectional(
                                                                              0,
                                                                              0),
                                                                          child:
                                                                              Text(
                                                                            'Add to cart',
                                                                            style:
                                                                                TextStyle(
                                                                              fontFamily: 'Inter',
                                                                              color: Color(0xFFF94638),
                                                                              fontSize: 11,
                                                                              letterSpacing: 0.0,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      width:
                                                                          150,
                                                                      height:
                                                                          40,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: Color(
                                                                            0xFFF94638),
                                                                        borderRadius:
                                                                            BorderRadius.only(
                                                                          bottomLeft:
                                                                              Radius.circular(10),
                                                                          bottomRight:
                                                                              Radius.circular(0),
                                                                          topLeft:
                                                                              Radius.circular(0),
                                                                          topRight:
                                                                              Radius.circular(10),
                                                                        ),
                                                                        border:
                                                                            Border.all(
                                                                          color:
                                                                              Color(0xFFF94638),
                                                                          width:
                                                                              0,
                                                                        ),
                                                                      ),
                                                                      child:
                                                                          Align(
                                                                        alignment: AlignmentDirectional(
                                                                            0,
                                                                            0),
                                                                        child:
                                                                            Text(
                                                                          'Place Order',
                                                                          style:
                                                                              TextStyle(
                                                                            fontFamily:
                                                                                'Inter',
                                                                            color:
                                                                                Colors.white,
                                                                            fontSize:
                                                                                11,
                                                                            letterSpacing:
                                                                                0.0,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Text(dishData!
                                                            .description!
                                                            .toString()),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    width: double.infinity,
                                                    height: 120,
                                                    decoration: BoxDecoration(),
                                                    child: ListView.builder(
                                                      padding: EdgeInsets.zero,
                                                      shrinkWrap: true,
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      itemCount:
                                                          ingredients!.length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return Container(
                                                          width: 100,
                                                          decoration:
                                                              BoxDecoration(),
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        5,
                                                                        10,
                                                                        5,
                                                                        0),
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              children: [
                                                                Padding(
                                                                  padding: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0,
                                                                          0,
                                                                          0,
                                                                          10),
                                                                  child:
                                                                      Container(
                                                                    width: 64,
                                                                    height: 64,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Colors
                                                                          .white,
                                                                      image:
                                                                          DecorationImage(
                                                                        fit: BoxFit
                                                                            .cover,
                                                                        image: Image.network(hostNameMedia +
                                                                                ingredients[index].photo!.toString())
                                                                            .image,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .only(
                                                                        bottomLeft:
                                                                            Radius.circular(10),
                                                                        bottomRight:
                                                                            Radius.circular(10),
                                                                        topLeft:
                                                                            Radius.circular(10),
                                                                        topRight:
                                                                            Radius.circular(10),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Text(
                                                                  ingredients[
                                                                          index]
                                                                      .name!
                                                                      .toString(),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'Inter',
                                                                    letterSpacing:
                                                                        0.0,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 3,
                                                  child: Container(
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(10, 25,
                                                                  10, 0),
                                                      child: Text(
                                                        'Sed ut perspiciatis unde omnis iste natus error sit \nvoluptatem accusantium doloremque laudantium, \ntotam rem aperiam, eaque ipsa quae ab illo inventore \nveritatis et quasi architecto beatae vitae dicta sunt \n\nexplicabo. Nemo enim ipsam voluptatem quia voluptas \nsit aspernatur aut odit aut fugit, sed quia consequuntur \nmagni dolores eos qui ratione voluptatem sequi \nnesciunt. Neque porro quisquam est, qui dolorem \nipsum quia dolor sit amet, consectetur, ',
                                                        style: TextStyle(
                                                          fontFamily: 'Inter',
                                                          letterSpacing: 0.0,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
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
            } else {
              return const LoadingDialogBox(
                text: 'Please Wait.!!!.',
              );
            }
          }

          return const LoadingDialogBox(
            text: 'Please Wait.!!!.',
          );
        });
  }

  void _showCustomBottomModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.3,
          minChildSize: 0.2,
          maxChildSize: 0.8,
          builder: (BuildContext context, scrollController) {
            return StatefulBuilder(
              builder: (context, setState) {
                return Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      // Title Row
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Customize food',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Quantity Row (The first one you mentioned)
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Quantity',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 17),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        5, 5, 5, 5),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Decrement button
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              if (_quantity > 1) {
                                                _quantity--; // Decrement the quantity
                                              }
                                            });
                                          },
                                          child: Container(
                                            width: 25,
                                            height: 25,
                                            decoration: BoxDecoration(
                                              color: Color(0xFFF94638),
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: Align(
                                              alignment:
                                                  AlignmentDirectional(0, 0),
                                              child: Text(
                                                '-',
                                                style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  10, 0, 10, 0),
                                          child: Text(
                                            '$_quantity', // Display the current quantity
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        // Increment button
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _quantity++; // Increment the quantity
                                            });
                                          },
                                          child: Container(
                                            width: 25,
                                            height: 25,
                                            decoration: BoxDecoration(
                                              color: Color(0xFFF94638),
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: Align(
                                              alignment:
                                                  AlignmentDirectional(0, 0),
                                              child: Text(
                                                '+',
                                                style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Text(
                              'Extra Adons',
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            )
                          ],
                        ),
                      ),

                      // List of items (customData)
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount:
                              customData.length, // Ensure customData is updated
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Container(
                                          height: 70,
                                          width: 70,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            image: DecorationImage(
                                                fit: BoxFit.cover,
                                                image: NetworkImage(
                                                    hostNameMedia +
                                                        customData[index]
                                                            .photo!)),
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              customData[index].name!,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 18),
                                            ),
                                            Row(
                                              children: [
                                                Text('Ghc ',
                                                    style: TextStyle(
                                                        fontSize: 14)),
                                                Text(customData[index].price!,
                                                    style: TextStyle(
                                                        fontSize: 14)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        5, 5, 5, 5),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Decrement button for custom data
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              if (customData[index].quantity >
                                                  0) {
                                                customData[index]
                                                    .quantity--; // Decrease quantity
                                              }
                                            });
                                          },
                                          child: Container(
                                            width: 25,
                                            height: 25,
                                            decoration: BoxDecoration(
                                              color: Color(0xFFF94638),
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: Align(
                                              alignment:
                                                  AlignmentDirectional(0, 0),
                                              child: Text(
                                                '-',
                                                style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  10, 0, 10, 0),
                                          child: Text(
                                            '${customData[index].quantity}',
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        // Increment button for custom data
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              customData[index]
                                                  .quantity++; // Increase quantity
                                            });
                                          },
                                          child: Container(
                                            width: 25,
                                            height: 25,
                                            decoration: BoxDecoration(
                                              color: Color(0xFFF94638),
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: Align(
                                              alignment:
                                                  AlignmentDirectional(0, 0),
                                              child: Text(
                                                '+',
                                                style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showRelatedBottomModal(BuildContext context, relatedFoodData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      //backgroundColor: Colors.black.withOpacity(0.5),
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.3, // Initial size of the modal
          minChildSize: 0.2, // Minimum height of the modal
          maxChildSize: 0.8, // Maximum height of the modal
          builder: (BuildContext context, scrollController) {
            return Container(
              color: Colors.white,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Best With',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w600),
                          ),
                        ),
                      )
                    ],
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: relatedFoodData.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DishDetailsWidget(
                                        dish_id: relatedFoodData[index]
                                            .dishId
                                            .toString())));
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Container(
                                        height: 70,
                                        width: 70,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            image: DecorationImage(
                                                fit: BoxFit.cover,
                                                image: NetworkImage(
                                                    hostNameMedia +
                                                        relatedFoodData[index]
                                                            .coverPhoto
                                                            .toString()))),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              relatedFoodData[index]
                                                  .name
                                                  .toString(),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 18),
                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    relatedFoodData[index]
                                                        .description
                                                        .toString(),
                                                    overflow: TextOverflow
                                                        .ellipsis, // This adds '...' at the end if text overflows
                                                    maxLines: 2,
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.grey),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
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
              ),
            );
          },
        );
      },
    );
  }
}
