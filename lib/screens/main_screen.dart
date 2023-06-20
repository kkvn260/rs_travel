import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rs_travel/config/palette.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  // String userName = '';
  String userEmail = '';
  String userPassword = '';
  var loginTab = true;
  var keyBoardOn = false;
  var loading = false;

  void _validForm() {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      _formKey.currentState!.save();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: ModalProgressHUD(
        inAsyncCall: loading,
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            setState(() {
              keyBoardOn = false;
            });
          },
          child: Stack(
            children: [
              //배경
              Positioned(
                top: 10,
                right: 10,
                left: 10,
                bottom: 10,
                child: Container(
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: AssetImage('assets/images/main_.jpg'),
                      fit: BoxFit.fill,
                    ),
                    borderRadius: BorderRadius.circular(20.0),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),
              ),
              //텍스트 폼
              Positioned(
                top: keyBoardOn
                    ? MediaQuery.of(context).size.height / 10
                    : MediaQuery.of(context).size.height / 2.5,
                right: 0,
                left: 0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                  height: (MediaQuery.of(context).size.height / 2) - 80,
                  width: MediaQuery.of(context).size.width - 40,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: Colors.white.withOpacity(0.8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  loginTab = true;
                                  keyBoardOn = false;
                                });
                              },
                              child: Column(
                                children: [
                                  Text(
                                    "Login",
                                    style: TextStyle(
                                      fontFamily: 'komi',
                                      color: loginTab
                                          ? Palette.activeColor
                                          : Palette.textColor1,
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (loginTab)
                                    Container(
                                      margin: const EdgeInsets.only(top: 3),
                                      height: 3,
                                      width: 55,
                                      color: Colors.blueGrey[500],
                                    ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  loginTab = false;
                                  keyBoardOn = false;
                                });
                              },
                              child: Column(
                                children: [
                                  Text(
                                    "Signin",
                                    style: TextStyle(
                                      fontFamily: 'komi',
                                      color: !loginTab
                                          ? Palette.activeColor
                                          : Palette.textColor1,
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (!loginTab)
                                    Container(
                                      margin: const EdgeInsets.only(top: 3),
                                      height: 3,
                                      width: 55,
                                      color: Colors.blueGrey[500],
                                    ),
                                ],
                              ),
                            )
                          ],
                        ),
                        if (loginTab)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 30),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  TextFormField(
                                    style: const TextStyle(
                                      fontFamily: 'komi',
                                      fontSize: 20,
                                    ),
                                    key: const ValueKey(1),
                                    onTap: () {
                                      setState(() {
                                        keyBoardOn = true;
                                      });
                                    },
                                    onSaved: (value) {
                                      userEmail = value!;
                                    },
                                    onChanged: (value) {
                                      userEmail = value;
                                    },
                                    validator: (value) {
                                      return null;
                                    },
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.email_rounded,
                                          color: Palette.iconColor,
                                        ),
                                        label: const Text('이메일'),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                        )),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  TextFormField(
                                    style: const TextStyle(
                                      fontFamily: 'komi',
                                      fontSize: 20,
                                    ),
                                    key: const ValueKey(2),
                                    obscureText: true,
                                    onTap: () {
                                      setState(() {
                                        keyBoardOn = true;
                                      });
                                    },
                                    onSaved: (value) {
                                      userPassword = value!;
                                    },
                                    onChanged: (value) {
                                      userPassword = value;
                                    },
                                    validator: (value) {
                                      if (value!.isEmpty || value.length < 6) {
                                        return '비밀번호는 6글자 이상 입력해주세요.';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.password,
                                          color: Palette.iconColor,
                                        ),
                                        label: const Text('비밀번호'),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                        )),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (!loginTab)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 30),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  TextFormField(
                                    style: const TextStyle(
                                      fontFamily: 'komi',
                                      fontSize: 20,
                                    ),
                                    key: const ValueKey(4),
                                    onTap: () {
                                      setState(() {
                                        keyBoardOn = true;
                                      });
                                    },
                                    onSaved: (value) {
                                      userEmail = value!;
                                    },
                                    onChanged: (value) {
                                      userEmail = value;
                                    },
                                    validator: (value) {
                                      return null;
                                    },
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.email_rounded,
                                          color: Palette.iconColor,
                                        ),
                                        label: const Text('이메일'),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                        )),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  TextFormField(
                                    style: const TextStyle(
                                      fontFamily: 'komi',
                                      fontSize: 20,
                                    ),
                                    obscureText: true,
                                    key: const ValueKey(5),
                                    onTap: () {
                                      setState(() {
                                        keyBoardOn = true;
                                      });
                                    },
                                    onSaved: (value) {
                                      userPassword = value!;
                                    },
                                    onChanged: (value) {
                                      userPassword = value;
                                    },
                                    validator: (value) {
                                      if (value!.isEmpty || value.length < 6) {
                                        return '비밀번호는 6글자 이상 입력해주세요.';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.password,
                                          color: Palette.iconColor,
                                        ),
                                        label: const Text('비밀번호'),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                        )),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              //버튼
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeIn,
                top: keyBoardOn ? MediaQuery.of(context).size.height / 8 : null,
                bottom: MediaQuery.of(context).size.height / 6,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    height: 70,
                    width: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: const LinearGradient(
                        colors: [
                          Colors.grey,
                          Colors.white,
                        ],
                      ),
                    ),
                    child: IconButton(
                      onPressed: () async {
                        try {
                          _validForm();
                          if (loginTab) {
                            setState(() {
                              loading = true;
                            });
                            await _auth.signInWithEmailAndPassword(
                              email: userEmail,
                              password: userPassword,
                            );
                          } else {
                            setState(() {
                              loading = true;
                            });
                            final newUser =
                                await _auth.createUserWithEmailAndPassword(
                              email: userEmail,
                              password: userPassword,
                            );
                            await FirebaseFirestore.instance
                                .collection('user')
                                .doc(newUser.user!.uid)
                                .set({
                              'userEmail': userEmail,
                            });
                          }
                        } catch (e) {
                          setState(() {
                            loading = false;
                          });
                          print(e);
                        }
                      },
                      icon: const Icon(Icons.arrow_forward),
                      color: Colors.black,
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
}
