import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:yayscribbl/Screens/login/auth_input_text.dart';
import 'package:yayscribbl/Screens/login/login_page_vm.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final loginScreenVM = ref.watch(loginPageVMProvider);
    return Scaffold(
      body: Stack(children: [
        Container(
          width: width,
          height: height,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(24),
            ),
            image: DecorationImage(
                image: NetworkImage(
                    'https://images.unsplash.com/photo-1551376347-075b0121a65b?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=387&q=80'),
                fit: BoxFit.cover,
                opacity: 1),
          ),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(24),
                    ),
                    color: Colors.white.withOpacity(0.5),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Padding(padding: EdgeInsets.only(top: 8)),
                      const Text(
                        'Word Charades!',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: height * 0.025),
                      ),
                      AuthInputText(
                        textEditingController:
                            loginScreenVM.emailTextController,
                        textInputType: TextInputType.emailAddress,
                        hintText: 'coolplayer@gmail.com',
                        labelText: 'Email',
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: height * 0.5 * 0.05),
                      ),
                      AuthInputText(
                        textEditingController:
                            loginScreenVM.passwordTextController,
                        textInputType: TextInputType.visiblePassword,
                        hintText: 'my cool password',
                        labelText: 'Password',
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: height * 0.5 * 0.1),
                      ),
                      loginScreenVM.isLoading
                          // ignore: dead_code
                          ? SpinKitDoubleBounce(
                              size: 64,
                            )
                          : Row(
                              children: [
                                GestureDetector(
                                  onTap: () {},
                                  child: Container(
                                    alignment: Alignment.center,
                                    width: width * 0.55,
                                    padding: EdgeInsets.symmetric(
                                      // horizontal: width * 0.2,
                                      vertical: height * 0.5 * 0.05,
                                    ),
                                    decoration: const BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(16),
                                      ),
                                    ),
                                    child: const Text(
                                      'Sign In',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                    padding:
                                        EdgeInsets.only(left: width * 0.06)),
                              ],
                            ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'New Here?',
                            style: TextStyle(color: Colors.black),
                          ),
                          const Padding(padding: EdgeInsets.only(right: 8)),
                          GestureDetector(
                            onTap: () {
                              // Navigator.of(context).pushReplacement(
                              //     MaterialPageRoute(
                              //         builder: (BuildContext context) {
                              //   return const RegisterScreen();
                              // }));
                            },
                            child: const Text(
                              'Create Account',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
