import 'package:flutter/material.dart';
import 'package:whatsapp_clone/shared/data/all_users.dart';
import 'package:whatsapp_clone/shared/models/user.dart';

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
        items: allUsers.map<DropdownMenuItem<User>>((User user) {
          return DropdownMenuItem<User>(
            value: user,
            child: Text(user.screenName),
          );
        }).toList(),
      ),
    );
  }
}