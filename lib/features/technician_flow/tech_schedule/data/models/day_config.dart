import 'package:flutter/material.dart';

class DayScheduleConfig {
  final String name;
  final int backendId;
  bool isSelected;
  TimeOfDay? fromTime;
  TimeOfDay? toTime;
  final ExpansibleController tileController = ExpansibleController();

  DayScheduleConfig({
    required this.name,
    required this.backendId,
    this.isSelected = false,
    this.fromTime,
    this.toTime,
  });
}
