import '../../event.dart';

class TriviaGameFinishedEvent extends Event {
  const TriviaGameFinishedEvent({required this.data})
      : super(name: Event.TRIVIA_GAME_FINISHED);

  final Data data;

  factory TriviaGameFinishedEvent.from(Map<String, dynamic> json) {
    final List<Prizes> prizeList = [];
    final prizes = json['data']['prizes'];

    if (prizes.length > 0) {
      prizeList.addAll(
        prizes.map((prize) => Prizes.fromJson(prize)),
      );
    }

    final data = Data(
      hits: json['data']['totalHitsQuestions'],
      time: json['data']['totalTimeSeconds'],
      questions: json['data']['totalQuestions'],
      prizes: prizeList,
    );

    return TriviaGameFinishedEvent(data: data);
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'data': data.toJson()};
  }
}

class Data {
  final int hits;
  final int questions;
  final String time;
  final List<Prizes> prizes;

  const Data({
    required this.hits,
    required this.questions,
    required this.time,
    required this.prizes,
  });

  Map<String, dynamic> toJson() {
    return {
      'hits': hits,
      'questions': questions,
      'time': time,
      'prizes': prizes.map((p) => p.toJson()).toList(),
    };
  }
}

class Prizes {
  final int quantity;
  final String category;
  final String label;

  const Prizes({
    required this.quantity,
    required this.category,
    required this.label,
  });

  factory Prizes.fromJson(Map<String, dynamic> json) {
    return Prizes(
      quantity: json['quantity'],
      category: json['category'],
      label: json['label'],
    );
  }

  Map<String, dynamic> toJson() => {
        'quantity': quantity,
        'category': category,
        'label': label,
      };
}
