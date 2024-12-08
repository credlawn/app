import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:credlawn/helpers/session_manager.dart';
import 'package:credlawn/models/user.dart';
import 'home_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/cupertino.dart';
import 'package:credlawn/custom/custom_color.dart';
import 'package:credlawn/network/api_network.dart';
import 'package:credlawn/network/api_login_helper.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String _message = '';

  bool viewPass = true;

  final String _apiUrl = ApiNetwork.login;

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
        Uri.parse(_apiUrl),
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
            User? user = await apiLoginHelper(jsonResponse, cookies);

            if (user != null) {
              CustomColor.showSuccessSnackBar(context, 'Welcome, ${user.fullName}');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(user: user),
                ),
              );
            } else {
              setState(() {
                _message = 'Error: Unable to fetch user data.';
              });
              CustomColor.showErrorSnackBar(context, 'Error: Unable to get user data.');
            }
          }
        }

      } else {
        setState(() {
          _message = 'Login failed! Please check your credentials.';
        });
        CustomColor.showErrorSnackBar(context, 'Login failed! Please check your credentials.');
      }
      
    } catch (e) {
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
                boxShadow: [
                  BoxShadow(
                    spreadRadius: 3,
                    blurRadius: 3,
                    color: Colors.grey.shade400,
                  ),
                ],
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
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'LOGIN',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(8)),
                        fillColor: Colors.white,
                        filled: true,
                        prefixIcon: const Icon(Icons.alternate_email_rounded),
                        prefixIconColor: Colors.green,
                        hintText: 'Email',
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _passwordController,
                      obscureText: viewPass,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(8)),
                        suffixIcon: InkWell(
                          onTap: () {
                            setState(() {
                              viewPass = !viewPass;
                            });
                          },
                          child: viewPass
                              ? const Icon(
                                  CupertinoIcons.eye_slash,
                                  color: Colors.green,
                                )
                              : const Icon(
                                  CupertinoIcons.eye,
                                  color: Colors.green,
                                ),
                        ),
                        prefixIcon: const Icon(CupertinoIcons.lock),
                        prefixIconColor: Colors.green,
                        hintText: 'Password',
                        hintStyle: GoogleFonts.poppins(),
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
