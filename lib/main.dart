import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'database/db_helper.dart';
void main() {
  runApp(const MyApp());
}
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}
class _MyAppState extends State<MyApp> {
  bool? isLoggedIn;
  String userName = '';
  String userId = '';
  @override
  void initState() {
    super.initState();
    checkLogin();
  }
  Future<void> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();

    final loggedIn = prefs.getBool('is_logged_in') ?? false;
    final savedName = prefs.getString('user_name') ?? '';
    final savedContact = prefs.getString('user_contact') ?? '';
    if (loggedIn && savedContact.isNotEmpty) {
      await DbHelper().assignOldTransactionsToUser(savedContact);
    }
    if (!mounted) return;
    setState(() {
      isLoggedIn = loggedIn;
      userName = savedName;
      userId = savedContact;
    });
  }
  Future<void> handleLogin(String name) async {
    final prefs = await SharedPreferences.getInstance();
    final contact = prefs.getString('user_contact') ?? '';
    if (contact.isNotEmpty) {
      await DbHelper().assignOldTransactionsToUser(contact);
    }
    if (!mounted) return;
    setState(() {
      userName = name;
      userId = contact;
      isLoggedIn = true;
    });
  }
  Future<void> handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);
    await prefs.remove('user_name');
    await prefs.remove('user_contact');
    if (!mounted) return;
    setState(() {
      userName = '';
      userId = '';
      isLoggedIn = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: isLoggedIn == null
          ? const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      )
          : isLoggedIn!
          ? HomeScreen(
        userName: userName,
        userId: userId,
        onLogout: handleLogout,
      )
          : LoginScreen(
        onLogin: handleLogin,
      ),
    );
  }
}

