class SubmitApl02Request {
  bool isDeclared;
  List<int> portfolioIds;
  List<AnswerModel> answers;

  SubmitApl02Request({required this.isDeclared, required this.portfolioIds, required this.answers});

  Map<String, dynamic> toJson() => {
        'is_declared': isDeclared ? 1 : 0,
        'portfolio_ids': portfolioIds,
        'answers': answers.map((x) => x.toJson()).toList(),
      };
}

class AnswerModel {
  int elementId;
  bool isCompetent;
  AnswerModel({required this.elementId, required this.isCompetent});
  Map<String, dynamic> toJson() => {'element_id': elementId, 'is_competent': isCompetent ? 1 : 0};
}