import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lsp_mkc_app/pages/pengajuan_controller.dart';

class PengajuanPage extends GetView<PengajuanController> {
  const PengajuanPage({super.key});


  @override
  Widget build(BuildContext context) {

    return Scaffold(
    appBar: AppBar(title: Text('PengajuanPage')),

    body: SafeArea(
      child: Text('PengajuanController'))
    );
  }
}