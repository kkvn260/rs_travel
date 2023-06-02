import 'package:flutter/material.dart';
import 'package:rs_travel/config/palette.dart';

class MainTravel extends StatefulWidget {
  const MainTravel({super.key});

  @override
  State<MainTravel> createState() => _MainTravelState();
}

class _MainTravelState extends State<MainTravel> {
  // final _auth = FirebaseAuth.instance;
  var loginTab = true;
  var keyBoardOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
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
                height: loginTab
                    ? (MediaQuery.of(context).size.height / 2) - 80
                    : (MediaQuery.of(context).size.height / 2) - 10,
                width: MediaQuery.of(context).size.width - 40,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  color: Colors.white.withOpacity(0.8),
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
                                    color: loginTab
                                        ? Palette.activeColor
                                        : Palette.textColor1,
                                    fontSize: 20,
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
                                    color: !loginTab
                                        ? Palette.activeColor
                                        : Palette.textColor1,
                                    fontSize: 20,
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
                            child: Column(
                              children: [
                                TextFormField(
                                  onTap: () {
                                    setState(() {
                                      keyBoardOn = true;
                                    });
                                  },
                                  key: const ValueKey(1),
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.email_rounded,
                                        color: Palette.iconColor,
                                      ),
                                      hintText: "이메일",
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      )),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                TextFormField(
                                  obscureText: true,
                                  onTap: () {
                                    setState(() {
                                      keyBoardOn = true;
                                    });
                                  },
                                  key: const ValueKey(2),
                                  decoration: InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.password,
                                        color: Palette.iconColor,
                                      ),
                                      hintText: "비밀번호",
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25),
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
                            child: Column(
                              children: [
                                TextFormField(
                                  onTap: () {
                                    setState(() {
                                      keyBoardOn = true;
                                    });
                                  },
                                  key: const ValueKey(3),
                                  keyboardType: TextInputType.name,
                                  decoration: InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.account_circle,
                                        color: Palette.iconColor,
                                      ),
                                      hintText: "닉네임",
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      )),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                TextFormField(
                                  onTap: () {
                                    setState(() {
                                      keyBoardOn = true;
                                    });
                                  },
                                  key: const ValueKey(4),
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.email_rounded,
                                        color: Palette.iconColor,
                                      ),
                                      hintText: "이메일",
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      )),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                TextFormField(
                                  obscureText: true,
                                  onTap: () {
                                    setState(() {
                                      keyBoardOn = true;
                                    });
                                  },
                                  key: const ValueKey(5),
                                  decoration: InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.password,
                                        color: Palette.iconColor,
                                      ),
                                      hintText: "비밀번호",
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25),
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
              top: keyBoardOn
                  ? loginTab
                      ? MediaQuery.of(context).size.height / 8
                      : MediaQuery.of(context).size.height / 4.5
                  : null,
              bottom: loginTab
                  ? MediaQuery.of(context).size.height / 6
                  : MediaQuery.of(context).size.height / 15,
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
                    onPressed: () {},
                    icon: const Icon(Icons.arrow_forward),
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
