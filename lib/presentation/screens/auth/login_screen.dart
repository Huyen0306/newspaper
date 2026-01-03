import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/auth_api_service.dart';
import '../main/main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final AuthApiService _authApiService = AuthApiService();
  final TextEditingController _usernameController = TextEditingController(
    text: 'emilys',
  );
  final TextEditingController _passwordController = TextEditingController(
    text: 'emilyspass',
  );
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _rememberMe = true;

  Future<void> _login() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar('Vui lòng nhập đầy đủ thông tin', Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authApiService.login(
        username: _usernameController.text,
        password: _passwordController.text,
      );

      final success = await _authService.saveAuthData(
        token: result['token'] as String,
        refreshToken: result['refreshToken'] as String?,
        user: result['user'] as UserModel,
      );

      if (success && mounted) {
        _showSnackBar('Đăng nhập thành công!', Colors.green);
        // Navigate to home
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Đăng nhập thất bại: ${e.toString()}', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Đăng nhập',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1C1C1E),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Chào mừng trở lại, chúng tôi rất nhớ bạn',
                style: TextStyle(
                  fontSize: 16,
                  color: const Color(0xFF3C3C43).withOpacity(0.7),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 40),
              // Username field
              const Text(
                'Tên đăng nhập',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1C1C1E),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  hintText: 'Nhập tên đăng nhập',
                  hintStyle: TextStyle(
                    color: const Color(0xFF3C3C43).withOpacity(0.4),
                    fontSize: 15,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: const Color(0xFF3C3C43).withOpacity(0.1),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: const Color(0xFF3C3C43).withOpacity(0.1),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF1e293b),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Password field
              const Text(
                'Mật khẩu',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1C1C1E),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Nhập mật khẩu',
                  hintStyle: TextStyle(
                    color: const Color(0xFF3C3C43).withOpacity(0.4),
                    fontSize: 15,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Iconsax.eye_slash : Iconsax.eye,
                      color: const Color(0xFF3C3C43).withOpacity(0.5),
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: const Color(0xFF3C3C43).withOpacity(0.1),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: const Color(0xFF3C3C43).withOpacity(0.1),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF1e293b),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Remember me & Forgot password
              Row(
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: _rememberMe,
                      activeColor: const Color(0xFF1e293b),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      onChanged: (val) {
                        setState(() {
                          _rememberMe = val ?? true;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Ghi nhớ đăng nhập',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF3C3C43),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      _showSnackBar(
                        'Chức năng quên mật khẩu chưa được thực hiện',
                        Colors.black54,
                      );
                    },
                    child: const Text(
                      'Quên mật khẩu?',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1e293b),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // Login button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1e293b),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Đăng nhập',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 30),
              // Demo info
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Demo: emilys / emilyspass',
                    style: TextStyle(color: Color(0xFF3C3C43), fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Sign up
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Chưa có tài khoản? ',
                    style: TextStyle(
                      color: const Color(0xFF3C3C43).withOpacity(0.6),
                      fontSize: 15,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _showSnackBar(
                        'Chức năng đăng ký chưa được thực hiện',
                        Colors.black54,
                      );
                    },
                    child: const Text(
                      'Đăng ký',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1e293b),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
