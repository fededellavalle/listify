import 'package:flutter/material.dart';

class ListItem {
  String name;
  String type;
  TimeOfDay selectedTime;
  bool addExtraTime;
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  double ticketPrice;
  DateTime? selectedStartExtraDate;
  DateTime? selectedEndExtraDate;
  double? ticketExtraPrice;
  bool allowSublists;

  ListItem({
    required this.name,
    required this.type,
    required this.selectedTime,
    required this.addExtraTime,
    required this.selectedStartDate,
    required this.selectedEndDate,
    required this.selectedStartExtraDate,
    required this.selectedEndExtraDate,
    required this.ticketPrice,
    required this.ticketExtraPrice,
    required this.allowSublists,
  });
}
