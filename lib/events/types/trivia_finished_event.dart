import '../event.dart';

class TriviaFinishedEvent extends Event {

  static const EVENT_NAME = "TriviaFinished";

  TriviaFinishedEvent({required this.data})
      : super(name: EVENT_NAME);

  final Data data;

  factory TriviaFinishedEvent.from(Map<String, dynamic> json) {

    List<Prizes> prizeList = [];

    if(json['data']['prizes'].length > 0){
      prizeList = List<Prizes>.from(
          json['data']['prizes']
              .map((prize) => Prizes.fromJson(prize))
      );
    }

    var data = Data(
        hits: json['data']['hits'],
        questions: json['data']['questions'],
        prizes: prizeList
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
  int hits;
  int questions;
  List<Prizes> prizes;

  Data({required this.hits, required this.questions, required this.prizes});

  Map toJson() {
    return {'hits': hits, 'questions': questions, 'prizes': prizes};
  }
}

class Prizes {
  int quantity;
  String category;

  Prizes({required this.quantity, required this.category});

  factory Prizes.fromJson(Map<String, dynamic> json) {
    return new Prizes(
      quantity: json['quantity'],
      category: json['category'],
    );
  }

  Map toJson() => {
    'quantity': quantity,
    'category': category,
  };
}
