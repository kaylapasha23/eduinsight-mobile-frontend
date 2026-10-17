import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nimController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nimController.dispose();
    super.dispose();
  }

  void _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final nim = _nimController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnackbar('Nama, email, dan password wajib diisi.', isError: true);
      return;
    }

    if (password.length < 6) {
      _showSnackbar('Password minimal 6 karakter.', isError: true);
      return;
    }

    if (password != confirmPassword) {
      _showSnackbar('Password dan konfirmasi password tidak cocok.', isError: true);
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.register(
      name: name,
      email: email,
      password: password,
      role: 'mahasiswa',
      nim: nim.isNotEmpty ? nim : null,
      fakultas: 'Ilmu Komputer',
      prodi: 'Teknik Informatika',
      angkatan: '2023',
    );

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (mounted) {
      _showSnackbar(authProvider.errorMessage ?? 'Registrasi gagal.', isError: true);
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? const Color(0xFFE5484D) : const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = isDark ? Colors.grey[400] : const Color(0xFF3A5A9B);
    final titleColor = isDark ? const Color(0xFF82B1FF) : const Color(0xFF0D1B40);
    final bgColor = isDark ? const Color(0xFF121418) : const Color(0xFFF0F4FF);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),
                // Logo
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1E2B52).withValues(alpha: 0.18),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Daftar Akun',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Buat akun baru untuk mulai menggunakan EduInsight',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: labelColor),
                ),
                const SizedBox(height: 36),

                // Nama Lengkap
                _buildLabel('Nama Lengkap', labelColor),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _nameController,
                  hint: 'Masukkan nama lengkap',
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 18),

                // Email
                _buildLabel('Email', labelColor),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _emailController,
                  hint: 'Masukkan email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 18),

                // NIM
                _buildLabel('NIM (Opsional)', labelColor),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _nimController,
                  hint: 'Masukkan NIM',
                  icon: Icons.badge_outlined,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 18),

                // Password
                _buildLabel('Password', labelColor),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _passwordController,
                  hint: 'Minimal 6 karakter',
                  icon: Icons.lock_outline_rounded,
                  obscure: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: const Color(0xFF3A6BBF),
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                const SizedBox(height: 18),

                // Konfirmasi Password
                _buildLabel('Konfirmasi Password', labelColor),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _confirmPasswordController,
                  hint: 'Ulangi password',
                  icon: Icons.lock_outline_rounded,
                  obscure: _obscureConfirm,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: const Color(0xFF3A6BBF),
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
                const SizedBox(height: 36),

                // Register Button
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    return Container(
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1A2547), Color(0xFF3A6BBF)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1E2B52).withValues(alpha: 0.35),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: auth.isLoading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: auth.isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Daftar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Link ke Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sudah punya akun? ',
                      style: TextStyle(fontSize: 13, color: labelColor),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'Masuk di sini',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3A6BBF),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, Color? color) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 13,
        color: color,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF8EA3BF)),
        filled: true,
        fillColor: const Color(0xFFDDE8FF),
        prefixIcon: Icon(icon, color: const Color(0xFF3A6BBF), size: 20),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
