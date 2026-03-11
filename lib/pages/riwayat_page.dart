import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lsp_mkc_app/pages/riwayat_controller.dart';

class RiwayatPage extends GetView<RiwayatController> {
  const RiwayatPage({super.key});


  @override
  Widget build(BuildContext context) {

    return Scaffold(
    appBar: AppBar(title: Text('RiwayatPage')),

    body: SafeArea(
      child: Text('RiwayatController'))
    );
  }
}