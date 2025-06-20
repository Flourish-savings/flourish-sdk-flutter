import '../event.dart';

class TriviaFinishedEvent extends Event {
  const TriviaFinishedEvent({required this.data})
      : super(name: Event.TRIVIA_FINISHED);

  final Data data;

  factory TriviaFinishedEvent.from(Map<String, dynamic> json) {
    final List<Prizes> prizeList = [];
    final prizes = json['data']['prizes'];

    if (prizes.length > 0) {
      prizeList.addAll(
        prizes.map((prize) => Prizes.fromJson(prize)),
      );
    }

    final data = Data(
        hits: json['data']['hits'],
        questions: json['data']['questions'],
        prizes: prizeList);

    return TriviaFinishedEvent(data: data);
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'data': data.toJson()};
  }
}

class Data {
  final int hits;
  final int questions;
  final List<Prizes> prizes;

  const Data({
    required this.hits,
    required this.questions,
    required this.prizes,
  });

  Map<String, dynamic> toJson() {
    return {
      'hits': hits,
      'questions': questions,
      'prizes': prizes.map((p) => p.toJson()).toList(),
    };
  }
}

class Prizes {
  final int quantity;
  final String category;

  const Prizes({required this.quantity, required this.category});

  factory Prizes.fromJson(Map<String, dynamic> json) {
    return Prizes(
      quantity: json['quantity'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() => {
        'quantity': quantity,
        'category': category,
      };
}
