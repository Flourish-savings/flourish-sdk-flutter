import '../../event.dart';

class InvalidTokenEvent extends Event {

  static const EVENT_NAME = "INVALID_TOKEN";

  InvalidTokenEvent({required this.data})
      : super(name: EVENT_NAME);

  final Data data;

  factory InvalidTokenEvent.from(Map<String, dynamic> json) {

    var data = Data(
        errorMessage: json['data']['errorMessage']
    );

    return InvalidTokenEvent(
        data: data
    );
  }

  Map toJson() {
    Map? data = this.data.toJson();
    return {'name': name, 'data': data};
  }

}

class Data {
  String errorMessage;

  Data({required this.errorMessage});

  Map toJson() => {
    'errorMessage': errorMessage
  };
}
