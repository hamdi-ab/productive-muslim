import 'dart:convert';

/// Represents a prompt-response pair in a Muhasabah reflection session.
class MuhasabahPromptResponse {
  final String? promptId;
  final String? promptText;
  final String response;

  const MuhasabahPromptResponse({
    this.promptId,
    this.promptText,
    required this.response,
  });

  Map<String, dynamic> toJson() => {
    if (promptId != null) 'promptId': promptId,
    if (promptText != null) 'promptText': promptText,
    'response': response,
  };

  factory MuhasabahPromptResponse.fromJson(Map<String, dynamic> json) {
    return MuhasabahPromptResponse(
      promptId: json['promptId'] as String?,
      promptText: json['promptText'] as String?,
      response: json['response'] as String? ?? '',
    );
  }
}

/// Decoded representation of a Muhasabah reflection's content.
class DecodedMuhasabahContent {
  final List<MuhasabahPromptResponse> prompts;
  final String? freeWriting;

  const DecodedMuhasabahContent({required this.prompts, this.freeWriting});
}

class MuhasabahEntry {
  const MuhasabahEntry({
    required this.id,
    required this.date,
    this.promptId,
    this.promptText,
    required this.content,
    this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String date;
  final String? promptId;
  final String? promptText;
  final String content;
  final String? tags;
  final int createdAt;
  final int updatedAt;

  /// Returns structured prompt responses if present.
  List<MuhasabahPromptResponse> get promptResponses => decodedContent.prompts;

  /// Returns free-writing notes if present.
  String? get freeWriting => decodedContent.freeWriting;

  /// Decoded representation of this entry's prompt responses and free writing.
  DecodedMuhasabahContent get decodedContent {
    return decodeContent(content, promptId: promptId, promptText: promptText);
  }

  /// Encodes multiple prompt responses and/or free writing into a single content string.
  static String encodeContent({
    required List<MuhasabahPromptResponse> prompts,
    String? freeWriting,
  }) {
    final validPrompts = prompts
        .where((p) => p.response.trim().isNotEmpty)
        .toList();
    final hasFree = freeWriting != null && freeWriting.trim().isNotEmpty;

    if (validPrompts.isEmpty) {
      return freeWriting ?? '';
    }

    if (validPrompts.length == 1 && !hasFree) {
      return validPrompts.first.response;
    }

    return jsonEncode({
      'version': 1,
      'prompts': validPrompts.map((p) => p.toJson()).toList(),
      if (hasFree) 'freeWriting': freeWriting,
    });
  }

  /// Decodes any content string given optional fallback promptId & promptText.
  static DecodedMuhasabahContent decodeContent(
    String content, {
    String? promptId,
    String? promptText,
  }) {
    if (content.startsWith('{"version":') ||
        content.startsWith('{"prompts":')) {
      try {
        final map = jsonDecode(content) as Map<String, dynamic>;
        final rawPrompts = map['prompts'] as List?;
        final prompts = rawPrompts == null
            ? <MuhasabahPromptResponse>[]
            : rawPrompts
                  .map(
                    (p) => MuhasabahPromptResponse.fromJson(
                      p as Map<String, dynamic>,
                    ),
                  )
                  .toList();
        final freeWriting = map['freeWriting'] as String?;
        return DecodedMuhasabahContent(
          prompts: prompts,
          freeWriting: freeWriting,
        );
      } catch (_) {}
    }

    if (promptId != null || promptText != null) {
      return DecodedMuhasabahContent(
        prompts: [
          MuhasabahPromptResponse(
            promptId: promptId,
            promptText: promptText,
            response: content,
          ),
        ],
        freeWriting: null,
      );
    }

    return DecodedMuhasabahContent(prompts: const [], freeWriting: content);
  }

  MuhasabahEntry copyWith({
    int? id,
    String? date,
    String? promptId,
    String? promptText,
    String? content,
    String? tags,
    int? createdAt,
    int? updatedAt,
  }) {
    return MuhasabahEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      promptId: promptId ?? this.promptId,
      promptText: promptText ?? this.promptText,
      content: content ?? this.content,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
