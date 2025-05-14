// ignore_for_file: invalid_use_of_protected_member, unnecessary_to_list_in_spreads

import 'package:cal_room/blocs/reservation/reservation__bloc.dart';
import 'package:cal_room/blocs/reservation/reservation__state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:cal_room/utils/color_utils.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  TextEditingController filterController = TextEditingController();
  final List<String> filterList = ["Daily", "Monthly", "Yearly"];
  String selectedFilter = "Daily";

  @override
  void initState() {
    super.initState();
    filterController.text = selectedFilter;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sales Report"),
        centerTitle: true,
        backgroundColor: ColorUtils.blue,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: () => showFilterDialog(),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      filterController.text,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<ReservationBloc, ReservationState>(
                builder: (context, state) {
                  if (state is ReservationLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ReservationError) {
                    return Center(child: Text('Error: ${state.message}'));
                  } else if (state is ReservationLoaded) {
                    final reservationList = state.reservations;
                    final groupedTransactions =
                        groupTransactions(reservationList);

                    if (groupedTransactions.isEmpty) {
                      return const Center(
                          child: Text("No transactions found."));
                    }

                    return ListView.builder(
                      itemCount: groupedTransactions.length,
                      itemBuilder: (context, index) {
                        final entry =
                            groupedTransactions.entries.elementAt(index);

                        // Calculate total per group
                        final groupTotal = entry.value.fold<double>(
                          0,
                          (sum, item) => sum + (item['amount'] as double),
                        );

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (selectedFilter != 'Daily') ...[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      entry.key,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: ColorUtils.blue,
                                      ),
                                    ),
                                    Text(
                                      "\$ ${groupTotal.toStringAsFixed(2)}",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                              ],
                              ...entry.value.map((item) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        item['date'],
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      Text(
                                        "\$ ${item['amount'].toStringAsFixed(2)}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.green[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        );
                      },
                    );
                  } else {
                    return const Center(child: Text('No Reservations Found'));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showFilterDialog() {
    String tempFilter = selectedFilter;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Select Filter"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: filterList.map((filter) {
              return RadioListTile(
                title: Text(filter),
                value: filter,
                groupValue: tempFilter,
                onChanged: (value) {
                  setState(() {
                    selectedFilter = value!;
                    filterController.text = value;
                    Navigator.pop(context);
                  });
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Map<String, List<Map<String, dynamic>>> groupTransactions(
      List reservationList) {
    Map<String, List<Map<String, dynamic>>> grouped = {};

    for (var item in reservationList) {
      final checkoutDate = DateFormat("yyyy-MM-dd").parse(item.checkout);
      String groupKey = "";

      if (selectedFilter == "Daily") {
        groupKey = DateFormat("dd MMM yyyy").format(checkoutDate);
      } else if (selectedFilter == "Monthly") {
        groupKey = DateFormat("MMMM yyyy").format(checkoutDate);
      } else if (selectedFilter == "Yearly") {
        groupKey = DateFormat("yyyy").format(checkoutDate);
      }

      if (!grouped.containsKey(groupKey)) {
        grouped[groupKey] = [];
      }

      grouped[groupKey]!.add({
        "date": DateFormat("dd MMM yyyy").format(checkoutDate),
        "amount": (item.grandTotal as num).toDouble(),
      });
    }

    return grouped;
  }
}
