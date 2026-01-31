import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lsp_mkc_app/pages/loading_controller.dart';

class LoadingPage extends GetView<LoadingController> {
  const LoadingPage({super.key});


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Color(0xFF009447),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: LoadingAnimationWidget.waveDots(
              color: Colors.white,
              size: 200  ,
            ),
          ),
          Text(
              'Tunggu sebentar ya...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold
              ),
            ),
        ],
      ),
    );
  }
}

