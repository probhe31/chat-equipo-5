import 'package:flutter/material.dart';
import 'package:flutter_flash_chat/pages/welcome_page.dart';
import 'package:flutter_flash_chat/pages/login_page.dart';
import 'package:flutter_flash_chat/pages/registration_page.dart';
import 'package:flutter_flash_chat/pages/chat_page.dart';

void main() => runApp(FlashChat());

class FlashChat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(initialRoute: WelcomePage.id, routes: {
      WelcomePage.id: (context) => WelcomePage(),
      LoginPage.id: (context) => LoginPage(),
      RegistrationPage.id: (context) => RegistrationPage(),
      ChatPage.id: (context) => ChatPage(),
    });
  }
}
