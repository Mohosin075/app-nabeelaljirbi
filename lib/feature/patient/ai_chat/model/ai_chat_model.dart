class AiChatHistoryResponse {
  String? type;
  int? page;
  int? limit;
  int? totalCount;
  int? totalPages;
  int? remainingCount;
  int? usedCount;
  int? chatLimit;
  bool? isEnable;
  List<AiChatHistoryMessage>? messages;

  AiChatHistoryResponse({
    this.type,
    this.page,
    this.limit,
    this.totalCount,
    this.totalPages,
    this.remainingCount,
    this.usedCount,
    this.chatLimit,
    this.isEnable,
    this.messages,
  });

  factory AiChatHistoryResponse.fromJson(Map<String, dynamic> json) {
    return AiChatHistoryResponse(
      type: json['type'],
      page: json['page'],
      limit: json['limit'],
      totalCount: json['totalCount'],
      totalPages: json['totalPages'],
      remainingCount: json['remainingCount'],
      usedCount: json['usedCount'],
      chatLimit: json['chatLimit'],
      isEnable: json['isEnable'],
      messages: json['messages'] != null
          ? (json['messages'] as List)
                .map((i) => AiChatHistoryMessage.fromJson(i))
                .toList()
          : null,
    );
  }
}

class AiChatHistoryMessage {
  String? id;
  String? userId;
  String? question;
  String? answer;
  String? doctorId;
  String? createdAt;
  Map<String, dynamic>? doctor;

  AiChatHistoryMessage({
    this.id,
    this.userId,
    this.question,
    this.answer,
    this.doctorId,
    this.createdAt,
    this.doctor,
  });

  factory AiChatHistoryMessage.fromJson(Map<String, dynamic> json) {
    return AiChatHistoryMessage(
      id: json['id'],
      userId: json['userId'],
      question: json['question'],
      answer: json['answer'],
      doctorId: json['doctorId'],
      createdAt: json['createdAt'],
      doctor: json['doctor'] != null ? Map<String, dynamic>.from(json['doctor']) : null,
    );
  }
}
