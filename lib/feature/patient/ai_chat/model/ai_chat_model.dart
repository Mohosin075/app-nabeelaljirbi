class AiChatHistoryResponse {
  String? type;
  int? page;
  int? limit;
  int? totalCount;
  int? totalPages;
  List<AiChatHistoryMessage>? messages;

  AiChatHistoryResponse({
    this.type,
    this.page,
    this.limit,
    this.totalCount,
    this.totalPages,
    this.messages,
  });

  factory AiChatHistoryResponse.fromJson(Map<String, dynamic> json) {
    return AiChatHistoryResponse(
      type: json['type'],
      page: json['page'],
      limit: json['limit'],
      totalCount: json['totalCount'],
      totalPages: json['totalPages'],
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

  AiChatHistoryMessage({
    this.id,
    this.userId,
    this.question,
    this.answer,
    this.doctorId,
    this.createdAt,
  });

  factory AiChatHistoryMessage.fromJson(Map<String, dynamic> json) {
    return AiChatHistoryMessage(
      id: json['id'],
      userId: json['userId'],
      question: json['question'],
      answer: json['answer'],
      doctorId: json['doctorId'],
      createdAt: json['createdAt'],
    );
  }
}
