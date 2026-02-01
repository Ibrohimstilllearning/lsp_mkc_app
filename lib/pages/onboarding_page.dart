import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lsp_mkc_app/pages/onboarding_controller.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingPage extends GetView<OnboardingController> {
  OnboardingPage({super.key});

  final pageController = PageController();
  bool isLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(bottom: 50),
        child: PageView(
          controller: pageController,
          onPageChanged: (index) {
            controller.onPageChanged(index);
          },
          children: [
            Container(
              color: Color(0xFF009447),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 100),
                  Image.asset('assets/onboarding1.png', width: 500),
                  Text(
                    'Selamat Datang!🎊',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Solusi digital untuk raih sertifikasi kompetensi Anda dengan mudah dan transparan.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Color(0xFF009447),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SafeArea(
                    child: Row(
                      children: [
                        SizedBox(width: 10),
                        IconButton(
                          onPressed: () => pageController.previousPage(
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          ),
                          icon: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 50),
                  Image.asset('assets/onboarding2.png', width: 500),
                  SizedBox(height: 53),
                  Text(
                    'Lengkapi Berkas Anda',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Lengkapi data diri dan unggah dokumen pendukung langsung dari aplikasi. Isi form FR.APL-01 dan FR.APL-02 tanpa ribet.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Color(0xFF009447),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SafeArea(
                    child: Row(
                      children: [
                        SizedBox(width: 10),
                        IconButton(
                          onPressed: () => pageController.previousPage(
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          ),
                          icon: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 80),
                  Image.asset('assets/onboarding3.png', width: 250),
                  SizedBox(height: 53),
                  Text(
                    'Pantau Proses Sertifikasi',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Dapatkan notifikasi real-time tentang status sertifikasi Anda. Pantau kemajuan proses sertifikasi dengan mudah melalui aplikasi.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Obx(() {
  return controller.isLastPage.value
      ? Container(
          padding: EdgeInsets.all(40),
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(color: Color(0xFF009447)),
          child: Column(
            children: [
/*               SmoothPageIndicator(
                controller: pageController,
                count: 3,
                effect: WormEffect(
                  dotColor: Colors.white70,
                  activeDotColor: Colors.white,
                ),
              ), */
              SizedBox(height: 30),
              TextButton(
                onPressed: controller.loadingScreen,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 100, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    'Bersiap!',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF009447),
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      : Container(
          padding: EdgeInsets.all(40),
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(color: Color(0xFF009447)),
          child: Column(
            children: [
              SmoothPageIndicator(
                controller: pageController,
                count: 3,
                effect: WormEffect(
                  dotColor: Colors.white70,
                  activeDotColor: Colors.white,
                ),
              ), 
              SizedBox(height: 30),
              TextButton(
                onPressed: () {
                  pageController.nextPage(
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 100, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    'Berikutnya',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF009447),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
}),

    );
  }
}
