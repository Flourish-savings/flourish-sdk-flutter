import '../event.dart';

class TriviaFinishedEvent extends Event {

  static const EVENT_NAME = "TriviaFinished";

  TriviaFinishedEvent({required this.data})
      : super(name: EVENT_NAME);

  final Data data;

  factory TriviaFinishedEvent.from(Map<String, dynamic> json) {

    var prizes = Prizes(
        quantity: json['data']['prizes']['quantity'],
        category: json['data']['prizes']['category']
    );

    var data = Data(
        hits: json['data']['hits'],
        questions: json['data']['questions'],
        prizes: prizes
    );

    return TriviaFinishedEvent(
        data: data
    );

  }

  Map toJson() {
    Map? data = this.data.toJson();
    return {'name': name, 'data': data};
  }

}

class Data {
  double hits;
  double questions;
  Prizes prizes;

  Data({required this.hits, required this.questions, required this.prizes});

  Map toJson() {
    Map? prizes = this.prizes.toJson();
    return {'hits': hits, 'questions': questions, 'prizes': prizes};
  }
}

class Prizes {
  double quantity;
  String category;

  Prizes({required this.quantity, required this.category});

  Map toJson() => {
    'quantity': quantity,
    'category': category,
  };
}
