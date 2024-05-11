import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yayscribbl/Screens/login/login_page_vm.dart';

import 'auth_input_text.dart';

class LogIn extends ConsumerStatefulWidget {
  const LogIn({Key? key}) : super(key: key);

  @override
  ConsumerState<LogIn> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LogIn> {
  final TextEditingController employeeIdTextController =
      TextEditingController();
  final TextEditingController passwordTextController = TextEditingController();

  @override
  void dispose() {
    employeeIdTextController.dispose();
    passwordTextController.dispose();
    super.dispose();
  }

  void process() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? employeeId = prefs.getString('employeeId');
    String? password = prefs.getString('password');
    setState(() {
      if (employeeId != null && password != null) {
        employeeIdTextController.text = employeeId.toString();
        passwordTextController.text = password.toString();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    process();
  }

  @override
  Widget build(BuildContext context) {
    final loginPageVM = ref.watch(loginPageVMProvider);
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
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
          child: SafeArea(
            child: Center(
              child: loginPageVM.isLoading
                  ? const CircularProgressIndicator()
                  : SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        //crossAxisAlignment: CrossAxisAlignment.center,
                        //mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Word Charades!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 40,
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Container(
                            height: 280,
                            width: MediaQuery.of(context).size.width / 1.1,
                            decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(20)),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20, right: 20, bottom: 20, top: 20),
                                  child: AuthInputText(
                                    textEditingController:
                                        employeeIdTextController,
                                    hintText: "Crazy Player",
                                    labelText: "Player Name",
                                    textInputType: TextInputType.none,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20, right: 20),
                                  child: AuthInputText(
                                    textEditingController:
                                        passwordTextController,
                                    labelText: "Password",
                                    hintText: "********",
                                    textInputType: TextInputType.none,
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0)),
                                        backgroundColor: Colors.purple,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 131, vertical: 20)),
                                    onPressed: () {
                                      loginPageVM.employeeLogin(
                                          employeeIdTextController.text,
                                          passwordTextController.text);
                                    },
                                    child: const Text(
                                      'Log In',
                                      style: TextStyle(fontSize: 17),
                                    )),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 25,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Let's Play!! ",
                                style: TextStyle(
                                  color: Colors.black.withOpacity(0.5),
                                  fontWeight: FontWeight.w300,
                                  fontSize: 18,
                                ),
                              ),
                              TextButton(
                                onPressed: () {},
                                child: const Text(
                                  "SignUp",
                                  style: TextStyle(
                                    color: Colors.deepPurple,
                                    fontWeight: FontWeight.w300,
                                    fontSize: 18,
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
      ]),
    );
  }
}
