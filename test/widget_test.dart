import 'package:flutter_test/flutter_test.dart';
import 'package:helpdesk_ticket/features/ticket/data/models/ticket_model.dart';
import 'package:helpdesk_ticket/features/ticket/data/models/ticket_history_model.dart';

void main() {
  group('TicketModel Tests', () {
    test('should parse from JSON correctly', () {
      final json = {
        'id': '1234',
        'title': 'Test Ticket',
        'description': 'This is a test ticket description',
        'status': 'Open',
        'user_id': 'user-99',
        'category': 'Network',
        'priority': 'High',
        'created_at': '2026-06-26T20:00:00.000Z',
        'assigned_to': 'agent-01',
        'image_url': 'https://example.com/image.png',
        'creator': {
          'name': 'Creator Name',
        },
        'helpdesk': {
          'name': 'Agent Name',
        }
      };

      final ticket = TicketModel.fromJson(json);

      expect(ticket.id, '1234');
      expect(ticket.title, 'Test Ticket');
      expect(ticket.description, 'This is a test ticket description');
      expect(ticket.status, 'Open');
      expect(ticket.userId, 'user-99');
      expect(ticket.category, 'Network');
      expect(ticket.priority, 'High');
      expect(ticket.createdAt, DateTime.parse('2026-06-26T20:00:00.000Z'));
      expect(ticket.assignedTo, 'agent-01');
      expect(ticket.imageUrl, 'https://example.com/image.png');
      expect(ticket.creatorName, 'Creator Name');
      expect(ticket.assignedName, 'Agent Name');
    });

    test('should convert to map correctly', () {
      final ticket = TicketModel(
        id: '1234',
        title: 'Test Ticket',
        description: 'This is a test ticket description',
        status: 'Open',
        userId: 'user-99',
        category: 'Network',
        priority: 'High',
        createdAt: DateTime.parse('2026-06-26T20:00:00.000Z'),
        assignedTo: 'agent-01',
        imageUrl: 'https://example.com/image.png',
      );

      final map = ticket.toMap();

      expect(map['id'], '1234');
      expect(map['title'], 'Test Ticket');
      expect(map['description'], 'This is a test ticket description');
      expect(map['status'], 'Open');
      expect(map['user_id'], 'user-99');
      expect(map['category'], 'Network');
      expect(map['priority'], 'High');
      expect(map['created_at'], '2026-06-26T20:00:00.000Z');
      expect(map['assigned_to'], 'agent-01');
      expect(map['image_url'], 'https://example.com/image.png');
    });

    test('copyWith should return updated object', () {
      final ticket = TicketModel(
        id: '1234',
        title: 'Test Ticket',
        description: 'Description',
        status: 'Open',
        userId: 'user-99',
      );

      final updated = ticket.copyWith(
        status: 'Resolved',
        title: 'New Title',
      );

      expect(updated.id, '1234');
      expect(updated.title, 'New Title');
      expect(updated.description, 'Description');
      expect(updated.status, 'Resolved');
      expect(updated.userId, 'user-99');
    });
  });

  group('TicketHistoryModel Tests', () {
    test('should parse from map correctly', () {
      final map = {
        'id': 'history-01',
        'ticket_id': '1234',
        'action': 'Status Changed',
        'old_value': 'Open',
        'new_value': 'In Progress',
        'changed_by': 'Agent Name',
        'created_at': '2026-06-26T20:10:00.000Z',
      };

      final history = TicketHistoryModel.fromMap(map);

      expect(history.id, 'history-01');
      expect(history.ticketId, '1234');
      expect(history.action, 'Status Changed');
      expect(history.oldValue, 'Open');
      expect(history.newValue, 'In Progress');
      expect(history.changedBy, 'Agent Name');
      expect(history.createdAt, DateTime.parse('2026-06-26T20:10:00.000Z'));
    });

    test('should convert to map correctly', () {
      final history = TicketHistoryModel(
        id: 'history-01',
        ticketId: '1234',
        action: 'Status Changed',
        oldValue: 'Open',
        newValue: 'In Progress',
        changedBy: 'Agent Name',
        createdAt: DateTime.parse('2026-06-26T20:10:00.000Z'),
      );

      final map = history.toMap();

      expect(map['id'], 'history-01');
      expect(map['ticket_id'], '1234');
      expect(map['action'], 'Status Changed');
      expect(map['old_value'], 'Open');
      expect(map['new_value'], 'In Progress');
      expect(map['changed_by'], 'Agent Name');
      expect(map['created_at'], '2026-06-26T20:10:00.000Z');
    });
  });
}
