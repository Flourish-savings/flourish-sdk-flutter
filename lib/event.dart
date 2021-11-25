class Event {
  Event({required this.type});
  final String type;
  static const String pointsEarned = 'points_earned';
  static const String goToSavings = 'go_to_savings';
  static const String goToWinners = 'go_to_winners';
  static const String share = 'share';

  factory Event.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    switch (type) {
      case pointsEarned:
        return PointsEarnedEvent.from(json);
      case goToSavings:
        return GoToSavingsEvent();
      case goToWinners:
        return GoToWinners();
      case share:
        return ShareEvent.from(json);
      default:
        throw Exception('Unsupported event type');
    }
  }
}

class PointsEarnedEvent extends Event {
  PointsEarnedEvent(
      {required this.amount, required this.newBalance, required this.when})
      : super(type: 'points_earned');

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

class GoToSavingsEvent extends Event {
  GoToSavingsEvent() : super(type: 'go_to_savings');
}

class GoToWinners extends Event {
  GoToWinners() : super(type: 'go_to_winners');
}

class NotificationAvailable extends Event {
  NotificationAvailable({
    this.hasNotificationAvailable = false,
  }) : super(type: 'notification');

  final bool hasNotificationAvailable;
}

class ErrorEvent extends Event {
  final String code;
  final String message;
  ErrorEvent(this.code, this.message) : super(type: 'error');
}

class ShareEvent extends Event {
  ShareEvent(
      {required this.title, required this.description})
      : super(type: 'share');

  final String title;
  final String description;

  factory ShareEvent.from(Map<String, dynamic> json) {
    return ShareEvent(
        title: json['title'],
        description: json['description']);
  }
}