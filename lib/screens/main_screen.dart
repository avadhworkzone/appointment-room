import 'package:cal_room/screens/reservation_screen.dart';
import 'package:cal_room/screens/room_screen.dart';
import 'package:cal_room/screens/settings_screen.dart';
import 'package:cal_room/screens/user_screen.dart';
import 'package:flutter/material.dart';

import '../controller/badge_controller.dart';
import 'calendar_screen.dart';
import 'package:get/get.dart';
class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;
  final screens = [
    CalendarScreen(),
    RoomScreen(),
    ReservationScreen(),
    UserScreen(),
    SettingsScreen(),
  ];

  final BadgeController badgeController = Get.find<BadgeController>();

  /// Clear badge count for the selected screen when tapped
  void clearBadge(int index) {
    switch (index) {
      case 0:
        badgeController.calendarBadge.value = 0;
        break;
      case 1:
        badgeController.roomsBadge.value = 0;
        break;
      case 2:
        badgeController.reservationsBadge.value = 0;
        break;
      case 3:
        badgeController.usersBadge.value = 0;
        break;
      case 4:
        badgeController.settingsBadge.value = 0;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: false, // Removes floating bottom bar
      appBar: AppBar(
        leading:        Icon(Icons.calendar_month,size: 30,), // ✅ Replace with your logo
          
        title: Text("Reservation App"),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {
              showSearch(context: context, delegate: DataSearch());
            },
          ),
        ],
      ),
      body: screens[currentIndex],

      bottomNavigationBar: Obx(() => NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;
            clearBadge(index); // Clear badge on tap
          });
        },
        destinations: [
          _buildNavItem(Icons.calendar_today, "Calendar", badgeController.calendarBadge.value),
          _buildNavItem(Icons.meeting_room, "Rooms", badgeController.roomsBadge.value),
          _buildNavItem(Icons.event, "Reservations", badgeController.reservationsBadge.value),
          _buildNavItem(Icons.person, "Users", badgeController.usersBadge.value),
          _buildNavItem(Icons.settings, "Settings", badgeController.settingsBadge.value),
        ],
      )),
    );
  }

  /// 🔹 Modern **Navigation Bar Item with Notification Badges**
  NavigationDestination _buildNavItem(IconData icon, String label, int badgeCount) {
    return NavigationDestination(
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(icon, size: 28),
          if (badgeCount > 0)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                constraints: BoxConstraints(minWidth: 18, minHeight: 18),
                child: Text(
                  badgeCount > 99 ? "99+" : badgeCount.toString(),
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      label: label,
    );
  }
}

// 🔹 Search Feature with Improved UI
class DataSearch extends SearchDelegate<String> {
  final List<String> searchItems = [
    "User 1",
    "User 2",
    "Room 101",
    "Room 102",
    "Reservation A",
    "Reservation B",
  ];

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(icon: Icon(Icons.clear, color: Colors.black), onPressed: () => query = ""),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(icon: Icon(Icons.arrow_back, color: Colors.black), onPressed: () => close(context, ""));
  }

  @override
  Widget buildResults(BuildContext context) {
    return Center(child: Text("Result: $query", style: TextStyle(color: Colors.black, fontSize: 18)));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = searchItems.where((item) => item.toLowerCase().contains(query.toLowerCase())).toList();
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) => ListTile(
        leading: Icon(Icons.search, color: Colors.blue),
        title: Text(suggestions[index], style: TextStyle(color: Colors.black)),
        onTap: () => query = suggestions[index],
      ),
    );
  }
}