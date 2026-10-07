import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/local_storage.dart';
import '../widgets/trekora_logo.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLogin = true; // true = tampilan Login, false = tampilan Register
  bool _ready = false; // true kalau status akun sudah selesai dicek
  bool _busy = false; // true selama proses daftar/masuk berjalan

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadInitialMode();
  }

  /// Kalau belum ada akun terdaftar di perangkat ini, langsung tampilkan tab
  /// Daftar, karena pengguna wajib daftar dulu sebelum bisa masuk.
  Future<void> _loadInitialMode() async {
    final hasAccounts = await AuthService.hasAccounts();
    if (!mounted) return;
    setState(() {
      _isLogin = hasAccounts;
      _ready = true;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      if (_isLogin) {
        await _login();
      } else {
        await _register();
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _login() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    if (email.trim().isEmpty || password.isEmpty) {
      _showMessage('Mohon isi email dan kata sandi.');
      return;
    }

    final account = await AuthService.login(email, password);
    if (!mounted) return;

    if (account == null) {
      final hasAccounts = await AuthService.hasAccounts();
      if (!mounted) return;
      _showMessage(
        hasAccounts
            ? 'Email atau kata sandi salah.'
            : 'Belum ada akun terdaftar. Silakan daftar dulu.',
      );
      return;
    }

    Navigator.pushReplacementNamed(context, '/main');
  }

  Future<void> _register() async {
    final name = _nameController.text.trim();

    final error = await AuthService.register(
      name: name,
      email: _emailController.text,
      password: _passwordController.text,
      confirm: _confirmController.text,
    );
    if (!mounted) return;

    if (error != null) {
      _showMessage(error);
      return;
    }

    // Nama saat daftar dipakai sebagai nama di halaman profil.
    currentUser.name = name;
    await LocalStorage.saveProfile(currentUser);
    if (!mounted) return;

    // Pindah ke tab Masuk, email dibiarkan terisi biar tinggal ketik sandi.
    setState(() {
      _isLogin = true;
      _nameController.clear();
      _passwordController.clear();
      _confirmController.clear();
    });
    _showMessage('Akun berhasil dibuat. Silakan masuk.');
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(backgroundColor: Color(0xFF161613));
    }

    return Scaffold(
      backgroundColor: const Color(0xFF161613), // tema gelap
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              // Logo / Wordmark
              const Center(
                child: TrekoraWordmark(
                  logoSize: 40,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Track Your Life',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
              ),
              const SizedBox(height: 40),

              // Tab Login / Sign Up
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF232320),
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(child: _buildTabButton('Masuk', true)),
                    Expanded(child: _buildTabButton('Daftar', false)),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              if (!_isLogin) ...[
                _buildTextField(
                  controller: _nameController,
                  hint: 'Nama Lengkap',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 14),
              ],
              _buildTextField(
                controller: _emailController,
                hint: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),
              _buildTextField(
                controller: _passwordController,
                hint: 'Kata Sandi',
                icon: Icons.lock_outline,
                obscureText: true,
              ),
              if (!_isLogin) ...[
                const SizedBox(height: 14),
                _buildTextField(
                  controller: _confirmController,
                  hint: 'Konfirmasi Kata Sandi',
                  icon: Icons.lock_outline,
                  obscureText: true,
                ),
              ],

              if (_isLogin) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      'Lupa kata sandi?',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 12),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: _busy ? null : _submit,
                  child: Text(
                    _isLogin ? 'MASUK' : 'DAFTAR',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              Center(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isLogin = !_isLogin;
                    });
                  },
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 13,
                      ),
                      children: [
                        TextSpan(
                          text: _isLogin
                              ? 'Belum punya akun? '
                              : 'Sudah punya akun? ',
                        ),
                        TextSpan(
                          text: _isLogin ? 'Daftar' : 'Masuk',
                          style: const TextStyle(
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, bool isLoginTab) {
    final bool selected = _isLogin == isLoginTab;
    return GestureDetector(
      onTap: () {
        setState(() {
          _isLogin = isLoginTab;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.deepOrange : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? Colors.white : Colors.grey.shade400,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade500),
        prefixIcon: Icon(icon, color: Colors.grey.shade500),
        filled: true,
        fillColor: const Color(0xFF232320),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}