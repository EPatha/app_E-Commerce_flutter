import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

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
    setState(() {
      // Load username and password if present
      _userController.text = prefs.getString('username') ?? '';
      _passController.text = prefs.getString('password') ?? '';
    });
  }

  Future<void> _update() async {
    final u = _userController.text.trim();
    final p = _passController.text.trim();
    if (u.isEmpty || p.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User dan password tidak boleh kosong')));
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    // Persist username and password and keep user logged in
    await prefs.setString('username', u);
    await prefs.setString('password', p);
    await prefs.setBool('isLoggedIn', true);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Update berhasil')));
    Navigator.of(context).pop();
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    // Optionally keep username; navigate to Login and clear stack
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
