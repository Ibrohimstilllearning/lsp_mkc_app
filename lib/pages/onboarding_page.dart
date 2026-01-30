import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lsp_mkc_app/pages/onboarding_controller.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingPage extends GetView<OnboardingController> {
  OnboardingPage({super.key});

  final pageController =  PageController();


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(bottom: 300),
        child: PageView(
          controller: pageController,
          children: [
            Container(
              color: Color(0xFF009447),
            ),
            Container(
              color: Color(0xFF009447),
            ),
            Container(
              color: Color(0xFF009447),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        height: 300,
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            SizedBox(height: 10),
            SmoothPageIndicator(
              controller: pageController,
              count: 3,
              effect: WormEffect(
                activeDotColor: Color(0xFF009447),
                dotColor: Color(0xFF787878),
                dotHeight: 12,
                dotWidth: 12,
              ),
            ),
            Text(
              "Selamat Datang",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1f1f1f),
              ),
            )

          ],
        ),
      ),
    );
  }
}