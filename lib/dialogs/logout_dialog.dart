import 'package:firebase_app/dialogs/generic_dialog.dart';
import 'package:flutter/cupertino.dart';

Future<bool> showLogOutAccountDialog(BuildContext context){
  return showGenericDialog<bool>(
    context: context,
    title: 'Log out',
    content: 'Are you sure you want to log out!',
    optionsBuilder: () =>{
      'Cancel': false,
      'Log out': true,
    },
  ).then((value) => value ?? false);
}