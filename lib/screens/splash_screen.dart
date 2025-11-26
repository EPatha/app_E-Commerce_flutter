import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = '/';
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), _checkAuth);
  }

  Future<void> _checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    // Check isLoggedIn flag (preferred) and fallback to username existence
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final hasUser = prefs.containsKey('username');
    if (isLoggedIn || hasUser) {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(DashboardScreen.routeName);
    } else {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Try to show an existing image as logo; fallback to FlutterLogo
            SizedBox(
              width: 120,
              height: 120,
              child: Image.asset(
                'assets/images/Estehajib-Jumbo.jpg',
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => const FlutterLogo(size: 120),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Selamat Datang', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('di', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            const Text('Warung Ajib', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            const Text('Bandungrejo, Mranggen, Demak', style: TextStyle(fontSize: 14, color: Colors.black54)),
            const SizedBox(height: 12),
            const Text('5 Pemrograman Perangkat Bergerak | Ajib Susanto', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
