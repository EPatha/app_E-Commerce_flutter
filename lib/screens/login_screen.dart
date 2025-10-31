import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard_screen.dart';
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  // no persistent flag needed — Create Account button always visible

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    // Load accounts map and prefill current user/password if available
    final accountsJson = prefs.getString('accounts');
    final current = prefs.getString('currentUser') ?? prefs.getString('username');
    if (accountsJson != null && current != null) {
      try {
        final Map<String, dynamic> map = json.decode(accountsJson);
        if (map.containsKey(current)) {
          setState(() {
            _userController.text = current;
            _passController.text = map[current].toString();
          });
        }
      } catch (_) {
        // ignore parse errors
      }
    }
  }

  Future<void> _createAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final u = _userController.text.trim();
    final p = _passController.text.trim();
    if (u.isEmpty || p.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Username and password required')));
      return;
    }
    // Persist into accounts map so multiple accounts are supported
    final accountsJson = prefs.getString('accounts');
    Map<String, String> accounts = {};
    if (accountsJson != null) {
      try {
        final Map<String, dynamic> parsed = json.decode(accountsJson);
        parsed.forEach((k, v) => accounts[k] = v.toString());
      } catch (_) {}
    }
    if (accounts.containsKey(u)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Username already exists')));
      return;
    }
    accounts[u] = p;
    await prefs.setString('accounts', json.encode(accounts));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account created')));
  }

  Future<void> _login() async {
    final prefs = await SharedPreferences.getInstance();
    final accountsJson = prefs.getString('accounts');
    final u = _userController.text.trim();
    final p = _passController.text.trim();
    if (accountsJson == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No account found. Please create one.')));
      return;
    }
    try {
      final Map<String, dynamic> map = json.decode(accountsJson);
      final stored = map[u];
      if (stored == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No such username')));
        return;
      }
      if (p == stored.toString()) {
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('currentUser', u);
        await prefs.setString('username', u); // keep compatibility
        Navigator.of(context).pushReplacementNamed(DashboardScreen.routeName);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid credentials')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login error')));
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
            ElevatedButton(onPressed: _createAccount, child: const Text('Create Account')),
          ],
        ),
      ),
    );
  }
}
