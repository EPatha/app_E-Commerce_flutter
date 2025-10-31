import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  bool _hasAccount = false;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // We only persist username (account marker). Password is not stored.
      // Check if account exists (username + password)
      _hasAccount = prefs.containsKey('username') && prefs.containsKey('password');
      if (prefs.containsKey('username')) {
        _userController.text = prefs.getString('username') ?? '';
      }
      if (prefs.containsKey('password')) {
        _passController.text = prefs.getString('password') ?? '';
      }
    });
  }

  Future<void> _createAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final u = _userController.text.trim();
    final p = _passController.text.trim();
    if (u.isEmpty || p.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Username and password required')));
      return;
    }
    // Persist username and password for login (demo purposes)
    await prefs.setString('username', u);
    await prefs.setString('password', p);
    setState(() => _hasAccount = true);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account created')));
  }

  Future<void> _login() async {
    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString('username');
    final storedPass = prefs.getString('password');
    final u = _userController.text.trim();
    final p = _passController.text.trim();
    if (storedUser == null || storedPass == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No account found. Please create one.')));
      return;
    }
    if (u == storedUser && p == storedPass) {
      // Mark logged in
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('username', u);
      Navigator.of(context).pushReplacementNamed(DashboardScreen.routeName);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid credentials')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _userController, decoration: const InputDecoration(labelText: 'Username')),
            const SizedBox(height: 8),
            TextField(controller: _passController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _login, child: const Text('Login')),
            const SizedBox(height: 8),
            if (!_hasAccount) ElevatedButton(onPressed: _createAccount, child: const Text('Create Account')),
          ],
        ),
      ),
    );
  }
}
