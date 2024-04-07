import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../models/user.dart';

final List<User> users = [
  User(userId: '1', screenName: 'ezajil1'),
  User(userId: '2', screenName: 'ezajil2'),
  User(userId: '3', screenName: 'ezajil3'),
  User(userId: '4', screenName: 'ezajil4'),
  User(userId: '5', screenName: 'ezajil5'),
  User(userId: '6', screenName: 'ezajil6'),
  User(userId: '7', screenName: 'ezajil7'),
  User(userId: '8', screenName: 'ezajil8'),
  User(userId: '9', screenName: 'ezajil9'),
  User(userId: '10', screenName: 'ezajil10'),
];

class UsernameSelection extends StatefulWidget {
  final Function(User) onUserSelected;

  UsernameSelection({required this.onUserSelected});

  @override
  _UsernameSelectionState createState() => _UsernameSelectionState();
}

class _UsernameSelectionState extends State<UsernameSelection> {
  User? selectedUser;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DropdownButton<User>(
        value: selectedUser,
        hint: Text('Select User'),
        onChanged: (User? newValue) {
          setState(() {
            selectedUser = newValue;
          });
          if (newValue != null) {
            widget.onUserSelected(newValue);
          }
        },
        items: users.map<DropdownMenuItem<User>>((User user) {
          return DropdownMenuItem<User>(
            value: user,
            child: Text(user.screenName),
          );
        }).toList(),
      ),
    );
  }
}