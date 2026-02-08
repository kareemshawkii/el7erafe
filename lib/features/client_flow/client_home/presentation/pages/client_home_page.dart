import 'package:flutter/material.dart';

class ClientHomePage extends StatelessWidget {
  const ClientHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ClientHomePageView();
  }
}

class ClientHomePageView extends StatefulWidget {
  const ClientHomePageView({super.key});
  @override
  State<ClientHomePageView> createState() => _ClientHomePageViewState();
}

class _ClientHomePageViewState extends State<ClientHomePageView> {
  @override         
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Client Home Page")),
      body: const Center(
        child: Text(
          "Client Home",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}