import '../event.dart';

class RetryLoginEvent extends Event {
  const RetryLoginEvent({required this.data}) : super(name: Event.RETRY_LOGIN);

  final Data data;

  factory RetryLoginEvent.from(Map<String, dynamic> json) {
    final data = Data(code: json['data']['code']);

    return RetryLoginEvent(data: data);
  }
}

class Data {
  final String code;
  const Data({required this.code});

  Map<String, dynamic> toJson() => {'code': code};
}
