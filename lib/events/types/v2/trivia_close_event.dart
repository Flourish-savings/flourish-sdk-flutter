import '../../event.dart';

class TriviaCloseEvent extends Event {

  static const EVENT_NAME = "TRIVIA_CLOSED";

  TriviaCloseEvent({required this.data})
      : super(name: EVENT_NAME);

  final Data data;

  factory TriviaCloseEvent.from(Map<String, dynamic> json) {

    List<Prizes> prizeList = [];

    if(json['data']['prizes'].length > 0){
      prizeList = List<Prizes>.from(
          json['data']['prizes']
              .map((prize) => Prizes.fromJson(prize))
      );
    }

    var data = Data(
        hits: json['data']['totalHitsQuestions'],
        time: json['data']['totalTimeSeconds'],
        questions: json['data']['totalQuestions'],
        prizes: prizeList
    );

    return TriviaCloseEvent(
        data: data
    );

  }

  Map toJson() {
    Map? data = this.data.toJson();
    return {'name': name, 'data': data};
  }

}

class Data {
  int hits;
  int questions;
  String time;
  List<Prizes> prizes;

  Data({required this.hits, required this.questions, required this.time, required this.prizes});

  Map toJson() {
    return {'hits': hits, 'questions': questions, 'time': time, 'prizes': prizes};
  }
}

class Prizes {
  int quantity;
  String category;
  String label;

  Prizes({required this.quantity, required this.category, required this.label});

  factory Prizes.fromJson(Map<String, dynamic> json) {
    return new Prizes(
      quantity: json['quantity'],
      category: json['category'],
      label: json['label'],
    );
  }

  Map toJson() => {
    'quantity': quantity,
    'category': category,
    'label': label,
  };
}