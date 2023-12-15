import 'package:flutter/material.dart';
import 'package:rss_feed_reader_app/src/widgets/sign_in_form.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  SignInScreenState createState() => SignInScreenState();
}

class SignInScreenState extends State<SignInScreen> {
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _emailFocusNode.unfocus();
        _passwordFocusNode.unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  bottom: 20.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const Row(),
                    const Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            flex: 1,
                            child: FlutterLogo(size: 100),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'FlutterFire',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 40,
                            ),
                          ),
                          Text(
                            'Authentication',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 40,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SignInForm(
                      emailFocusNode: _emailFocusNode,
                      passwordFocusNode: _passwordFocusNode,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}