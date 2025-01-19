import 'package:flutter/material.dart';

class CustomNavBar extends StatelessWidget {
  final List<Widget> pages; // List of pages to navigate to
  final Function(int) onTabSelected; // Callback when a tab is selected

  CustomNavBar({required this.pages, required this.onTabSelected});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        margin: const EdgeInsets.all(5),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.green],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(color: Colors.transparent),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(context, 0, 'Home', 'assets/icons/home.png'),
                  _buildNavItem(context, 1, 'My Orders', 'assets/icons/card.png'),
                  _buildNavItem(context, 2, 'Transactions', Icons.explore),
                  _buildNavItem(context, 3, 'Settings', 'assets/icons/message.png'),
                  _buildNavItem(context, 4, 'Profile', 'assets/icons/person.png'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to create each navigation item
  Widget _buildNavItem(BuildContext context, int index, String label, dynamic icon) {
    return InkWell(
      onTap: () {
        // Call the callback and navigate to the selected page
        onTabSelected(index);
        // Ensure `pages` is correctly passed and used for navigation
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => pages[index]), // Correctly use pages[index]
        );
      },
      child: Column(
        children: [
          icon is IconData
              ? Icon(icon)
              : Image.asset(
                  icon,
                  height: 20,
                  color: Colors.grey,
                ),
          Text(
            label,
            style: TextStyle(fontSize: 9, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
