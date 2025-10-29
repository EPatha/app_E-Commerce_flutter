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
      _hasAccount = prefs.containsKey('username');
      if (_hasAccount) {
        _userController.text = prefs.getString('username') ?? '';
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
    // For this assignment we only persist username as account marker.
    await prefs.setString('username', u);
    setState(() => _hasAccount = true);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account created (password not stored)')));
  }

  Future<void> _login() async {
    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString('username');
    final u = _userController.text.trim();
    // We do not store password; for this demo we accept login when username matches stored username.
    if (storedUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No account found. Please create one.')));
      return;
    }
    if (u == storedUser) {
      // Mark logged in
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('username', u);
      Navigator.of(context).pushReplacementNamed(DashboardScreen.routeName);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid username')));
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
