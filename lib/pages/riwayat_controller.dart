import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lsp_mkc_app/utils/api_endpoints.dart';
import 'package:lsp_mkc_app/utils/api_helper.dart';
import 'package:lsp_mkc_app/pages/pengajuan_controller.dart';

class RiwayatController extends GetxController {
  final isLoading = true.obs;
  final hasError = false.obs;
  final riwayatList = <RegistrationItem>[].obs;

  final searchController = TextEditingController();
  final searchQuery = ''.obs;
  var sortTerbaru = true.obs;
  var selectedSkema = <String>{}.obs;

  List<String> get availableSkema {
    return riwayatList.map((e) => e.schemeName).toSet().toList()..sort();
  }

  List<RegistrationItem> get filteredList {
    var list = riwayatList.toList();

    if (searchQuery.value.isNotEmpty) {
      list = list.where((item) =>
        item.schemeName.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
        item.schemeCode.toLowerCase().contains(searchQuery.value.toLowerCase())
      ).toList();
    }

    if (selectedSkema.isNotEmpty) {
      list = list.where((item) =>
        selectedSkema.contains(item.schemeName)
      ).toList();
    }

    list.sort((a, b) => sortTerbaru.value
      ? b.createdAt.compareTo(a.createdAt)
      : a.createdAt.compareTo(b.createdAt));

    return list;
  }

  void toggleSkema(String skema) {
    if (selectedSkema.contains(skema)) {
      selectedSkema.remove(skema);
    } else {
      selectedSkema.add(skema);
    }
  }

  void toggleSortTerbaru(bool value) => sortTerbaru.value = value;

  void resetFilter() {
    sortTerbaru.value = true;
    selectedSkema.clear();
  }

  @override
  void onInit() {
    super.onInit();
    fetchRiwayat();
    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchRiwayat() async {
    isLoading.value = true;
    hasError.value = false;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/registrations'),
        headers: ApiEndpoints.authHeaders(token),
      );

      final data = ApiHelper.handleResponse(response);
      if (data != null) {
        final List list = data['response'] ?? [];
        final allItems = list
            .map((e) => RegistrationItem.fromJson(e))
            .toList();

        riwayatList.assignAll(
          allItems.where((item) {
            final apl01 = item.forms.firstWhereOrNull(
              (f) => f.code == 'APL.01',
            );
            return apl01?.status == 'approved';
          }).toList(),
        );
      } else {
        hasError.value = true;
      }
    } catch (e) {
      ApiHelper.handleException(e);
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }
}