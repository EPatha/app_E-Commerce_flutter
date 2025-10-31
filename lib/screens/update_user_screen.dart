import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'dart:convert';

class UpdateUserScreen extends StatefulWidget {
  static const routeName = '/update_user';
  const UpdateUserScreen({Key? key}) : super(key: key);

  @override
  State<UpdateUserScreen> createState() => _UpdateUserScreenState();
}

class _UpdateUserScreenState extends State<UpdateUserScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
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
        // fallback to single stored username/password
        setState(() {
          _userController.text = prefs.getString('username') ?? '';
          _passController.text = prefs.getString('password') ?? '';
        });
      }
    } else {
      setState(() {
        _userController.text = prefs.getString('username') ?? '';
        _passController.text = prefs.getString('password') ?? '';
      });
    }
  }

  Future<void> _update() async {
    final u = _userController.text.trim();
    final p = _passController.text.trim();
    if (u.isEmpty || p.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User dan password tidak boleh kosong')));
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final accountsJson = prefs.getString('accounts');
    Map<String, String> accounts = {};
    if (accountsJson != null) {
      try {
        final parsed = json.decode(accountsJson) as Map<String, dynamic>;
        parsed.forEach((k, v) => accounts[k] = v.toString());
      } catch (_) {}
    }
    final current = prefs.getString('currentUser') ?? prefs.getString('username');
    // If username changed and previous exists, remove old key
    if (current != null && current != u && accounts.containsKey(current)) {
      accounts.remove(current);
    }
    accounts[u] = p;
    await prefs.setString('accounts', json.encode(accounts));
    await prefs.setString('currentUser', u);
    await prefs.setBool('isLoggedIn', true);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Update berhasil')));
    Navigator.of(context).pop();
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    // Only clear the logged-in flag and currentUser; keep accounts
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('currentUser');
    Navigator.of(context).pushNamedAndRemoveUntil(LoginScreen.routeName, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update User & Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _userController, decoration: const InputDecoration(labelText: 'User')),
            const SizedBox(height: 8),
            TextField(controller: _passController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(onPressed: _update, child: const Text('Update')),
                const SizedBox(width: 8),
                OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                const SizedBox(width: 8),
                TextButton(onPressed: _logout, child: const Text('Logout', style: TextStyle(color: Colors.red))),
              ],
            )
          ],
        ),
      ),
    );
  }
}
