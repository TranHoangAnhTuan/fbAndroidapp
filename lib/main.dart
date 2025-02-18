import 'package:flutter/material.dart';
import 'package:fb_scrape/pages/chat_page.dart';
import 'package:fb_scrape/pages/posts_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:fb_scrape/widgets/animated_nav_item.dart';
import 'dart:convert';
import "package:fb_scrape/sign_in/sign_in_screen.dart";
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('en', 'US'),
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: FirebaseAuth.instance.currentUser == null ? const SignInScreen() : const MainScreen(),
    );
  }
}
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final User? user = FirebaseAuth.instance.currentUser;

  static final List<Widget> _pages = <Widget>[
    const PostsPage(),     // You'll need to create this page
    const PostsPage(),   // You'll need to create this page
    const PostsPage(), // You'll need to create this page
    const PostsPage(), // You'll need to create this page
    const PostsPage(),  // You'll need to create this page
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    // Navigate back to the login page
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const SignInScreen()),
    );
  }

  @override
  void initState() {
    super.initState();
    if (user != null) {
      sendUserDataToServer(user!);
    }
  }

  Future<void> sendUserDataToServer(User user) async {
    final String serverUrl = 'http://10.0.2.2:5000/auth';
    final String? token = await user.getIdToken();
    
    final response = await http.post(
      Uri.parse(serverUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': user.email,
        'name': user.displayName,
        'photo_url': user.photoURL,
        'auth_token': token,
      }),
    );
    
    if (response.statusCode == 200) {
      print('User data sent successfully');
    } else {
      print('Failed to send user data: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        title: const Text('Flutter Demo'),
        actions: [
          if (user != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(user!.photoURL ?? ''),
                  ),
                  const SizedBox(width: 8),
                  Text(user!.displayName ?? 'User'),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: _logout,
                  ),
                ],
              ),
            ),
        ],
      ),
      body: _pages[_selectedIndex], // Display selected page
      bottomNavigationBar: Container(
        height: 80,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedNavItem(
              icon: 'assets/icons/navigationbar/Home.png',
              activeIcon: 'assets/icons/navigationbar/transformed/Home.png',
              label: 'Home',
              isSelected: _selectedIndex == 0,
              onTap: () => _onItemTapped(0),
            ),
            AnimatedNavItem(
              icon: 'assets/icons/navigationbar/Search.png',
              activeIcon: 'assets/icons/navigationbar/transformed/Search.png',
              label: 'Search',
              isSelected: _selectedIndex == 1,
              onTap: () => _onItemTapped(1),
            ),
            AnimatedNavItem(
              icon: 'assets/icons/navigationbar/Bag.png',
              activeIcon: 'assets/icons/navigationbar/transformed/Bag.png',
              label: 'Job News',
              isSelected: _selectedIndex == 2,
              onTap: () => _onItemTapped(2),
            ),
            AnimatedNavItem(
              icon: 'assets/icons/navigationbar/Setting.png',
              activeIcon: 'assets/icons/navigationbar/transformed/Setting.png',
              label: 'Settings',
              isSelected: _selectedIndex == 3,
              onTap: () => _onItemTapped(3),
            ),
            AnimatedNavItem(
              icon: 'assets/icons/navigationbar/User.png',
              activeIcon: 'assets/icons/navigationbar/transformed/User.png',
              label: 'Profile',
              isSelected: _selectedIndex == 4,
              onTap: () => _onItemTapped(4),
            ),
          ],
        ),
      ),
    );
  }
}