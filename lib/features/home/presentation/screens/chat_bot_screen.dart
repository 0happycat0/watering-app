import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:watering_app/core/constants/app_colors.dart';

class ChatBotScreen extends StatelessWidget {
  const ChatBotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,

        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.secondaryGreen[200]!,
                AppColors.secondaryGreen[150]!,
              ],
            ),
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Icon robot
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.smart_toy_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 10),
              // Text Header
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trợ lý AI',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Luôn sẵn sàng hỗ trợ',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          // Nút đóng (X)
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: LlmChatView(
        enableAttachments: false,
        welcomeMessage:
            'Xin chào! Tôi là trợ lý AI của hệ thống tưới cây. Tôi có thể giúp gì cho bạn?',
        suggestions: [
          'Tưới bao nhiêu nước là đủ?',
          'Cây bị vàng lá phải làm sao?',
          'Lịch tưới cho cây sen đá?',
          'Cách phòng trừ sâu bệnh?',
        ],
        provider: FirebaseProvider(
          model: FirebaseAI.googleAI().generativeModel(
            model: 'gemini-2.5-flash',
            generationConfig: GenerationConfig(
              temperature: 0.7,
              maxOutputTokens: 500,
            ),
            safetySettings: [
              SafetySetting(
                HarmCategory.harassment,
                HarmBlockThreshold.high,
                null,
              ),
            ],
            systemInstruction: Content.system('''
              Bạn là Trợ lý AI chuyên gia của ứng dụng tưới cây.
              Nhiệm vụ: Hỗ trợ chăm sóc cây trồng, tư vấn lịch tưới, đất trồng và sâu bệnh.
              
              Quy tắc:
              1. CHỈ trả lời về cây cối và nông nghiệp. Từ chối khéo các chủ đề khác.
              2. Trả lời ngắn gọn, thân thiện, dùng Emoji 🌿💧.
              3. Luôn định dạng văn bản bằng Markdown (in đậm ý chính).
              4. Nếu cây bị bệnh, hãy hỏi thêm triệu chứng trước khi đưa ra lời khuyên.
              '''),
          ),
        ),
        errorMessage: 'Hệ thống đang bận, vui lòng thử lại sau.',
        style: LlmChatViewStyle(
          backgroundColor: Colors.transparent,
          progressIndicatorColor: Colors.black,
          chatInputStyle: ChatInputStyle(
            backgroundColor: Colors.transparent,
            hintText: 'Nhập tin nhắn...',
          ),
          llmMessageStyle: LlmMessageStyle(
            icon: Symbols.smart_toy_rounded,
            iconColor: Colors.white,
            iconDecoration: BoxDecoration(
              color: AppColors.secondaryGreen[200],
              shape: BoxShape.circle,
            ),
            decoration: BoxDecoration(
              color: AppColors.divider.withAlpha(150),
              borderRadius: BorderRadius.only(
                topLeft: Radius.zero,
                bottomLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
          ),
          userMessageStyle: UserMessageStyle(
            textStyle: TextStyle(color: Colors.white, fontSize: 16),
            decoration: BoxDecoration(
              color: AppColors.secondaryGreen[200],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                topRight: Radius.zero,
                bottomRight: Radius.circular(20),
              ),
            ),
          ),
          suggestionStyle: SuggestionStyle(
            // textStyle: TextStyle(color: Colors.white, fontSize: 16),
            decoration: BoxDecoration(
              // color: AppColors.secondaryGreen[200],
              color: AppColors.divider.withAlpha(150),
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
          ),
          submitButtonStyle: ActionButtonStyle(
            iconDecoration: BoxDecoration(
              color: AppColors.secondaryGreen[200],
              shape: BoxShape.circle,
            ),
          ),
          recordButtonStyle: ActionButtonStyle(
            iconColor: Colors.white,
            iconDecoration: BoxDecoration(
              color: AppColors.secondaryGreen[200],
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
