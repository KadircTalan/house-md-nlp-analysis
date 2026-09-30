import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ---------------- SIGN IN ----------------
  Future<void> _signIn() async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      _showError("Lütfen tüm alanları doldurun.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) _goToHome();
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? "Giriş başarısız.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ---------------- SIGN UP ----------------
  Future<void> _signUp() async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      _showError("E-posta ve şifre gerekli.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Hesap başarıyla oluşturuldu"),
            backgroundColor: Colors.green,
          ),
        );

        _goToHome();
      }
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? "Kayıt başarısız.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ---------------- GOOGLE ----------------
  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      await GoogleSignIn.instance.initialize(
        serverClientId:
        '258043579962-tij0trr5u9ohashh3ao3609vlpbdapci.apps.googleusercontent.com',
      );

      final GoogleSignInAccount? googleUser =
      await GoogleSignIn.instance.authenticate();

      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final authorization = await googleUser.authorizationClient
          .authorizeScopes(['email']);

      final credential = GoogleAuthProvider.credential(
        accessToken: authorization.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);

      if (mounted) _goToHome();
    } catch (e) {
      _showError("Google giriş hatası oluştu.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ---------------- HELPERS ----------------
  void _goToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomePage(),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // BACKGROUND
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xff0F172A),
                  Color(0xff1E3A8A),
                  Color(0xff2563EB),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // GLOW EFFECTS
          Positioned(
            top: -80,
            left: -50,
            child: _glowCircle(
              size: 220,
              color: Colors.blueAccent.withOpacity(0.35),
            ),
          ),

          Positioned(
            bottom: -120,
            right: -50,
            child: _glowCircle(
              size: 260,
              color: Colors.cyanAccent.withOpacity(0.25),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(35),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 20,
                      sigmaY: 20,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(35),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.15),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // LOGO
                          Container(
                            height: 95,
                            width: 95,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xff60A5FA),
                                  Color(0xff2563EB),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.5),
                                  blurRadius: 30,
                                  spreadRadius: 2,
                                )
                              ],
                            ),
                            child: const Icon(
                              Icons.medical_services_rounded,
                              color: Colors.white,
                              size: 48,
                            ),
                          ),

                          const SizedBox(height: 25),

                          const Text(
                            "BLUE AI",
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 3,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            "Akıllı Tıbbi Analiz Platformu",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            ),
                          ),

                          const SizedBox(height: 35),

                          // EMAIL
                          _buildTextField(
                            controller: _emailController,
                            hint: "E-posta adresi",
                            icon: Icons.email_outlined,
                          ),

                          const SizedBox(height: 18),

                          // PASSWORD
                          _buildTextField(
                            controller: _passwordController,
                            hint: "Şifre",
                            icon: Icons.lock_outline_rounded,
                            obscure: _obscurePassword,
                            suffix: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscurePassword =
                                  !_obscurePassword;
                                });
                              },
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.white70,
                              ),
                            ),
                          ),

                          const SizedBox(height: 28),

                          // LOGIN BUTTON
                          SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              onPressed:
                              _isLoading ? null : _signIn,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                const Color(0xff3B82F6),
                                elevation: 15,
                                shadowColor:
                                Colors.blueAccent.withOpacity(0.6),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(18),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                height: 25,
                                width: 25,
                                child:
                                CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                                  : const Text(
                                "Giriş Yap",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight:
                                  FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 28),

                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: Colors.white24,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12),
                                child: Text(
                                  "veya",
                                  style: TextStyle(
                                    color:
                                    Colors.white.withOpacity(0.7),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: Colors.white24,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 28),

                          // GOOGLE BUTTON
                          SizedBox(
                            width: double.infinity,
                            height: 58,
                            child: OutlinedButton.icon(
                              onPressed: _isLoading ? null : _signInWithGoogle,
                              icon: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.g_mobiledata_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              label: const Text(
                                "Google ile Devam Et",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: Colors.white.withOpacity(0.08),
                                side: BorderSide(
                                  color: Colors.white.withOpacity(0.15),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),

                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            children: [
                              Text(
                                "Hesabın yok mu?",
                                style: TextStyle(
                                  color: Colors.white
                                      .withOpacity(0.8),
                                ),
                              ),
                              TextButton(
                                onPressed:
                                _isLoading ? null : _signUp,
                                child: const Text(
                                  "Kayıt Ol",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- CUSTOM TEXTFIELD ----------------
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withOpacity(0.08),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            vertical: 20,
          ),
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.5),
          ),
          prefixIcon: Icon(
            icon,
            color: Colors.white70,
          ),
          suffixIcon: suffix,
        ),
      ),
    );
  }

  // ---------------- GLOW CIRCLE ----------------
  Widget _glowCircle({
    required double size,
    required Color color,
  }) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}