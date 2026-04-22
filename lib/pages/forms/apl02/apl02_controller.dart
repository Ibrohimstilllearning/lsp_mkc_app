import 'package:get/get.dart';
import 'package:lsp_mkc_app/pages/forms/apl02/model/response.dart';
import 'package:lsp_mkc_app/pages/forms/apl02/model/submit.dart';
import 'package:lsp_mkc_app/pages/forms/apl02/providers/response_provider.dart';

class Apl02Controller extends GetxController {
  final int userId;
  final ResponseProvider _provider = ResponseProvider();

  // state
  var isLoading = false.obs;
  var isSubmitting = false.obs;
  var apl02Data = Rxn<ResponseRegistration>();
  var userAnswer = <int, bool>{}.obs;

  Apl02Controller({required this.userId});

  void fetchData(int registrationId) async {
    isLoading.value = true;
    final result = await _provider.getDatabyId(registrationId, userId);
    if (result != null) {
      apl02Data.value = result;
      userAnswer.clear();
    } else {
      Get.snackbar('Error', 'Tidak dapat fetch data APL02');
    }
    isLoading.value = false;
  }

  void setAnswer(int elementId, bool isCompetent) {
    userAnswer[elementId] = isCompetent;
  }

  bool checkAnswer(int elementId, bool checkType) {
    if (!userAnswer.containsKey(elementId)) return false;
    return userAnswer[elementId] == checkType;
  }

  void submitForm() async {
    if (apl02Data.value == null) return;

    final regId = apl02Data.value!.registrationId!;
    isSubmitting.value = true;

    // Ambil portfolioIds
    List<int> portfolioIds = apl02Data.value!.portfolios?.map((p) => p.id!).toList() ?? [];

    // Buat list answers
    List<AnswerModel> answers = userAnswer.entries
        .map((entry) => AnswerModel(elementId: entry.key, isCompetent: entry.value))
        .toList();

    final payload = SubmitApl02Request(
      isDeclared: true,
      portfolioIds: portfolioIds,
      answers: answers,
    );

    bool success = await _provider.postDatabyId(regId, userId, payload);

    if (success) {
      Get.snackbar('Sukses', 'APL-02 berhasil disubmit!');
    } else {
      Get.snackbar('Gagal', 'Terjadi kesalahan sistem');
    }

    isSubmitting.value = false;
  }
}