/// Dispute message for threaded conversations in disputes
class DisputeMessage {
  final int id;
  final int disputeId;
  final String message;
  final MessageSender sender; // user, vendor, admin, system
  final int? senderId;
  final String? senderName;
  final bool isInternal; // internal admin notes vs public messages
  final List<String> attachments;
  final DateTime createdAt;

  const DisputeMessage({
    required this.id,
    required this.disputeId,
    required this.message,
    required this.sender,
    this.senderId,
    this.senderName,
    required this.isInternal,
    required this.attachments,
    required this.createdAt,
  });

  factory DisputeMessage.fromJson(Map<String, dynamic> json) {
    return DisputeMessage(
      id: json['id'] as int,
      disputeId: json['dispute_id'] as int,
      message: json['message'] as String,
      sender: MessageSender.fromString(json['sender'] as String),
      senderId: json['sender_id'] as int?,
      senderName: json['sender_name'] as String?,
      isInternal: json['is_internal'] as bool? ?? false,
      attachments:
          (json['attachments'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dispute_id': disputeId,
      'message': message,
      'sender': sender.value,
      'sender_id': senderId,
      'sender_name': senderName,
      'is_internal': isInternal,
      'attachments': attachments,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Check if message has attachments
  bool get hasAttachments => attachments.isNotEmpty;

  /// Get sender display name
  String get displayName {
    if (senderName != null) return senderName!;
    return sender.label;
  }

  DisputeMessage copyWith({
    int? id,
    int? disputeId,
    String? message,
    MessageSender? sender,
    int? senderId,
    String? senderName,
    bool? isInternal,
    List<String>? attachments,
    DateTime? createdAt,
  }) {
    return DisputeMessage(
      id: id ?? this.id,
      disputeId: disputeId ?? this.disputeId,
      message: message ?? this.message,
      sender: sender ?? this.sender,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      isInternal: isInternal ?? this.isInternal,
      attachments: attachments ?? this.attachments,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Message sender type enum
enum MessageSender {
  user('user', 'User'),
  vendor('vendor', 'Vendor'),
  admin('admin', 'Admin'),
  system('system', 'System');

  final String value;
  final String label;

  const MessageSender(this.value, this.label);

  static MessageSender fromString(String value) {
    return MessageSender.values.firstWhere(
      (e) => e.value == value,
      orElse: () => MessageSender.system,
    );
  }
}
