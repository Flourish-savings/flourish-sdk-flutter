import 'package:flutter/foundation.dart';

class Event {
  Event({@required this.type});
  final String type;
  static const String pointsEarned = 'points_earned';

  factory Event.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    switch (type) {
      case pointsEarned:
        return PointsEarnedEvent.from(json);
      default:
        throw Exception('Unsupported event type');
    }
  }
}

class PointsEarnedEvent extends Event {
  PointsEarnedEvent({
    this.amount,
    this.newBalance,
    this.when,
  }) : super(type: 'points_earned');

  final double amount;
  final double newBalance;
  final DateTime when;

  factory PointsEarnedEvent.from(Map<String, dynamic> json) {
    return PointsEarnedEvent(
        amount: json['amount'],
        newBalance: json['new_balance'],
        when: json['when']);
  }
}

class WebviewLoadedEvent extends Event {
  WebviewLoadedEvent() : super(type: 'webview_loaded');
}

class NotificationAvailable extends Event {
  NotificationAvailable() : super(type: 'notification');
}

class ErrorEvent extends Event {
  final String code;
  final String message;
  ErrorEvent(this.code, this.message) : super(type: 'error');
}
