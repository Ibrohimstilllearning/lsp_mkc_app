import 'dart:convert';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:lsp_mkc_app/pages/forms/apl02/model/response.dart';
import 'package:lsp_mkc_app/pages/forms/apl02/model/submit.dart';
import 'package:lsp_mkc_app/pages/forms/apl02/providers/response_provider.dart';
import 'package:lsp_mkc_app/utils/api_endpoints.dart';

class Apl02Controller extends GetxController {
 final ResponseProvider _provider = ResponseProvider();

 //state
 var isLoading = false.obs;
 var isSubmitting = false.obs;
 var apl02Data = Rxn<ResponseRegistration>();

// Listener buat jawabn
 var userAnswer = <int, bool>{}.obs;

 @override
 void onInit() {
  super.onInit();
 }

  void fetchData(int registrationId) async {
    isLoading.value = true;
    var result = await _provider.getDatabyId(registrationId);
    if (result != null) {
      apl02Data.value = result;
      userAnswer.clear();
  } else {
    Get.snackbar('error', 'Tidak dapat fetch');
  }
  isLoading.value = false;
 }

  // logis radio
  void setAnswer (int elementId, bool isCompetent) {
    userAnswer[elementId] = isCompetent;
  }

  bool checkAnswer(int elementId, bool checkType){
    if(!userAnswer.containsKey(elementId)) return false;
    return userAnswer[elementId] == checkType;
  }

  // SUBMIT DATA LOGIC
  void submitForm() async {
    if (apl02Data.value == null) return;

    var regId = apl02Data.value!.registrationId!;

    isSubmitting.value = true;

    // AMBIL ID PORTFOLIO UNTUK STATE GET
    List<int> extractedPortfolioIds = [];
    if (apl02Data.value!.portfolios != null) {
        extractedPortfolioIds = apl02Data.value!.portfolios!
        .where((p) => p.id != null)
        .map((p) => p.id!)
        .toList();
    }
    // 2. Ubah Map userAnswers menjadi List<AnswerModel>
    List<AnswerModel> answersToSubmit = userAnswer.entries.map((entry) {
      return AnswerModel(elementId: entry.key, isCompetent: entry.value);
    }).toList();

    // 3. Susun Payload Akhir
    var payload = SubmitApl02Request(
      isDeclared: true, 
      portfolioIds: extractedPortfolioIds,
      answers: answersToSubmit,
    );

    // 4. Kirim via Provider
    bool success = await _provider.postDatabyId(regId, payload);

    if (success) {
      Get.snackbar('Sukses', 'Asesmen Mandiri tersimpan!');
      // Get.back();
    } else {
      Get.snackbar('Gagal', 'Terjadi kesalahan sistem');
    }
    
    isSubmitting.value = false;
  }
  }
  