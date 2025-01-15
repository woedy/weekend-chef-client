import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;
import 'package:weekend_chef_client/NewUIs/models/categories_model.dart';
import 'package:weekend_chef_client/constants.dart';
import 'package:weekend_chef_client/utils/custom_ui.dart';

Future<CategoriesModel> get_all_categories(
    {int page = 1, Map<String, String>? filters, String? search_query}) async {
  var token = await getApiPref();

  // Construct the query parameters from the filters map
  String filterQuery = '';
  if (filters != null) {
    filters.forEach((key, value) {
      filterQuery += '&$key=$value';
    });
  }

  final String url = hostName +
      'api/clients/get-all-client-food-categories/?search=${search_query ?? ''}&page=$page$filterQuery';

  final response = await http.get(
    Uri.parse(url),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      'Authorization': 'Token $token', //+ token.toString()
      //'Authorization': 'Token '  + token.toString()
    },
  );

  if (response.statusCode == 200) {
    print(response.body);
    return CategoriesModel.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load data');
  }
}

class CategoriesWidget extends StatefulWidget {
  const CategoriesWidget({super.key});

  @override
  State<CategoriesWidget> createState() => _CategoriesWidgetState();
}

class _CategoriesWidgetState extends State<CategoriesWidget>
    with TickerProviderStateMixin {
  Future<CategoriesModel?>? _futureAllCategories;
  List<FoodCategories> _allCategories = [];
  bool _isLoading = false;
  bool _isSearchVisible = false;
  int _currentPage = 1;
  int _totalPages = 1;
  Map<String, String>? _filters;
  String? _searchQuery;

  // Animation controllers for each list item
  List<AnimationController>? _controllers;

  Future<CategoriesModel?> _fetchCategories({bool loadMore = false}) async {
    if (_isLoading) return Future.error('Loading in progress');

    setState(() {
      _isLoading = true;
    });

    try {
      final categoriesData = await get_all_categories(
        page: loadMore ? _currentPage + 1 : 1,
        filters: _filters,
        search_query: _searchQuery,
      );

      setState(() {
        if (loadMore) {
          _allCategories.addAll(categoriesData.data!.foodCategories!);
          _currentPage++;
        } else {
          _allCategories = categoriesData.data!.foodCategories!;
          _currentPage = 1;
        }
        _totalPages = categoriesData.data!.pagination!.totalPages!;
        _isLoading = false;

        // Reinitialize the animation controllers after fetching the categories
        _controllers = List.generate(_allCategories.length, (index) {
          return AnimationController(
            duration: Duration(milliseconds: 500),
            vsync: this,
          )..forward();
        });
      });

      if (_allCategories.isEmpty) {
        return null;
      }

      return categoriesData;
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      return Future.error('Failed to load data');
    }
  }

  @override
  void initState() {
    super.initState();
    _futureAllCategories = _fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header Row (Back Button, Title, Search)
            Container(
              padding: EdgeInsetsDirectional.fromSTEB(10, 10, 10, 0),
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
                    "Categories",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.black),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isSearchVisible =
                            !_isSearchVisible; // Toggle search visibility
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.search,
                        size: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Search Input Section
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              padding: EdgeInsets.all(8.0),
              child: AnimatedOpacity(
                duration: Duration(milliseconds: 300),
                opacity: _isSearchVisible ? 1 : 0,
                child: _isSearchVisible ? searchInputSection() : Container(),
              ),
            ),
            // Category List
            Expanded(
              child: FutureBuilder<CategoriesModel?>(
                future: _futureAllCategories,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || _allCategories.isEmpty) {
                    return Center(child: Text('No categories available'));
                  } else {
                    final allCategories = snapshot.data!.data!.foodCategories!;
                    return NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification scrollInfo) {
                        if (!_isLoading &&
                            scrollInfo.metrics.pixels ==
                                scrollInfo.metrics.maxScrollExtent) {
                          if (_currentPage < _totalPages) {
                            _fetchCategories(loadMore: true);
                          }
                          return true;
                        }
                        return false;
                      },
                      child: ListView.builder(
                        itemCount: allCategories.length + (_isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == allCategories.length) {
                            return Center(child: CircularProgressIndicator());
                          }
                          return listDataWidget(context, allCategories, index);
                        },
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // List data widget with animations
  Padding listDataWidget(
      BuildContext context, List<FoodCategories> allCategories, int index) {
    // Ensure the controllers list is not null and has enough controllers
    if (_controllers == null || _controllers!.length <= index) {
      return Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(10, 10, 10, 5),
        child: Text('Controller not available'),
      );
    }

    final controller = _controllers![index];
    final slideAnimation = Tween<Offset>(
            begin: Offset(0.0, 0.2), end: Offset(0.0, 0.0))
        .animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(10, 10, 10, 5),
      child: AnimatedOpacity(
        duration: Duration(milliseconds: 500),
        opacity: 1.0,
        child: SlideTransition(
          position: slideAnimation,
          child: Container(
            width: 100,
            height: 173, // Adjust the height as needed
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              image: DecorationImage(
                fit: BoxFit.cover,
                image: Image.network(
                        hostNameMedia + allCategories[index].photo!.toString())
                    .image,
              ),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: Color(0x6E000000),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter, // Align to the bottom
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(10, 0, 10, 10),
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.end, // Align text at the bottom
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          allCategories[index].name!.toString(),
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.copyWith(
                                    fontFamily: 'Inter',
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                        SizedBox(
                            height:
                                4), // Optional: space between the name and description
                        Text(
                          allCategories[index].description!.toString(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.copyWith(
                                    fontFamily: 'Inter',
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w300,
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
      ),
    );
  }

  // Search input section
  Padding searchInputSection() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: const InputDecoration(
          labelText: 'Search',
          labelStyle: TextStyle(color: Colors.black),
          enabledBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
          focusedBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
        ),
        style: TextStyle(color: Colors.black),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
            _currentPage = 1;
          });
          _applyFilters();
        },
      ),
    );
  }

  // Apply filters
  void _applyFilters() {
    setState(() {
      _futureAllCategories = _fetchCategories();
    });
  }

  // Reset filters
  void _resetFilters() {
    setState(() {
      _filters = null;
      _searchQuery = null;
      _currentPage = 1;
      _futureAllCategories = _fetchCategories();
    });
  }

  // Show filters bottom sheet
  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Filters',
                      style: TextStyle(color: bookPrimary, fontSize: 18)),
                  SizedBox(height: 16),
                  // Year Group Dropdown
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: DropdownButton<String>(
                      hint: Text("Select Year Group"),
                      value: _filters?['year_group'],
                      onChanged: (String? newValue) {
                        setState(() {
                          _filters = _filters ?? {};
                          _filters!['year_group'] = newValue ?? '';
                        });
                      },
                      items: <String>['2020', '2021', '2022', '2023']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 16),
                  // City Input
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: TextFormField(
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        hintStyle: TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.normal),
                        labelText: "City",
                        labelStyle: TextStyle(
                            fontSize: 13, color: Colors.black.withOpacity(0.5)),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white)),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white)),
                        border: InputBorder.none,
                      ),
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(225),
                        PasteTextInputFormatter(),
                      ],
                      textInputAction: TextInputAction.next,
                      onChanged: (String? newValue) {
                        setState(() {
                          _filters = _filters ?? {};
                          _filters!['city'] = newValue ?? '';
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  // House Dropdown
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: DropdownButton<String>(
                      hint: Text("Select House"),
                      value: _filters?['house'],
                      onChanged: (String? newValue) {
                        setState(() {
                          _filters = _filters ?? {};
                          _filters!['house'] = newValue ?? '';
                        });
                      },
                      items: <String>['House1', 'House2', 'House3']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 24),
                  // Apply and Reset Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _applyFilters();
                        },
                        child: Text('Apply Filters',
                            style: TextStyle(color: bookPrimary)),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _resetFilters();
                        },
                        child: Text('Reset Filters',
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ],
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
