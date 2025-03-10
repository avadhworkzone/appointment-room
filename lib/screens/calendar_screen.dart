import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controller/reservation_controller.dart';
import '../model/reservation_model.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final ReservationController reservationController = Get.find();
  DateTime _selectedDay = DateTime.now();
  Map<DateTime, List<ReservationModel>> _eventsMap = {};

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  /// ✅ **Ensures correct date parsing**
  DateTime _parseDate(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      try {
        return DateFormat("dd-MM-yyyy").parse(dateString);
      } catch (e) {
        print("Date parsing error: $e");
        return DateTime.now();
      }
    }
  }

  /// ✅ **Optimized function to pre-load reservations into a Map**
  void _loadEvents() {
    setState(() {
      _eventsMap.clear();
      for (var res in reservationController.reservationList) {
        DateTime parsedDate = _parseDate(res.checkin);
        if (_eventsMap.containsKey(parsedDate)) {
          _eventsMap[parsedDate]!.add(res);
        } else {
          _eventsMap[parsedDate] = [res];
        }
      }
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
              });
            },
            eventLoader: (day) => _eventsMap[day] ?? [],
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
              selectedDecoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: _eventsMap[_selectedDay]?.length ?? 0,
              itemBuilder: (context, index) {
                final reservation = _eventsMap[_selectedDay]![index];
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
