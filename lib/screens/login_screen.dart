import 'package:credlawn/helpers/device_info_helper.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:credlawn/models/user.dart';
import 'package:credlawn/models/login_result.dart';
import 'home_screen.dart';
import 'manager_home_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/cupertino.dart';
import 'package:credlawn/custom/custom_color.dart';
import 'package:credlawn/api/server_api.dart';
import 'package:credlawn/network/api_login_helper.dart';
import 'package:credlawn/helpers/error_logger.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String _message = '';
  bool viewPass = true;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    final email = _emailController.text;
    final password = _passwordController.text;

    if (email.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      CustomColor.showErrorSnackBar(context, 'Please Enter Email');
      return;
    }

    if (password.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      CustomColor.showErrorSnackBar(context, 'Please Enter Password');
      return;
    }

    try {
      final response = await http.post(
        ServerApi.login,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'usr': email,
          'pwd': password,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse['message'] == 'Logged In') {
          var cookies = response.headers['set-cookie'];

          if (cookies != null) {
            LoginResult loginResult = await apiLoginHelper(jsonResponse, cookies);

            if (loginResult.success && loginResult.user != null) {
              User user = loginResult.user!;
              String? token = await FirebaseMessaging.instance.getToken();
              String? deviceId = await getDeviceId();
              if (token != null && deviceId != null) {
                await sendFcmTokenToServer(
                  token: token,
                  deviceId: deviceId,
                  userId: user.userId,
                );
              }
              CustomColor.showSuccessSnackBar(context, 'Welcome, ${user.fullName}');
              Widget homeScreen = user.role == 'Manager' ? ManagerHomeScreen(user: user) : HomeScreen(user: user);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => homeScreen,
                ),
              );
            } else {
              // Handle different error types
              String errorMessage;
              switch (loginResult.errorType) {
                case LoginErrorType.invalidCredentials:
                  errorMessage = 'Invalid credentials';
                  break;
                case LoginErrorType.unauthorizedAccess:
                  errorMessage = 'Unauthorized access error';
                  break;
                case LoginErrorType.permissionDenied:
                  errorMessage = 'You don\'t have permission to access resources';
                  break;
                case LoginErrorType.networkError:
                  errorMessage = 'Network connection error';
                  break;
                default:
                  errorMessage = loginResult.errorMessage ?? 'Authentication failed';
              }

              await ErrorLogger.logError(
                title: 'Login Validation Failed',
                errorMessage: 'Error Type: ${loginResult.errorType}, Message: ${loginResult.errorMessage}',
                errorType: 'Auth',
                userId: email,
              );

              setState(() {
                _message = errorMessage;
              });
              CustomColor.showErrorSnackBar(context, errorMessage);
            }
          } else {
            await ErrorLogger.logError(
              title: 'Login Missing Cookies',
              errorMessage: 'Login successful but no cookies received from server',
              errorType: 'Auth',
              userId: email,
            );
            setState(() {
              _message = 'Authentication error: No session received';
            });
            CustomColor.showErrorSnackBar(context, 'Authentication error: No session received');
          }
        }
      } else {
        await ErrorLogger.logApiError(
          endpoint: ServerApi.login.toString(),
          method: 'POST',
          statusCode: response.statusCode,
          responseBody: response.body,
          userId: email,
        );
        setState(() {
          _message = 'Login failed! Please check your credentials.';
        });
        CustomColor.showErrorSnackBar(context, 'Login failed! Please check your credentials.');
      }

    } catch (e) {
      await ErrorLogger.logException(
        context: 'login',
        exception: e,
        userId: email,
      );
      setState(() {
        _message = 'Error: Unable to connect to the server.';
      });
      CustomColor.showErrorSnackBar(context, 'Error: Unable to connect to the server.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        elevation: 0.5,
        backgroundColor: CustomColor.MainColor,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 75),
          Image.asset(
            'assets/image/login_img.png',
            height: 60,
          ),
          const SizedBox(height: 75),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: CustomColor.MainColor,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 30),
                    Text(
                      'Welcome back, login to continue',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      controller: _emailController,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Email',
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.grey.shade500,
                          fontSize: 16,
                        ),
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: CustomColor.MainColor,
                          size: 22,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: CustomColor.MainColor, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _passwordController,
                      obscureText: viewPass,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.grey.shade500,
                          fontSize: 16,
                        ),
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: CustomColor.MainColor,
                          size: 22,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              viewPass = !viewPass;
                            });
                          },
                          icon: Icon(
                            viewPass ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey.shade500,
                            size: 22,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: CustomColor.MainColor, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    _isLoading
                        ? SpinKitWaveSpinner(
                            trackColor: Colors.white,
                            waveColor: Colors.greenAccent.shade700,
                            color: Colors.greenAccent.shade700,
                            size: 50.0,
                          )
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                backgroundColor: Colors.greenAccent.shade700,
                                minimumSize: const Size(double.infinity, 50)),
                            onPressed: _login,
                            child: Text(
                              'LOGIN',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.white),
                            ),
                          ),
                    const SizedBox(height: 40),
                    Text(
                      '© 2025 Credlawn. All rights reserved.',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
