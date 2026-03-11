import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lsp_mkc_app/pages/profil_controller.dart';

class ProfilPage extends GetView<ProfilController> {
  const ProfilPage({super.key});


  @override
  Widget build(BuildContext context) {

    return Scaffold(
    appBar: AppBar(title: Text('ProfilPage')),

    body: SafeArea(
      child: Text('ProfilController'))
    );
  }
}