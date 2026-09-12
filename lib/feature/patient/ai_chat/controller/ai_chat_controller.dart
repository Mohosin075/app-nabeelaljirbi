import 'dart:convert';

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
  var chatLimit = 0.obs;
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

      final url = '${Urls.baseUrl}/allow-ai-chat';
      debugPrint('🌍 Fetching AI Chat Config: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
        },
      );

      debugPrint('📥 Config Response Status: ${response.statusCode}');
      debugPrint('📥 Config Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          final List data = body['data'];
          if (data.isNotEmpty) {
            final config = AiChatConfig.fromJson(data.first);
            isChatEnabled.value = config.isEnable ?? true;
            chatLimit.value = config.limit ?? 0;
            debugPrint(
              '✅ Chat Config Loaded: Enabled=${isChatEnabled.value}, Limit=${chatLimit.value}',
            );
          } else {
            debugPrint('⚠️ Chat Config Data is empty');
          }
        } else {
          debugPrint('⚠️ Chat Config Success is false or data is null');
        }
      } else {
        debugPrint('❌ Failed to load config: ${response.statusCode}');
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
      //final uri = Uri.parse('ws://206.162.244.141:8003/ws/');
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

      // Load initial messages after connection
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
      "limit": 10, // As per user request example
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

    // Decrement limit
    chatLimit.value--;
    debugPrint('📉 Limit Decremented. New Limit: ${chatLimit.value}');

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
    // simple retry logic if needed, for now just call connect
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

  void _handleDoctorRecommendation(Map<String, dynamic> data) {
    // We assume this recommendation comes after a relevant query.
    // We can append it as a separate message or part of the last AI message.
    // The UI supports 'doctorRecommendation' key in the message map.

    // If the last message is from AI (which it should be if we just got an answer/stream),
    // we can attach it there. Or we can create a new message bubble.
    // Given the flow, usually AI answers then recommends.

    final doctorData = data['doctor'];
    debugPrint(
      '👨‍⚕️ Doctor recommendation: ${doctorData != null ? "Found" : "None"}',
    );
    if (doctorData != null) {
      debugPrint('👨‍⚕️ Doctor Data: ${jsonEncode(doctorData)}');
      final userData = doctorData['user'] ?? {};

      final mappedDoctor = {
        'name': userData['fullName'] ?? 'Dr. Unknown',
        'specialty': doctorData['speciality'] ?? 'General',
        'experience': '${doctorData['experience'] ?? 0}y exp',
        'fee': '${doctorData['consultFee'] ?? 0}',
        'rating': '5.0', // Default as API doesn't provide it yet
        'reviews': '10+', // Default
        'image': userData['profileImage'] ?? 'https://placehold.co/150.png',
        'id': doctorData['id'], // Added ID for navigation
      };

      // Check if last message is AI and append, otherwise create new
      if (messages.isNotEmpty && messages.last['isUser'] == false) {
        final lastMsg = messages.last;
        // If we are currently streaming or just finished, attach it
        lastMsg['doctorRecommendation'] = mappedDoctor;
        messages.refresh();
      } else {
        // Create a new message just for the card
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
        // Add answer (AI)
        if (msg.answer != null && msg.answer!.isNotEmpty) {
          historyMessages.add({
            'isUser': false,
            'text': msg.answer,
            'timestamp': msg.createdAt, // or updatedAt
          });
        }
      }
      messages.assignAll(historyMessages);
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
    // Optional: too verbose for large texts, but requested
    // debugPrint('🧩 Stream chunk: $chunk'); // Commented out to avoid spamming logs
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
