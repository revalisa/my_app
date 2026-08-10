import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/pages/register_page.dart';

// statefulWidget menyimpan data yang bisa berubah
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  // memvalidasi form login
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  bool isResetLoading = false;
  bool isPasswordHidden = true;
  bool hasSubmitted = false;

  static const Color primaryColor = Color(0xff7A284A);
  static const Color secondaryColor = Color(0xffDFA5B8);
  static const Color backgroundColor = Color(0xffFFF7FA);
  static const Color accentColor = Color(0xffF8E5EC);
  void showMessage(String message) {
    if (!mounted) return;
    // menghilangkan snackbar sebelumnya jika ada, lalu menampilkan pesan baru
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  String getFirebaseAuthMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Format email tidak valid';
      case 'user-disabled':
        return 'Akun ini sudah dinonaktifkan';
      case 'user-not-found':
        return 'Email belum terdaftar';
      case 'wrong-password':
        return 'Password salah';
      case 'invalid-credential':
        return 'Email atau password salah';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi beberapa saat';
      case 'network-request-failed':
        return 'Koneksi internet bermasalah';
      default:
        return e.message ?? 'Login gagal';
    }
  }

  Future<void> login() async {
    setState(() {
      hasSubmitted = true;
    });

    if (!(formKey.currentState?.validate() ?? false)) {
      showMessage('Periksa email dan password');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      showMessage('Sedang login...');

     final credential = await auth.signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    await FirebaseFirestore.instance
        .collection('users')
        .doc(credential.user!.uid)
        .set({
      'email': credential.user!.email,
      'createdAt': FieldValue.serverTimestamp(),
    });

      if (!mounted) return;

      showMessage('Login berhasil');
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      showMessage(getFirebaseAuthMessage(e));
    } catch (e) {
      showMessage('Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> resetPassword() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      showMessage('Masukkan email terlebih dahulu');
      return;
    }

    if (!email.contains('@')) {
      showMessage('Format email tidak valid');
      return;
    }

    setState(() {
      isResetLoading = true;
    });

    try {
      showMessage('Mengirim link reset password...');

      await auth.sendPasswordResetEmail(
        email: email,
      );

      showMessage('Jika email terdaftar, link reset password akan dikirim');
    } on FirebaseAuthException catch (e) {
      showMessage(getFirebaseAuthMessage(e));
    } catch (e) {
      showMessage('Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          isResetLoading = false;
        });
      }
    }
  }

  @override
  // dispose untuk membersihkan controller saat tidak digunakan lagi
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: -70,
              right: -60,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: secondaryColor.withOpacity(.3),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Positioned(
              bottom: -80,
              left: -70,
              child: Container(
                width: 220,
                height: 220,
                decoration: const BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),

      Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              // fromkey untuk memvalidasi form login
              key: formKey,
              autovalidateMode: hasSubmitted
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.disabled,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(.15),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/images/app_icon.png',
                      width: 50,
                      height: 50,
                    ),
                  ),
                ),
              ),
                  const SizedBox(height: 18),
                  Text(
                    'Login',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Masuk ke aplikasi keuangan kamu',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 36),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Email",
                      filled: true,
                      fillColor: Colors.white,

                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: primaryColor,
                      ),

                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(
                          color: secondaryColor,
                        ),
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(
                          color: primaryColor,
                          width: 2,
                        ),
                      ),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    validator: (value) {
                      final email = value?.trim() ?? '';

                      if (email.isEmpty) {
                        return 'Email wajib diisi';
                      }

                      if (!email.contains('@')) {
                        return 'Email tidak valid';
                      }

                      return null;
                    },
                    onFieldSubmitted: (_) {
                      if (!isLoading) {
                        login();
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: passwordController,
                    obscureText: isPasswordHidden,

                    decoration: InputDecoration(
                      labelText: 'Password',

                      labelStyle: GoogleFonts.poppins(
                        color: primaryColor,
                      ),

                      filled: true,
                      fillColor: Colors.white,

                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: primaryColor,
                      ),

                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            isPasswordHidden = !isPasswordHidden;
                          });
                        },
                        icon: Icon(
                          isPasswordHidden
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: primaryColor,
                        ),
                      ),

                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(
                          color: secondaryColor,
                        ),
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(
                          color: primaryColor,
                          width: 2,
                        ),
                      ),

                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(
                          color: Colors.red,
                        ),
                      ),

                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 2,
                        ),
                      ),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),

                    validator: (value) {
                      final password = value?.trim() ?? '';

                      if (password.isEmpty) {
                        return 'Password wajib diisi';
                      }

                      if (password.length < 6) {
                        return 'Password minimal 6 karakter';
                      }

                      return null;
                    },

                    onFieldSubmitted: (_) {
                      if (!isLoading) {
                        login();
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: isLoading || isResetLoading
                          ? null
                          : () {
                              resetPassword();
                            },
                      child: Text(
                        isResetLoading
                            ? "Mengirim..."
                            : "Lupa Password?",
                        style: GoogleFonts.poppins(
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: isLoading || isResetLoading
                        ? null
                        : () {
                            login();
                          },
                    style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 5,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Login'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: isLoading || isResetLoading
                        ? null
                        : () {
                            showMessage('Membuka halaman daftar');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterPage(),
                              ),
                            );
                          },
                    child: Text(
                    "Belum punya akun? Daftar",
                    style: GoogleFonts.poppins(
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  ),
                ],
              ),
            ),
          ),
        ),
          ],
        )
      )
    );
  }
}