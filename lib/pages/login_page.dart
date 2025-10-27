import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:buildausermanagement/main.dart';
import 'package:buildausermanagement/pages/account_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  bool _redirecting = false;
  late final TextEditingController _emailController = TextEditingController();
  late final StreamSubscription<AuthState> _authStateSubscription;

  Future<void> _signIn() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final email = _emailController.text.trim();
      if (email.isEmpty) {
        throw 'Por favor ingresa tu email';
      }

      await supabase.auth.signInWithOtp(
        email: email,
        emailRedirectTo: kIsWeb
            ? null
            : 'io.supabase.buildausermanagement://login-callback/',
        shouldCreateUser: true,
      );

      if (mounted) {
        context.showSnackBar('¡Revisa tu email para el enlace de acceso! 📧');
        _emailController.clear();
      }
    } on AuthException catch (error) {
      if (mounted) {
        String errorMessage = error.message;
        if (error.message.contains('code verifier')) {
          errorMessage = 'Error de autenticación. Intenta nuevamente.';
        }
        context.showSnackBar(errorMessage, isError: true);
      }
    } catch (error) {
      if (mounted) {
        String errorMessage = error.toString();
        if (error.toString().contains('SocketException') ||
            error.toString().contains('Failed host lookup')) {
          errorMessage =
              'Sin conexión a internet. Verifica tu WiFi o datos móviles.';
        } else if (error.toString().contains('Por favor ingresa')) {
          errorMessage = error.toString();
        } else {
          errorMessage =
              'Error de conexión. Verifica tu internet y vuelve a intentar.';
        }
        context.showSnackBar(errorMessage, isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    
    // Verificar si ya hay una sesión activa
    final session = supabase.auth.currentSession;
    if (session != null) {
      Future.delayed(Duration.zero, () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AccountPage()),
        );
      });
      return;
    }
    
    _authStateSubscription = supabase.auth.onAuthStateChange.listen(
      (data) {
        if (_redirecting) return;
        final session = data.session;
        if (session != null && mounted) {
          _redirecting = true;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const AccountPage()),
          );
        }
      },
      onError: (error) {
        if (mounted) {
          String errorMessage = 'Error de autenticación';
          if (error is AuthException) {
            errorMessage = error.message;
            if (error.message.contains('code verifier')) {
              errorMessage = 'Error de autenticación. Intenta acceder desde el mismo dispositivo.';
            }
          }
          context.showSnackBar(errorMessage, isError: true);
        }
      },
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _authStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFF2D2D2D,
      ), // Fondo gris oscuro como en la imagen
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              // Título principal
              const Text(
                'Sign In',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              // Descripción
              const Text(
                'Sign in via the magic link with your email below',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 60),
              // Campo de email
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Email',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                    ),
                    child: TextFormField(
                      controller: _emailController,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                        hintText: 'Enter your email',
                        hintStyle: TextStyle(
                          color: Colors.white38,
                          fontSize: 16,
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60),
              // Botón de enviar magic link
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _signIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFF4CAF50,
                    ), // Verde como en la imagen
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                    disabledBackgroundColor: const Color(
                      0xFF4CAF50,
                    ).withOpacity(0.6),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Send Magic Link',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
