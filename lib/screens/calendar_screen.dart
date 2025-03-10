import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import '../controller/reservation_controller.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final ReservationController reservationController = Get.put(ReservationController());
  DateTime _selectedDay = DateTime.now();
  List<dynamic> _events = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  /// Function to ensure date is properly formatted before parsing
  DateTime _parseDate(String dateString) {
    try {
      // If already in YYYY-MM-DD format, return directly
      return DateTime.parse(dateString);
    } catch (e) {
      // If format is incorrect, attempt conversion
      try {
        DateFormat inputFormat = DateFormat("dd-MM-yyyy"); // Format of incoming date
        DateTime parsedDate = inputFormat.parse(dateString); // Convert to DateTime
        DateFormat outputFormat = DateFormat("yyyy-MM-dd"); // Convert to correct format
        return DateTime.parse(outputFormat.format(parsedDate)); // Convert to DateTime
      } catch (e) {
        print("Date parsing error: $e"); // Debugging
        return DateTime.now(); // Default fallback
      }
    }
  }

  void _loadEvents() {
    setState(() {
      _events = reservationController.reservationList
          .where((res) => _parseDate(res.checkin).year == _selectedDay.year &&
          _parseDate(res.checkin).month == _selectedDay.month &&
          _parseDate(res.checkin).day == _selectedDay.day)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Calendar")),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _selectedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _loadEvents();
              });
            },
            eventLoader: (day) {
              return reservationController.reservationList
                  .where((res) => _parseDate(res.checkin).year == day.year &&
                  _parseDate(res.checkin).month == day.month &&
                  _parseDate(res.checkin).day == day.day)
                  .toList();
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
              selectedDecoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: _events.isEmpty
                ? Center(child: Text("No reservations on this day."))
                : ListView.builder(
              itemCount: _events.length,
              itemBuilder: (context, index) {
                final reservation = _events[index];
                return Card(
                  elevation: 4,
                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: ListTile(
                    title: Text(reservation.fullname, style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Check-in: ${reservation.checkin}\nCheck-out: ${reservation.checkout}"),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
