import 'dart:convert';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:nabeelaljirbi_app/core/const/shared_pref_helper.dart';
import 'package:nabeelaljirbi_app/feature/patient/ai_chat/model/ai_chat_model.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:http/http.dart' as http;
import 'package:nabeelaljirbi_app/core/network_caller/endpoints.dart';
import 'package:nabeelaljirbi_app/feature/patient/ai_chat/model/ai_chat_config_model.dart';

class AiChatController extends GetxController {
  var messages = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var isStreaming = false.obs;
  final ScrollController scrollController = ScrollController();
  WebSocketChannel? channel;

  var isChatEnabled = true.obs;
  var chatLimit = 0.obs; // Represents live remaining messages in rolling 24h
  var maxLimit = 5.obs; // Configured limit per rolling 24h
  var isConfigLoading = true.obs;

  bool get hasMessages => messages.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    debugPrint('🚀 AiChatController Initialized');
    getConfig();
    connectWebSocket();
  }

  Future<void> getConfig() async {
    isConfigLoading.value = true;
    try {
      final token = SharedPrefHelper.getAccessToken();
      if (token == null) {
        debugPrint('❌ AiChatController: No access token found for config');
        return;
      }

      // First try fetching patient's live rolling 24h status
      final myStatusUrl = '${Urls.baseUrl}/allow-ai-chat/my-status';
      debugPrint('🌍 Fetching User AI Rolling Status: $myStatusUrl');

      final response = await http.get(
        Uri.parse(myStatusUrl),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
        },
      );

      debugPrint('📥 AI Status Response Status: ${response.statusCode}');
      debugPrint('📥 AI Status Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          final data = body['data'];
          isChatEnabled.value = data['isEnable'] ?? true;
          maxLimit.value = data['limit'] ?? 5;
          chatLimit.value = data['remainingCount'] ?? 0;
          debugPrint(
            '✅ Live AI Status Loaded: Enabled=${isChatEnabled.value}, Remaining=${chatLimit.value}/${maxLimit.value}',
          );
          return;
        }
      }

      // Fallback to general config if my-status endpoint is unavailable
      final fallbackUrl = '${Urls.baseUrl}/allow-ai-chat';
      final fallbackResp = await http.get(
        Uri.parse(fallbackUrl),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
        },
      );

      if (fallbackResp.statusCode == 200) {
        final body = jsonDecode(fallbackResp.body);
        if (body['success'] == true && body['data'] != null) {
          final List data = body['data'];
          if (data.isNotEmpty) {
            final config = AiChatConfig.fromJson(data.first);
            isChatEnabled.value = config.isEnable ?? true;
            maxLimit.value = config.limit ?? 5;
            if (chatLimit.value == 0) {
              chatLimit.value = config.limit ?? 0;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Error fetching AI chat config: $e');
    } finally {
      isConfigLoading.value = false;
    }
  }

  @override
  void onClose() {
    channel?.sink.close(status.goingAway);
    super.onClose();
  }

  void connectWebSocket() {
    final token = SharedPrefHelper.getAccessToken();
    if (token == null) {
      debugPrint('❌ AiChatController: No access token found for WebSocket');
      return;
    }

    try {
      final uri = Uri.parse('wss://api.salamaapp.ly/ws/');
      debugPrint('🔌 Connecting to WebSocket: $uri');

      channel = IOWebSocketChannel.connect(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      channel!.stream.listen(
        (message) {
          debugPrint('📨 WebSocket Message Received: $message');
          _handleMessage(message);
        },
        onError: (error) {
          debugPrint('❌ WebSocket error: $error');
          isLoading.value = false;
          isStreaming.value = false;
        },
        onDone: () {
          debugPrint('🔌 WebSocket connection closed');
          isLoading.value = false;
          isStreaming.value = false;
        },
      );

      // Request rolling status & load previous messages
      debugPrint('📜 Requesting history messages...');
      loadHistoryMessages();
    } catch (e) {
      debugPrint('❌ WebSocket connection exception: $e');
    }
  }

  void loadHistoryMessages({int page = 1}) {
    if (channel == null) return;

    final request = {
      "type": "loadMessages",
      "page": page,
      "limit": 50, // Load comprehensive message history
    };

    channel!.sink.add(jsonEncode(request));
  }

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    if (!isChatEnabled.value || chatLimit.value < 1) {
      debugPrint('🚫 Message blocked: Limit reached or Chat Disabled');
      Get.snackbar('error'.tr, 'limit_complete_message'.tr);
      return;
    }

    if (channel == null) {
      debugPrint('⚠️ WebSocket channel is null, attempting reconnect...');
      reconnectWebSocket();
    }

    // Add user message locally
    messages.add({'isUser': true, 'text': text});
    debugPrint('📤 Sending message: $text');
    scrollToBottom();

    // Decrement remaining limit optimistically
    chatLimit.value = max(0, chatLimit.value - 1);
    debugPrint('📉 Limit Decremented. Remaining: ${chatLimit.value}');

    isLoading.value = true;

    final request = {"type": "sendMessage", "question": text};

    if (channel != null) {
      channel!.sink.add(jsonEncode(request));
    } else {
      debugPrint('❌ Failed to send message: WebSocket not connected');
      isLoading.value = false;
    }
  }

  void reconnectWebSocket() {
    if (channel == null || channel!.closeCode != null) {
      connectWebSocket();
    }
  }

  void _handleMessage(dynamic messageData) {
    try {
      final decoded = jsonDecode(messageData);
      final type = decoded['type'];
      debugPrint('📥 Handle Message Type: $type');

      switch (type) {
        case 'userUsageConfig':
          _handleUserUsageConfig(decoded);
          break;
        case 'limitExceeded':
          _handleLimitExceeded(decoded);
          break;
        case 'chatDisabled':
          _handleChatDisabled(decoded);
          break;
        case 'messagesLoaded':
          _handleMessagesLoaded(decoded);
          break;
        case 'streamStart':
          _handleStreamStart(decoded);
          break;
        case 'streamChunk':
          _handleStreamChunk(decoded);
          break;
        case 'doctorRecommendation':
          _handleDoctorRecommendation(decoded);
          break;
        case 'streamEnd':
          _handleStreamEnd(decoded);
          break;
        default:
          debugPrint('⚠️ Unknown message type: $type');
      }
    } catch (e) {
      debugPrint('❌ Error handling message: $e');
    }
  }

  void _handleUserUsageConfig(Map<String, dynamic> data) {
    if (data['remainingCount'] != null) {
      chatLimit.value = data['remainingCount'];
    }
    if (data['limit'] != null) {
      maxLimit.value = data['limit'];
    }
    if (data['isEnable'] != null) {
      isChatEnabled.value = data['isEnable'];
    }
    debugPrint('⚙️ User usage config updated: remaining=${chatLimit.value}/${maxLimit.value}, enabled=${isChatEnabled.value}');
  }

  void _handleLimitExceeded(Map<String, dynamic> data) {
    chatLimit.value = 0;
    isLoading.value = false;
    isStreaming.value = false;
    final msg = data['message'] ?? 'limit_complete_message'.tr;
    Get.snackbar('error'.tr, msg);
  }

  void _handleChatDisabled(Map<String, dynamic> data) {
    isChatEnabled.value = false;
    isLoading.value = false;
    isStreaming.value = false;
    Get.snackbar('error'.tr, data['message'] ?? 'AI Assistant is disabled');
  }

  void _handleDoctorRecommendation(Map<String, dynamic> data) {
    final doctorData = data['doctor'];
    debugPrint(
      '👨‍⚕️ Doctor recommendation: ${doctorData != null ? "Found" : "None"}',
    );
    if (doctorData != null) {
      final userData = doctorData['user'] ?? {};

      final mappedDoctor = {
        'name': userData['fullName'] ?? 'Dr. Specialist',
        'specialty': doctorData['speciality'] ?? 'General',
        'experience': '${doctorData['experience'] ?? 0}y exp',
        'fee': '${doctorData['consultFee'] ?? 0}',
        'rating': '5.0',
        'reviews': '10+',
        'image': userData['profileImage'] ?? 'https://placehold.co/150.png',
        'id': doctorData['id'],
      };

      if (messages.isNotEmpty && messages.last['isUser'] == false) {
        final lastMsg = messages.last;
        lastMsg['doctorRecommendation'] = mappedDoctor;
        messages.refresh();
      } else {
        messages.add({
          'isUser': false,
          'text': 'Here is a recommended doctor for you:',
          'doctorRecommendation': mappedDoctor,
        });
      }
      scrollToBottom();
    }
  }

  void _handleMessagesLoaded(Map<String, dynamic> data) {
    debugPrint('📜 Messages Loaded: ${data.keys}');
    final response = AiChatHistoryResponse.fromJson(data);

    // Sync usage limits if provided by server
    if (response.remainingCount != null) {
      chatLimit.value = response.remainingCount!;
    }
    if (response.chatLimit != null) {
      maxLimit.value = response.chatLimit!;
    }
    if (response.isEnable != null) {
      isChatEnabled.value = response.isEnable!;
    }

    if (response.messages != null) {
      var historyMessages = <Map<String, dynamic>>[];

      for (var msg in response.messages!) {
        // Add question (User)
        if (msg.question != null && msg.question!.isNotEmpty) {
          historyMessages.add({
            'isUser': true,
            'text': msg.question,
            'timestamp': msg.createdAt,
          });
        }
        // Add answer (AI) with doctor recommendation persistence
        if (msg.answer != null && msg.answer!.isNotEmpty) {
          Map<String, dynamic>? mappedDoctor;
          if (msg.doctor != null) {
            final doc = msg.doctor!;
            final userData = doc['user'] ?? {};
            mappedDoctor = {
              'name': userData['fullName'] ?? 'Dr. Specialist',
              'specialty': doc['speciality'] ?? 'General',
              'experience': '${doc['experience'] ?? 0}y exp',
              'fee': '${doc['consultFee'] ?? 0}',
              'rating': '5.0',
              'reviews': '10+',
              'image': userData['profileImage'] ?? 'https://placehold.co/150.png',
              'id': doc['id'] ?? userData['id'],
            };
          final Map<String, dynamic> aiMsg = {
            'isUser': false,
            'text': msg.answer,
            'timestamp': msg.createdAt,
          };
          if (mappedDoctor != null) {
            aiMsg['doctorRecommendation'] = mappedDoctor;
          }
          historyMessages.add(aiMsg);
        }
      }

      // Preserve active in-progress stream if any
      if (isStreaming.value || isLoading.value) {
        final inFlight = messages.where((m) => m['isStreaming'] == true).toList();
        messages.assignAll([...historyMessages, ...inFlight]);
      } else {
        messages.assignAll(historyMessages);
      }
      Future.delayed(const Duration(milliseconds: 100), scrollToBottom);
    }
  }

  void _handleStreamStart(Map<String, dynamic> data) {
    debugPrint('🏁 Stream started');
    isLoading.value = false;
    isStreaming.value = true;
    messages.add({'isUser': false, 'text': '', 'isStreaming': true});
    scrollToBottom();
  }

  void _handleStreamChunk(Map<String, dynamic> data) {
    if (!isStreaming.value) return;

    final chunk = data['chunk'] ?? '';
    if (messages.isNotEmpty && messages.last['isUser'] == false) {
      final currentText = messages.last['text'] ?? '';
      messages.last['text'] = currentText + chunk;
      messages.refresh();
      scrollToBottom();
    }
  }

  void _handleStreamEnd(Map<String, dynamic> data) {
    debugPrint('✅ Stream Ended');
    isStreaming.value = false;
    if (messages.isNotEmpty) {
      messages.last['isStreaming'] = false;
      messages.refresh();
    }
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void clearChat() {
    messages.clear();
  }
}
