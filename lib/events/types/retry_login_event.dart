import '../event.dart';

class RetryLoginEvent extends Event {

  static const EVENT_NAME = "RetryLogin";

  RetryLoginEvent({required this.data})
      : super(name: EVENT_NAME);

  final Data data;

  factory RetryLoginEvent.from(Map<String, dynamic> json) {

    var data = Data(
        code: json['data']['code']
    );

    return RetryLoginEvent(
        data: data
    );
  }

}

class Data {
  String code;
  Data({required this.code});

  Map toJson() => {
    'code': code
  };
}
