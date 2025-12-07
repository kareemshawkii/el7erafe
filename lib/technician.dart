import 'package:flutter/material.dart';

class TechnicianPage extends StatelessWidget {
  const TechnicianPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Technician Page")),
      body: const Center(
        child: Text(
          "Technician",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
