import 'package:flutter/material.dart';
import 'package:whatsapp_clone/views/homepage.dart';
import 'package:whatsapp_clone/views/username-selection.dart';

import 'models/user.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Whatsapp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  User? selectedUser;

  void onUserSelected(User user) {
    setState(() {
      selectedUser = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: selectedUser == null
          ? UsernameSelection(
              onUserSelected: onUserSelected,
            )
          : HomePage(
              user: selectedUser!,
            ),
    );
  }
}
