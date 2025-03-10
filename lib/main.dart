import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'controller/badge_controller.dart';
import 'screens/user_screen.dart';
import 'screens/room_screen.dart';
import 'screens/reservation_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/settings_screen.dart';
import 'controller/user_controller.dart';
import 'controller/room_controller.dart';
import 'controller/reservation_controller.dart';
import 'database/db_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize the database before controllers
  Database db = await DBHelper.database;

  // ✅ Use Get.putAsync() to ensure database is ready before controllers
  await Get.putAsync(() async => UserController());
  await Get.putAsync(() async => RoomController());
  await Get.putAsync(() async => ReservationController());
  await Get.putAsync(() async => BadgeController());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Reservation App',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      home: MainScreen(),
    );
  }
}

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
      extendBody: true,
      appBar: AppBar(
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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: Obx(() => BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (index) {
              setState(() {
                currentIndex = index;
                clearBadge(index); // Clear badge on tap
              });
            },
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey,
            backgroundColor: Colors.white,
            elevation: 10,
            type: BottomNavigationBarType.fixed,
            items: [
              _buildNavItem(Icons.calendar_today, "Calendar", badgeController.calendarBadge.value),
              _buildNavItem(Icons.meeting_room, "Rooms", badgeController.roomsBadge.value),
              _buildNavItem(Icons.event, "Reservations", badgeController.reservationsBadge.value),
              _buildNavItem(Icons.person, "Users", badgeController.usersBadge.value),
              _buildNavItem(Icons.settings, "Settings", badgeController.settingsBadge.value),
            ],
          )),
        ),
      ),
    );
  }

  /// Helper function to build Bottom Navigation items with notification badges
  BottomNavigationBarItem _buildNavItem(IconData icon, String label, int badgeCount) {
    return BottomNavigationBarItem(
      icon: Stack(
        children: [
          Icon(icon, size: 28),
          if (badgeCount > 0) // Show badge only if there's a notification
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: EdgeInsets.all(5),
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
