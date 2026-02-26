import 'package:flutter/material.dart';
import 'package:lsp_mkc_app/core/main_navigation.dart';

import 'package:flutter/material.dart';

// void main() {
//   runApp(const HomeApp());
// }

class HomeApp extends StatelessWidget {
  const HomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),

            /// ICON / IMAGE PLACEHOLDER
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 140,
                    width: 140,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                        )
                      ],
                    ),
                    child: const Icon(
                      Icons.description_outlined,
                      size: 60,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Belum ada pengajuan\npending, buat satu?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            /// BUTTON
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3E8E41),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Mulai Proses Sertifikasi",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),

      /// FLOATING BOTTOM NAV
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Container(
          height: 65,
          decoration: BoxDecoration(
            color: const Color(0xFF3E8E41),
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              Icon(Icons.home, color: Colors.white),
              Icon(Icons.description, color: Colors.white70),
              Icon(Icons.history, color: Colors.white70),
              Icon(Icons.person, color: Colors.white70),
              Icon(Icons.logout, color: Colors.white70),
            ],
          ),
        ),
      ),
    );
  }
}

