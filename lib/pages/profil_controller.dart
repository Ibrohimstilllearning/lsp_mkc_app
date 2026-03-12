// dart:convert → menyediakan jsonDecode() dan jsonEncode()
// jsonDecode: ubah string JSON dari API → Map Dart
// jsonEncode: ubah Map Dart → string JSON untuk dikirim ke API
import 'dart:convert';
import 'package:get/get.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
// get_storage → penyimpanan lokal key-value (seperti SharedPreferences)
// dipakai untuk menyimpan dan membaca token login
import 'package:get_storage/get_storage.dart';
class ProfilController extends GetxController {
  
final _box = GetStorage();

}