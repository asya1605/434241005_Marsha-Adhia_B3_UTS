class TicketHistoryModel {
  final String? id;
  final String ticketId;
  final String action;
  final String? oldValue;
  final String? newValue;
  final String? changedBy;
  final DateTime createdAt;

  TicketHistoryModel({
    this.id,
    required this.ticketId,
    required this.action,
    this.oldValue,
    this.newValue,
    this.changedBy,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory TicketHistoryModel.fromMap(Map<String, dynamic> map) {
    return TicketHistoryModel(
      id: map['id']?.toString(),
      ticketId: map['ticket_id']?.toString() ?? '',
      action: map['action']?.toString() ?? '',
      oldValue: map['old_value']?.toString(),
      newValue: map['new_value']?.toString(),
      changedBy: map['changed_by']?.toString(),
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'ticket_id': ticketId,
      'action': action,
      'old_value': oldValue,
      'new_value': newValue,
      'changed_by': changedBy,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
