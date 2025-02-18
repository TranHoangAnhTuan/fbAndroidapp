import 'package:flutter/material.dart';
import 'package:fb_scrape/sign_in/components/custom_text_field.dart';
import 'package:fb_scrape/sign_in/components/social_sign_in_button.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: 310, // Fixed width container for all content
            child: Column(
              children: [
                SizedBox(height: 110),
                Image.network(
                  'https://cdn.builder.io/api/v1/image/assets/fdcd3b480ad74ef88680204f18559404/1ea3748d1d59e6eb2d9d1cc0d493f01d26e5f73af5b609d6b2c371803ccf8c57?apiKey=fdcd3b480ad74ef88680204f18559404&',
                  width: 98,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 50),
                Center(
                  child: Text(
                    'sign in your account',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 31,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                SizedBox(height: 35),
                // Email label and input
                Align(
                  // align to the left but more 5 pixels
                  alignment: Alignment(-0.95, 0),
                  child: Text(
                    'Email',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w300,
                      fontFamily: 'Inter',
                      letterSpacing: 0.22,
                    ),
                  ),
                ),
                SizedBox(height: 5),
                Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: Color(0xFFF5F3F3),
                    borderRadius: BorderRadius.circular(60),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'ex:john.smith@gmai.com',
                      style: TextStyle(
                        color: Color(0xFFCAC2C2),
                        fontSize: 15,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 5),
                // Password label and input
                Align(
                  alignment: Alignment(-0.95, 0),
                  child: Text(
                    'Password',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w300,
                      fontFamily: 'Inter',
                      letterSpacing: 0.22,
                    ),
                  ),
                ),
                SizedBox(height: 5),
                Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: Color(0xFFF5F3F3),
                    borderRadius: BorderRadius.circular(60),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '************',
                      style: TextStyle(
                        color: Color(0xFFCAC2C2),
                        fontSize: 15,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                // Sign in button
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF46BE5C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(60),
                    ),
                    minimumSize: Size(310, 42),
                    maximumSize: Size(310, 42),
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(
                    'sign in',
                    style: TextStyle(
                      color: Color(0xFFF3ECEC),
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Nunito',
                      letterSpacing: 0.22,
                    ),
                  ),
                ),
                SizedBox(height: 43),
                Text(
                  'or sign in with',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w300,
                    fontFamily: 'Inter',
                    letterSpacing: 0.22,
                  ),
                ),
                SizedBox(height: 34),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center, // Changed to center
                  
                ),
                SizedBox(height: 37),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "don't have account? ",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w300,
                          fontFamily: 'Inter',
                          letterSpacing: 0.22,
                        ),
                      ),
                      Text(
                        'sign up',
                        style: TextStyle(
                          color: Color(0xFF000100),
                          fontSize: 15,
                          fontWeight: FontWeight.w300,
                          fontFamily: 'Inter',
                          letterSpacing: 0.22,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}